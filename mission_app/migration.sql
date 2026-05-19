-- ==============================================================================
-- Go4Me MissionApp — MIGRATION COMPLETA (v2 - tabelas primeiro, policies depois)
-- Execute este arquivo no SQL Editor do Supabase (projeto novo e vazio).
-- ==============================================================================

-- ==============================================================================
-- ETAPA 1: ENUMS
-- ==============================================================================
DO $$ BEGIN CREATE TYPE user_role AS ENUM ('donor', 'missionary', 'admin'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ==============================================================================
-- ETAPA 2: TODAS AS TABELAS (criar primeiro, sem policies ainda)
-- ==============================================================================

-- 2.1 profiles (core, vinculado ao auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT,
  email       TEXT UNIQUE NOT NULL,
  avatar_url  TEXT,
  role        user_role DEFAULT 'donor',
  country     TEXT,
  slug        TEXT UNIQUE,
  updated_at  TIMESTAMPTZ DEFAULT now(),
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- 2.2 missionaries
CREATE TABLE IF NOT EXISTS public.missionaries (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id        UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  slug              TEXT UNIQUE NOT NULL,
  location          TEXT,
  latitude          DOUBLE PRECISION DEFAULT 0,
  longitude         DOUBLE PRECISION DEFAULT 0,
  years_in_field    TEXT,
  lives_impacted    TEXT,
  headline          TEXT,
  full_story        TEXT,
  current_support   DOUBLE PRECISION DEFAULT 0,
  goal_support      DOUBLE PRECISION DEFAULT 0,
  profile_image_url TEXT,
  cover_image_url   TEXT,
  nationality       TEXT,
  nationality_code  TEXT,
  country_code      TEXT,
  category          TEXT DEFAULT 'church_planting',
  is_public         BOOLEAN DEFAULT true,
  created_at        TIMESTAMPTZ DEFAULT now(),
  updated_at        TIMESTAMPTZ DEFAULT now()
);

-- 2.3 donors
CREATE TABLE IF NOT EXISTS public.donors (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id               UUID UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  name                     TEXT,
  avatar_url               TEXT,
  total_donated            DOUBLE PRECISION DEFAULT 0,
  supported_missions_count INT DEFAULT 0,
  lives_impacted_count     INT DEFAULT 0,
  created_at               TIMESTAMPTZ DEFAULT now(),
  updated_at               TIMESTAMPTZ DEFAULT now()
);

-- 2.4 projects
CREATE TABLE IF NOT EXISTS public.projects (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  missionary_id UUID REFERENCES public.missionaries(id) ON DELETE CASCADE NOT NULL,
  title         TEXT NOT NULL,
  description   TEXT,
  goal          DOUBLE PRECISION DEFAULT 0,
  current       DOUBLE PRECISION DEFAULT 0,
  image_url     TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- 2.5 donations (depende de donors, missionaries, projects)
CREATE TABLE IF NOT EXISTS public.donations (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id                 UUID REFERENCES public.donors(id) ON DELETE CASCADE NOT NULL,
  missionary_id            UUID REFERENCES public.missionaries(id) ON DELETE CASCADE NOT NULL,
  project_id               UUID REFERENCES public.projects(id) ON DELETE SET NULL,
  amount                   DOUBLE PRECISION NOT NULL,
  currency                 TEXT DEFAULT 'BRL',
  is_recurring             BOOLEAN DEFAULT false,
  is_anonymous             BOOLEAN DEFAULT false,
  stripe_payment_intent_id TEXT,
  status                   TEXT DEFAULT 'pending',
  created_at               TIMESTAMPTZ DEFAULT now()
);

-- 2.6 past_locations
CREATE TABLE IF NOT EXISTS public.past_locations (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  missionary_id UUID REFERENCES public.missionaries(id) ON DELETE CASCADE NOT NULL,
  city          TEXT,
  country       TEXT,
  country_code  TEXT,
  period        TEXT,
  description   TEXT,
  created_at    TIMESTAMPTZ DEFAULT now()
);

-- 2.7 posts
CREATE TABLE IF NOT EXISTS public.posts (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content    TEXT,
  media_urls JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2.8 likes
CREATE TABLE IF NOT EXISTS public.likes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  post_id    UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(profile_id, post_id)
);

-- 2.9 comments
CREATE TABLE IF NOT EXISTS public.comments (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  post_id    UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  content    TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2.10 follows
CREATE TABLE IF NOT EXISTS public.follows (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id  UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  following_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  created_at   TIMESTAMPTZ DEFAULT now(),
  UNIQUE(follower_id, following_id)
);

-- 2.11 prayer_requests
CREATE TABLE IF NOT EXISTS public.prayer_requests (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content     TEXT NOT NULL,
  is_praise   BOOLEAN DEFAULT false,
  is_answered BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- 2.12 prayer_participants
CREATE TABLE IF NOT EXISTS public.prayer_participants (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prayer_id  UUID REFERENCES public.prayer_requests(id) ON DELETE CASCADE NOT NULL,
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(prayer_id, profile_id)
);

-- ==============================================================================
-- ETAPA 3: ROW LEVEL SECURITY (ativar em todas as tabelas)
-- ==============================================================================
ALTER TABLE public.profiles            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.missionaries        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donors              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donations           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.past_locations      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prayer_requests     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prayer_participants ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- ETAPA 4: TODAS AS POLICIES
-- ==============================================================================

-- profiles
CREATE POLICY "Profiles: owner read"   ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Profiles: public read"  ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Profiles: owner update" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- missionaries
CREATE POLICY "Missionaries: public read"        ON public.missionaries FOR SELECT USING (is_public OR auth.uid() = profile_id);
CREATE POLICY "Missionaries: owner update"       ON public.missionaries FOR UPDATE USING (auth.uid() = profile_id);
CREATE POLICY "Missionaries: missionary insert"  ON public.missionaries FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('missionary','admin')));

-- donors
CREATE POLICY "Donors: owner read"      ON public.donors FOR SELECT USING (auth.uid() = profile_id);
CREATE POLICY "Donors: missionary read" ON public.donors FOR SELECT USING (EXISTS (SELECT 1 FROM public.donations d JOIN public.missionaries m ON d.missionary_id = m.id WHERE d.donor_id = donors.id AND m.profile_id = auth.uid()));
CREATE POLICY "Donors: owner update"    ON public.donors FOR UPDATE USING (auth.uid() = profile_id);

-- projects
CREATE POLICY "Projects: public read" ON public.projects FOR SELECT USING (true);
CREATE POLICY "Projects: owner all"   ON public.projects FOR ALL USING (EXISTS (SELECT 1 FROM public.missionaries WHERE id = projects.missionary_id AND profile_id = auth.uid()));

-- donations
CREATE POLICY "Donations: donor read"      ON public.donations FOR SELECT USING (EXISTS (SELECT 1 FROM public.donors WHERE id = donations.donor_id AND profile_id = auth.uid()));
CREATE POLICY "Donations: missionary read" ON public.donations FOR SELECT USING (EXISTS (SELECT 1 FROM public.missionaries WHERE id = donations.missionary_id AND profile_id = auth.uid()));
CREATE POLICY "Donations: auth insert"     ON public.donations FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- past_locations
CREATE POLICY "PastLocations: public read" ON public.past_locations FOR SELECT USING (true);
CREATE POLICY "PastLocations: owner all"   ON public.past_locations FOR ALL USING (EXISTS (SELECT 1 FROM public.missionaries WHERE id = past_locations.missionary_id AND profile_id = auth.uid()));

-- posts
CREATE POLICY "Posts: public read"  ON public.posts FOR SELECT USING (true);
CREATE POLICY "Posts: owner insert" ON public.posts FOR INSERT WITH CHECK (auth.uid() = profile_id);
CREATE POLICY "Posts: owner update" ON public.posts FOR UPDATE USING (auth.uid() = profile_id);
CREATE POLICY "Posts: owner delete" ON public.posts FOR DELETE USING (auth.uid() = profile_id);

-- likes
CREATE POLICY "Likes: public read"  ON public.likes FOR SELECT USING (true);
CREATE POLICY "Likes: owner insert" ON public.likes FOR INSERT WITH CHECK (auth.uid() = profile_id);
CREATE POLICY "Likes: owner delete" ON public.likes FOR DELETE USING (auth.uid() = profile_id);

-- comments
CREATE POLICY "Comments: public read"  ON public.comments FOR SELECT USING (true);
CREATE POLICY "Comments: owner insert" ON public.comments FOR INSERT WITH CHECK (auth.uid() = profile_id);
CREATE POLICY "Comments: owner delete" ON public.comments FOR DELETE USING (auth.uid() = profile_id);

-- follows
CREATE POLICY "Follows: public read"  ON public.follows FOR SELECT USING (true);
CREATE POLICY "Follows: owner insert" ON public.follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Follows: owner delete" ON public.follows FOR DELETE USING (auth.uid() = follower_id);

-- prayer_requests
CREATE POLICY "PrayerRequests: public read"  ON public.prayer_requests FOR SELECT USING (true);
CREATE POLICY "PrayerRequests: owner insert" ON public.prayer_requests FOR INSERT WITH CHECK (auth.uid() = profile_id);
CREATE POLICY "PrayerRequests: owner delete" ON public.prayer_requests FOR DELETE USING (auth.uid() = profile_id);

-- prayer_participants
CREATE POLICY "PrayerParticipants: public read" ON public.prayer_participants FOR SELECT USING (true);
CREATE POLICY "PrayerParticipants: auth insert" ON public.prayer_participants FOR INSERT WITH CHECK (auth.uid() = profile_id);

-- ==============================================================================
-- ETAPA 5: TRIGGERS e STORED PROCEDURES
-- ==============================================================================

-- Trigger: criar perfil automaticamente no signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  final_slug TEXT;
  base_slug  TEXT;
  counter    INT := 0;
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
  VALUES (new.id, new.raw_user_meta_data->>'full_name', new.email, new.raw_user_meta_data->>'avatar_url',
    COALESCE(NULLIF(new.raw_user_meta_data->>'role','')::user_role, 'donor'::user_role),
    NULLIF(new.raw_user_meta_data->>'country',''), final_slug)
  ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, email = EXCLUDED.email, updated_at = now();
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Trigger: criar registro donor ao criar perfil com role=donor
CREATE OR REPLACE FUNCTION public.handle_new_donor()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'donor' THEN
    INSERT INTO public.donors (profile_id, name, avatar_url) VALUES (NEW.id, NEW.full_name, NEW.avatar_url) ON CONFLICT (profile_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_profile_created_donor ON public.profiles;
CREATE TRIGGER on_profile_created_donor AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE PROCEDURE public.handle_new_donor();

-- Procedure: incrementar suporte do missionário
CREATE OR REPLACE FUNCTION public.increment_missionary_support(m_id UUID, amt DOUBLE PRECISION)
RETURNS void AS $$
BEGIN
  UPDATE public.missionaries SET current_support = current_support + amt, updated_at = now() WHERE id = m_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Procedure: atualizar stats do doador
CREATE OR REPLACE FUNCTION public.update_donor_stats(d_id UUID, amt DOUBLE PRECISION)
RETURNS void AS $$
BEGIN
  UPDATE public.donors SET
    total_donated = total_donated + amt,
    supported_missions_count = (SELECT COUNT(DISTINCT missionary_id) FROM public.donations WHERE donor_id = d_id AND status = 'completed'),
    lives_impacted_count = lives_impacted_count + CEILING(amt / 50)::INT,
    updated_at = now()
  WHERE id = d_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- ETAPA 6: STORAGE BUCKETS E POLICIES
-- ==============================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg','image/png','image/webp'])
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('posts', 'posts', true, 10485760, ARRAY['image/jpeg','image/png','image/webp','video/mp4'])
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('covers', 'covers', true, 10485760, ARRAY['image/jpeg','image/png','image/webp'])
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Storage: public read avatars" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "Storage: public read posts"   ON storage.objects FOR SELECT USING (bucket_id = 'posts');
CREATE POLICY "Storage: public read covers"  ON storage.objects FOR SELECT USING (bucket_id = 'covers');
CREATE POLICY "Storage: auth upload avatars" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);
CREATE POLICY "Storage: auth upload posts"   ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'posts' AND auth.uid() IS NOT NULL);
CREATE POLICY "Storage: auth upload covers"  ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'covers' AND auth.uid() IS NOT NULL);
CREATE POLICY "Storage: auth delete avatars" ON storage.objects FOR DELETE USING (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);
CREATE POLICY "Storage: auth delete posts"   ON storage.objects FOR DELETE USING (bucket_id = 'posts' AND auth.uid() IS NOT NULL);
CREATE POLICY "Storage: auth delete covers"  ON storage.objects FOR DELETE USING (bucket_id = 'covers' AND auth.uid() IS NOT NULL);

-- ==============================================================================
-- ETAPA 7: ÍNDICES
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_profiles_role              ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_slug              ON public.profiles(slug);
CREATE INDEX IF NOT EXISTS idx_missionaries_slug          ON public.missionaries(slug);
CREATE INDEX IF NOT EXISTS idx_missionaries_country       ON public.missionaries(country_code);
CREATE INDEX IF NOT EXISTS idx_missionaries_category      ON public.missionaries(category);
CREATE INDEX IF NOT EXISTS idx_missionaries_profile       ON public.missionaries(profile_id);
CREATE INDEX IF NOT EXISTS idx_donations_missionary       ON public.donations(missionary_id);
CREATE INDEX IF NOT EXISTS idx_donations_donor            ON public.donations(donor_id);
CREATE INDEX IF NOT EXISTS idx_donations_status           ON public.donations(status);
CREATE INDEX IF NOT EXISTS idx_projects_missionary        ON public.projects(missionary_id);
CREATE INDEX IF NOT EXISTS idx_posts_profile              ON public.posts(profile_id);
CREATE INDEX IF NOT EXISTS idx_posts_created              ON public.posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_likes_post                 ON public.likes(post_id);
CREATE INDEX IF NOT EXISTS idx_likes_profile              ON public.likes(profile_id);
CREATE INDEX IF NOT EXISTS idx_comments_post              ON public.comments(post_id);
CREATE INDEX IF NOT EXISTS idx_follows_follower           ON public.follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following          ON public.follows(following_id);
CREATE INDEX IF NOT EXISTS idx_donors_profile             ON public.donors(profile_id);
CREATE INDEX IF NOT EXISTS idx_prayer_requests_profile    ON public.prayer_requests(profile_id);
CREATE INDEX IF NOT EXISTS idx_prayer_requests_created    ON public.prayer_requests(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_prayer_participants        ON public.prayer_participants(prayer_id);

-- ==============================================================================
-- ETAPA 8: SEED DATA
-- ==============================================================================
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000001', 'João Paulo', 'joaopaulo', 'Santiago, Chile', -33.4489, -70.6693, '5 Anos', '1.200+', 'Levando esperança aos pés das montanhas.', 'Trabalhamos com educação infantil e apoio social em áreas rurais do Chile.', 3750, 5000, 'https://randomuser.me/api/portraits/men/41.jpg', 'https://images.unsplash.com/photo-1542359498-4f8a84e6d420', 'Brasil', 'br', 'cl', 'education');

INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000002', 'Sarah Jenkins', 'sarah', 'Maputo, Moçambique', -25.9692, 32.5732, '2 Anos', '300+', 'Construindo poços, levando vida.', 'Perfuração de poços artesianos em aldeias remotas de Moçambique.', 1200, 6000, 'https://randomuser.me/api/portraits/women/65.jpg', 'https://images.unsplash.com/photo-1544985338-782a20987320', 'EUA', 'us', 'mz', 'water');

INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000003', 'Kenji Sato', 'kenji', 'Osaka, Japão', 34.6937, 135.5023, '8 Anos', '500+', 'Plantando igrejas no coração do Japão.', 'Discipulado urbano e plantação de igrejas domésticas no Japão.', 4500, 8000, 'https://randomuser.me/api/portraits/men/45.jpg', 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e', 'Japão', 'jp', 'jp', 'church_planting');

INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000004', 'Ana & Carlos', 'anacarlos', 'Manaus, Brasil', -3.1190, -60.0217, '12 Anos', '3.000+', 'Navegando pelos rios para salvar vidas.', 'Barco médico atendendo comunidades ribeirinhas da Amazônia.', 7200, 7000, 'https://randomuser.me/api/portraits/lego/1.jpg', 'https://images.unsplash.com/photo-1596395817838-2dd476e3381a', 'Brasil', 'br', 'br', 'health');

INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000005', 'David Miller', 'david', 'Berlim, Alemanha', 52.5200, 13.4050, '3 Anos', '150+', 'Acolhendo refugiados com amor.', 'Aulas de idioma, integração e apoio espiritual em campos de refugiados.', 1800, 5000, 'https://randomuser.me/api/portraits/men/12.jpg', 'https://images.unsplash.com/photo-1599946347371-68eb71b16afc', 'EUA', 'us', 'de', 'humanitarian');

INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category, is_public)
VALUES ('10000000-0000-0000-0000-000000000006', 'Li Wei', 'liwei', 'Shanghai, China', 31.2304, 121.4737, '6 Anos', 'Unknown', 'Treinando líderes locais.', 'Treinamento teológico de líderes locais para fortalecer a igreja.', 3200, 4000, 'https://randomuser.me/api/portraits/women/33.jpg', 'https://images.unsplash.com/photo-1548266652-99cf27701ced', 'China', 'cn', 'cn', 'discipleship', false);

INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000007', 'Pr. Emmanuel', 'emmanuel', 'Lagos, Nigéria', 6.5244, 3.3792, '15 Anos', '5.000+', 'Evangelismo em massa e cruzadas.', 'Cruzadas evangelísticas e plantação de igrejas em áreas rurais.', 2500, 3000, 'https://randomuser.me/api/portraits/men/55.jpg', 'https://images.unsplash.com/photo-1618255955776-857502c28656', 'Nigéria', 'ng', 'ng', 'church_planting');

INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000008', 'Elena Ivanov', 'elena', 'Kiev, Ucrânia', 50.4501, 30.5234, '1 Ano', '800+', 'Apoio humanitário em tempos de crise.', 'Distribuição de alimentos, roupas e Bíblias para famílias deslocadas.', 4800, 6000, 'https://randomuser.me/api/portraits/women/48.jpg', 'https://images.unsplash.com/photo-1560743641-729481156829', 'Ucrânia', 'ua', 'ua', 'humanitarian');

INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000009', 'Raj Patel', 'raj', 'Mumbai, Índia', 19.0760, 72.8777, '10 Anos', '2.500+', 'Resgatando crianças das ruas.', 'Orfanato e escola para crianças em situação de rua nos subúrbios de Mumbai.', 1500, 4500, 'https://randomuser.me/api/portraits/men/22.jpg', 'https://images.unsplash.com/photo-1566552881560-0be862a7c445', 'Índia', 'in', 'in', 'orphans');

INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000010', 'Carmen R.', 'carmen', 'Cusco, Peru', -13.5319, -71.9675, '4 Anos', '400+', 'Traduzindo a Bíblia para o Quechua.', 'Tradução bíblica e alfabetização nas montanhas dos Andes.', 2200, 3500, 'https://randomuser.me/api/portraits/women/12.jpg', 'https://images.unsplash.com/photo-1587595431973-160d0d94add1', 'Peru', 'pe', 'pe', 'bible_translation');

INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000011', 'John Doe', 'john', 'Nova Iorque, EUA', 40.7128, -74.0060, '3 Anos', '200+', 'Missão urbana em meio aos arranha-céus.', 'Trabalho com moradores de rua e viciados no Bronx.', 5500, 8000, 'https://randomuser.me/api/portraits/men/33.jpg', 'https://images.unsplash.com/photo-1496442226666-8d4a0e62e6e9', 'EUA', 'us', 'us', 'street_outreach');

INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category, is_public)
VALUES ('10000000-0000-0000-0000-000000000012', 'Ahmed K.', 'ahmed', 'Cairo, Egito', 30.0444, 31.2357, '7 Anos', 'Unknown', 'Compartilhando a luz no deserto.', 'Discipulado um a um e pequenos grupos em cafés e universidades.', 2800, 3000, 'https://randomuser.me/api/portraits/men/78.jpg', 'https://images.unsplash.com/photo-1572252009286-268acec5ca0a', 'Egito', 'eg', 'eg', 'urban', false);

