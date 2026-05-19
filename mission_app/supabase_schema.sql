-- ################################################################################
-- # SCHEMA COMPLETO DO MISSIONAPP (Go4Me)
-- # Execute este script no SQL Editor do Supabase na ordem.
-- # Inclui: perfis, missionários, doadores, doações, projetos, social
-- ################################################################################

-- ============================================================================
-- 1. ENUM PARA ROLES (PAPÉIS)
-- ============================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('donor', 'missionary', 'admin');
    END IF;
END$$;

-- ============================================================================
-- 2. TABELA DE PERFIS (PROFILES)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  email TEXT UNIQUE NOT NULL,
  avatar_url TEXT,
  role user_role DEFAULT 'donor',
  country TEXT,
  slug TEXT UNIQUE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile" 
ON public.profiles FOR SELECT 
USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone" 
ON public.profiles FOR SELECT 
USING (true);

-- ============================================================================
-- 3. TRIGGER: CRIAR PERFIL AUTOMATICAMENTE NO SIGNUP
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
DECLARE
  final_slug TEXT;
  base_slug TEXT;
  counter INT := 0;
BEGIN
  base_slug := NULLIF(new.raw_user_meta_data->>'slug', '');
  final_slug := base_slug;

  IF final_slug IS NOT NULL THEN
    WHILE EXISTS (SELECT 1 FROM public.profiles WHERE slug = final_slug) LOOP
      counter := counter + 1;
      final_slug := base_slug || '-' || counter;
    END LOOP;
  END IF;

  INSERT INTO public.profiles (id, full_name, email, avatar_url, role, country, slug)
  VALUES (
    new.id, 
    new.raw_user_meta_data->>'full_name', 
    new.email, 
    new.raw_user_meta_data->>'avatar_url',
    COALESCE(
      NULLIF(new.raw_user_meta_data->>'role', '')::user_role,
      'donor'::user_role
    ),
    NULLIF(new.raw_user_meta_data->>'country', ''),
    final_slug
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    updated_at = CURRENT_TIMESTAMP;
    
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ============================================================================
-- 4. TABELA DE MISSIONÁRIOS (MISSIONARIES)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.missionaries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  location TEXT,
  latitude DOUBLE PRECISION DEFAULT 0,
  longitude DOUBLE PRECISION DEFAULT 0,
  years_in_field TEXT,
  lives_impacted TEXT,
  headline TEXT,
  full_story TEXT,
  current_support DOUBLE PRECISION DEFAULT 0,
  goal_support DOUBLE PRECISION DEFAULT 0,
  profile_image_url TEXT,
  cover_image_url TEXT,
  nationality TEXT,
  nationality_code TEXT,
  country_code TEXT,
  category TEXT DEFAULT 'church_planting',
  is_public BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.missionaries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Missionaries are viewable by everyone" ON public.missionaries;
CREATE POLICY "Missionaries are viewable by everyone" 
ON public.missionaries FOR SELECT 
USING (is_public = true OR auth.uid() = profile_id);

DROP POLICY IF EXISTS "Missionaries can update own profile" ON public.missionaries;
CREATE POLICY "Missionaries can update own profile" 
ON public.missionaries FOR UPDATE 
USING (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Admins can insert missionaries" ON public.missionaries;
CREATE POLICY "Admins can insert missionaries" 
ON public.missionaries FOR INSERT 
WITH CHECK (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('missionary', 'admin'))
);

-- ============================================================================
-- 5. TABELA DE DOADORES (DONORS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.donors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT,
  avatar_url TEXT,
  total_donated DOUBLE PRECISION DEFAULT 0,
  supported_missions_count INT DEFAULT 0,
  lives_impacted_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.donors ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Donors can view own record" ON public.donors;
CREATE POLICY "Donors can view own record" 
ON public.donors FOR SELECT 
USING (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Donors can update own record" ON public.donors;
CREATE POLICY "Donors can update own record" 
ON public.donors FOR UPDATE 
USING (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Donor data viewable by supported missionaries" ON public.donors;
CREATE POLICY "Donor data viewable by supported missionaries" 
ON public.donors FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.donations d
    JOIN public.missionaries m ON d.missionary_id = m.id
    WHERE d.donor_id = donors.id AND m.profile_id = auth.uid()
  )
);

-- ============================================================================
-- 6. TABELA DE DOAÇÕES (DONATIONS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.donations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  donor_id UUID REFERENCES public.donors(id) ON DELETE CASCADE NOT NULL,
  missionary_id UUID REFERENCES public.missionaries(id) ON DELETE CASCADE NOT NULL,
  project_id UUID, -- nullable, for project-specific donations
  amount DOUBLE PRECISION NOT NULL,
  currency TEXT DEFAULT 'BRL',
  is_recurring BOOLEAN DEFAULT false,
  is_anonymous BOOLEAN DEFAULT false,
  stripe_payment_intent_id TEXT,
  status TEXT DEFAULT 'pending', -- pending, completed, failed, refunded
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Donors can view own donations" ON public.donations;
CREATE POLICY "Donors can view own donations" 
ON public.donations FOR SELECT 
USING (
  EXISTS (SELECT 1 FROM public.donors WHERE id = donations.donor_id AND profile_id = auth.uid())
);

DROP POLICY IF EXISTS "Missionaries can view donations to them" ON public.donations;
CREATE POLICY "Missionaries can view donations to them" 
ON public.donations FOR SELECT 
USING (
  EXISTS (SELECT 1 FROM public.missionaries WHERE id = donations.missionary_id AND profile_id = auth.uid())
);

DROP POLICY IF EXISTS "Authenticated users can create donations" ON public.donations;
CREATE POLICY "Authenticated users can create donations" 
ON public.donations FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL);

-- ============================================================================
-- 7. TABELA DE PROJETOS (PROJECTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.projects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  missionary_id UUID REFERENCES public.missionaries(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  goal DOUBLE PRECISION DEFAULT 0,
  current DOUBLE PRECISION DEFAULT 0,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Projects are viewable by everyone" ON public.projects;
CREATE POLICY "Projects are viewable by everyone" 
ON public.projects FOR SELECT USING (true);

DROP POLICY IF EXISTS "Missionaries can manage own projects" ON public.projects;
CREATE POLICY "Missionaries can manage own projects" 
ON public.projects FOR ALL 
USING (
  EXISTS (SELECT 1 FROM public.missionaries WHERE id = projects.missionary_id AND profile_id = auth.uid())
);

-- ============================================================================
-- 8. TABELA DE LOCALIZAÇÕES PASSADAS (PAST_LOCATIONS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.past_locations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  missionary_id UUID REFERENCES public.missionaries(id) ON DELETE CASCADE NOT NULL,
  city TEXT,
  country TEXT,
  country_code TEXT,
  period TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.past_locations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Past locations are viewable by everyone" ON public.past_locations;
CREATE POLICY "Past locations are viewable by everyone" 
ON public.past_locations FOR SELECT USING (true);

DROP POLICY IF EXISTS "Missionaries can manage own past locations" ON public.past_locations;
CREATE POLICY "Missionaries can manage own past locations" 
ON public.past_locations FOR ALL 
USING (
  EXISTS (SELECT 1 FROM public.missionaries WHERE id = past_locations.missionary_id AND profile_id = auth.uid())
);

-- ============================================================================
-- 9. TABELA DE POSTAGENS (POSTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT,
  media_urls JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Posts are viewable by everyone" ON public.posts;
CREATE POLICY "Posts are viewable by everyone" ON public.posts FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can create posts" ON public.posts;
CREATE POLICY "Users can create posts" ON public.posts FOR INSERT WITH CHECK (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Users can update own posts" ON public.posts;
CREATE POLICY "Users can update own posts" ON public.posts FOR UPDATE USING (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Users can delete own posts" ON public.posts;
CREATE POLICY "Users can delete own posts" ON public.posts FOR DELETE USING (auth.uid() = profile_id);

-- ============================================================================
-- 10. TABELA DE CURTIDAS (LIKES)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(profile_id, post_id)
);

ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Likes are viewable by everyone" ON public.likes;
CREATE POLICY "Likes are viewable by everyone" ON public.likes FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can like posts" ON public.likes;
CREATE POLICY "Users can like posts" ON public.likes FOR INSERT WITH CHECK (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Users can unlike posts" ON public.likes;
CREATE POLICY "Users can unlike posts" ON public.likes FOR DELETE USING (auth.uid() = profile_id);

-- ============================================================================
-- 11. TABELA DE COMENTÁRIOS (COMMENTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Comments are viewable by everyone" ON public.comments;
CREATE POLICY "Comments are viewable by everyone" ON public.comments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can comment" ON public.comments;
CREATE POLICY "Users can comment" ON public.comments FOR INSERT WITH CHECK (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Users can delete own comments" ON public.comments;
CREATE POLICY "Users can delete own comments" ON public.comments FOR DELETE USING (auth.uid() = profile_id);

-- ============================================================================
-- 12. TABELA DE SEGUIDORES (FOLLOWS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.follows (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  follower_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  following_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(follower_id, following_id)
);

ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Follows are viewable by everyone" ON public.follows;
CREATE POLICY "Follows are viewable by everyone" ON public.follows FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can follow" ON public.follows;
CREATE POLICY "Users can follow" ON public.follows FOR INSERT WITH CHECK (auth.uid() = follower_id);

DROP POLICY IF EXISTS "Users can unfollow" ON public.follows;
CREATE POLICY "Users can unfollow" ON public.follows FOR DELETE USING (auth.uid() = follower_id);

-- ============================================================================
-- 13. STORAGE BUCKETS (Inserir via SQL)
-- ============================================================================

-- Bucket para avatares de perfil
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- Bucket para posts/images do feed
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('posts', 'posts', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'video/mp4'])
ON CONFLICT (id) DO NOTHING;

-- Bucket para capas de missionários
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('covers', 'covers', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- Políticas de Storage: Leitura pública para buckets públicos
DROP POLICY IF EXISTS "Public read avatars" ON storage.objects;
CREATE POLICY "Public read avatars" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Public read posts" ON storage.objects;
CREATE POLICY "Public read posts" ON storage.objects FOR SELECT USING (bucket_id = 'posts');

DROP POLICY IF EXISTS "Public read covers" ON storage.objects;
CREATE POLICY "Public read covers" ON storage.objects FOR SELECT USING (bucket_id = 'covers');

-- Políticas de Storage: Upload autenticado
DROP POLICY IF EXISTS "Auth users upload avatars" ON storage.objects;
CREATE POLICY "Auth users upload avatars" ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Auth users upload posts" ON storage.objects;
CREATE POLICY "Auth users upload posts" ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'posts' AND auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Auth users upload covers" ON storage.objects;
CREATE POLICY "Auth users upload covers" ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'covers' AND auth.uid() IS NOT NULL);

-- Políticas de Storage: Delete próprio
DROP POLICY IF EXISTS "Auth users delete own avatars" ON storage.objects;
CREATE POLICY "Auth users delete own avatars" ON storage.objects FOR DELETE 
USING (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Auth users delete own posts" ON storage.objects;
CREATE POLICY "Auth users delete own posts" ON storage.objects FOR DELETE 
USING (bucket_id = 'posts' AND auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Auth users delete own covers" ON storage.objects;
CREATE POLICY "Auth users delete own covers" ON storage.objects FOR DELETE 
USING (bucket_id = 'covers' AND auth.uid() IS NOT NULL);

-- ============================================================================
-- 13.5. TABELA DE PEDIDOS DE ORAÇÃO (PRAYER_REQUESTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.prayer_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  is_praise BOOLEAN DEFAULT false,
  is_answered BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.prayer_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Prayer requests are viewable by everyone" ON public.prayer_requests;
CREATE POLICY "Prayer requests are viewable by everyone" ON public.prayer_requests FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can create prayer requests" ON public.prayer_requests;
CREATE POLICY "Users can create prayer requests" ON public.prayer_requests FOR INSERT WITH CHECK (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Users can delete own prayer requests" ON public.prayer_requests;
CREATE POLICY "Users can delete own prayer requests" ON public.prayer_requests FOR DELETE USING (auth.uid() = profile_id);

-- Rastreamento de quem orou
CREATE TABLE IF NOT EXISTS public.prayer_participants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  prayer_id UUID REFERENCES public.prayer_requests(id) ON DELETE CASCADE NOT NULL,
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(prayer_id, profile_id)
);

ALTER TABLE public.prayer_participants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Prayer participants viewable by everyone" ON public.prayer_participants;
CREATE POLICY "Prayer participants viewable by everyone" ON public.prayer_participants FOR SELECT USING (true);

DROP POLICY IF EXISTS "Auth users can mark as prayed" ON public.prayer_participants;
CREATE POLICY "Auth users can mark as prayed" ON public.prayer_participants FOR INSERT WITH CHECK (auth.uid() = profile_id);

-- ============================================================================
-- 14. TRIGGER: CRIAR REGISTRO DE DOADOR AUTOMÁTICO
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_donor()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'donor' THEN
    INSERT INTO public.donors (profile_id, name, avatar_url, total_donated, supported_missions_count, lives_impacted_count)
    VALUES (NEW.id, NEW.full_name, NEW.avatar_url, 0, 0, 0)
    ON CONFLICT (profile_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_profile_created_donor ON public.profiles;
CREATE TRIGGER on_profile_created_donor
  AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_donor();

-- ============================================================================
-- 15. STORED PROCEDURES
-- ============================================================================

-- Incrementa o suporte atual do missionário
CREATE OR REPLACE FUNCTION public.increment_missionary_support(m_id UUID, amt DOUBLE PRECISION)
RETURNS void AS $$
BEGIN
  UPDATE public.missionaries
  SET current_support = current_support + amt, updated_at = CURRENT_TIMESTAMP
  WHERE id = m_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Atualiza stats do doador após doação bem-sucedida
CREATE OR REPLACE FUNCTION public.update_donor_stats(d_id UUID, amt DOUBLE PRECISION)
RETURNS void AS $$
BEGIN
  UPDATE public.donors
  SET total_donated = total_donated + amt,
      supported_missions_count = (
        SELECT COUNT(DISTINCT missionary_id) FROM public.donations WHERE donor_id = d_id AND status = 'completed'
      ),
      lives_impacted_count = lives_impacted_count + CEILING(amt / 50)::INT,
      updated_at = CURRENT_TIMESTAMP
  WHERE id = d_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Verifica se um usuário segue outro
CREATE OR REPLACE FUNCTION public.is_following(follower UUID, following UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.follows WHERE follower_id = follower AND following_id = following
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Conta seguidores de um perfil
CREATE OR REPLACE FUNCTION public.follower_count(profile_id UUID)
RETURNS INT AS $$
BEGIN
  RETURN (SELECT COUNT(*) FROM public.follows WHERE following_id = profile_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Conta quantos perfis um usuário segue
CREATE OR REPLACE FUNCTION public.following_count(profile_id UUID)
RETURNS INT AS $$
BEGIN
  RETURN (SELECT COUNT(*) FROM public.follows WHERE follower_id = profile_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 16. ÍNDICES DE PERFORMANCE
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_missionaries_slug ON public.missionaries(slug);
CREATE INDEX IF NOT EXISTS idx_missionaries_country ON public.missionaries(country_code);
CREATE INDEX IF NOT EXISTS idx_missionaries_category ON public.missionaries(category);
CREATE INDEX IF NOT EXISTS idx_missionaries_profile ON public.missionaries(profile_id);
CREATE INDEX IF NOT EXISTS idx_donations_missionary ON public.donations(missionary_id);
CREATE INDEX IF NOT EXISTS idx_donations_donor ON public.donations(donor_id);
CREATE INDEX IF NOT EXISTS idx_projects_missionary ON public.projects(missionary_id);
CREATE INDEX IF NOT EXISTS idx_posts_profile ON public.posts(profile_id);
CREATE INDEX IF NOT EXISTS idx_posts_created ON public.posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_likes_post ON public.likes(post_id);
CREATE INDEX IF NOT EXISTS idx_likes_profile ON public.likes(profile_id);
CREATE INDEX IF NOT EXISTS idx_comments_post ON public.comments(post_id);
CREATE INDEX IF NOT EXISTS idx_follows_follower ON public.follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON public.follows(following_id);
CREATE INDEX IF NOT EXISTS idx_donors_profile ON public.donors(profile_id);
CREATE INDEX IF NOT EXISTS idx_prayer_requests_profile ON public.prayer_requests(profile_id);
CREATE INDEX IF NOT EXISTS idx_prayer_requests_created ON public.prayer_requests(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_prayer_participants_prayer ON public.prayer_participants(prayer_id);