-- Projetos
INSERT INTO public.projects (missionary_id, title, description, goal, current, image_url) VALUES
('10000000-0000-0000-0000-000000000001', 'Reforma do Telhado', 'O telhado da creche precisa de reparos urgentes antes do inverno.', 15000, 4500, 'https://picsum.photos/seed/roof_project/800/600'),
('10000000-0000-0000-0000-000000000001', 'Material Escolar 2026', 'Kits completos para 50 crianças da comunidade.', 2500, 2500, 'https://picsum.photos/seed/school_supplies/800/600'),
('10000000-0000-0000-0000-000000000002', 'Novo Poço Artesiano', 'Perfuração de poço na aldeia de Marracuene.', 25000, 8000, 'https://picsum.photos/seed/water_well_project/800/600');

-- Localizações passadas
INSERT INTO public.past_locations (missionary_id, city, country, country_code, period, description) VALUES
('10000000-0000-0000-0000-000000000001', 'Port-au-Prince', 'Haiti', 'ht', '2015 - 2017', 'Reconstrução pós-terremoto e distribuição de alimentos.'),
('10000000-0000-0000-0000-000000000001', 'Luanda', 'Angola', 'ao', '2018 - 2019', 'Grupos de estudo bíblico e treinamento de professores.');

-- ==============================================================================
-- FIM DA MIGRATION
-- ==============================================================================
