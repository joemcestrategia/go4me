-- ################################################################################
-- # SEED DATA: 12 MISSIONÁRIOS DE EXEMPLO (COM CATEGORIAS)
-- ################################################################################

-- 1. João Paulo (Chile) - education
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000001', 'João Paulo', 'joaopaulo', 'Santiago, Chile', -33.4489, -70.6693, '5 Anos', '1.200+', 'Levando esperança aos pés das montanhas.', 'Meu chamado começou em 2019, quando visitei as comunidades rurais do Chile. Hoje, trabalhamos com educação infantil e apoio social.', 3750, 5000, 'https://randomuser.me/api/portraits/men/41.jpg', 'https://images.unsplash.com/photo-1542359498-4f8a84e6d420', 'Brasil', 'br', 'cl', 'education');

-- 2. Sarah Jenkins (Moçambique) - water
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000002', 'Sarah Jenkins', 'sarah', 'Maputo, Moçambique', -25.9692, 32.5732, '2 Anos', '300+', 'Construindo poços, levando vida.', 'Trabalhamos na perfuração de poços artesianos em aldeias remotas de Moçambique.', 1200, 6000, 'https://randomuser.me/api/portraits/women/65.jpg', 'https://images.unsplash.com/photo-1544985338-782a20987320', 'EUA', 'us', 'mz', 'water');

-- 3. Kenji Sato (Japão) - church_planting
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000003', 'Kenji Sato', 'kenji', 'Osaka, Japão', 34.6937, 135.5023, '8 Anos', '500+', 'Plantando igrejas no coração do Japão.', 'O Japão é um dos países menos alcançados. Nosso foco é discipulado urbano e plantação de igrejas.', 4500, 8000, 'https://randomuser.me/api/portraits/men/45.jpg', 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e', 'Japão', 'jp', 'jp', 'church_planting');

-- 4. Ana & Carlos (Brasil) - health
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000004', 'Ana & Carlos', 'anacarlos', 'Manaus, Brasil', -3.1190, -60.0217, '12 Anos', '3.000+', 'Navegando pelos rios para salvar vidas.', 'Utilizamos nosso barco médico Esperança para levar atendimento médico às comunidades ribeirinhas.', 7200, 7000, 'https://randomuser.me/api/portraits/lego/1.jpg', 'https://images.unsplash.com/photo-1596395817838-2dd476e3381a', 'Brasil', 'br', 'br', 'health');

-- 5. David Miller (Alemanha) - humanitarian
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000005', 'David Miller', 'david', 'Berlim, Alemanha', 52.5200, 13.4050, '3 Anos', '150+', 'Acolhendo refugiados com amor.', 'Trabalho em campos de refugiados na Europa, oferecendo aulas de idioma e apoio espiritual.', 1800, 5000, 'https://randomuser.me/api/portraits/men/12.jpg', 'https://images.unsplash.com/photo-1599946347371-68eb71b16afc', 'EUA', 'us', 'de', 'humanitarian');

-- 6. Li Wei (China) - discipleship
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category, is_public)
VALUES ('10000000-0000-0000-0000-000000000006', 'Li Wei', 'liwei', 'Shanghai, China', 31.2304, 121.4737, '6 Anos', 'Unknown', 'Treinando líderes locais.', 'Focamos no treinamento teológico de líderes locais.', 3200, 4000, 'https://randomuser.me/api/portraits/women/33.jpg', 'https://images.unsplash.com/photo-1548266652-99cf27701ced', 'China', 'cn', 'cn', 'discipleship', false);

-- 7. Pr. Emmanuel (Nigéria) - church_planting
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000007', 'Pr. Emmanuel', 'emmanuel', 'Lagos, Nigéria', 6.5244, 3.3792, '15 Anos', '5.000+', 'Evangelismo em massa.', 'Realizamos grandes cruzadas evangelísticas na Nigéria.', 2500, 3000, 'https://randomuser.me/api/portraits/men/55.jpg', 'https://images.unsplash.com/photo-1618255955776-857502c28656', 'Nigéria', 'ng', 'ng', 'church_planting');

-- 8. Elena Ivanov (Ucrânia) - humanitarian
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000008', 'Elena Ivanov', 'elena', 'Kiev, Ucrânia', 50.4501, 30.5234, '1 Ano', '800+', 'Apoio humanitário em tempos de crise.', 'Distribuímos alimentos, roupas e Bíblias para famílias deslocadas pela guerra.', 4800, 6000, 'https://randomuser.me/api/portraits/women/48.jpg', 'https://images.unsplash.com/photo-1560743641-729481156829', 'Ucrânia', 'ua', 'ua', 'humanitarian');

-- 9. Raj Patel (Índia) - orphans
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000009', 'Raj Patel', 'raj', 'Mumbai, Índia', 19.0760, 72.8777, '10 Anos', '2.500+', 'Resgatando crianças das ruas.', 'Mantemos um orfanato e escola para crianças em situação de rua.', 1500, 4500, 'https://randomuser.me/api/portraits/men/22.jpg', 'https://images.unsplash.com/photo-1566552881560-0be862a7c445', 'Índia', 'in', 'in', 'orphans');

-- 10. Carmen R. (Peru) - bible_translation
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000010', 'Carmen R.', 'carmen', 'Cusco, Peru', -13.5319, -71.9675, '4 Anos', '400+', 'Traduzindo a Bíblia para o Quechua.', 'Tradução bíblica e alfabetização nas montanhas dos Andes.', 2200, 3500, 'https://randomuser.me/api/portraits/women/12.jpg', 'https://images.unsplash.com/photo-1587595431973-160d0d94add1', 'Peru', 'pe', 'pe', 'bible_translation');

-- 11. John Doe (EUA) - street_outreach
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category)
VALUES ('10000000-0000-0000-0000-000000000011', 'John Doe', 'john', 'Nova Iorque, EUA', 40.7128, -74.0060, '3 Anos', '200+', 'Missão urbana em meio aos arranha-céus.', 'Trabalhamos com moradores de rua e viciados no Bronx.', 5500, 8000, 'https://randomuser.me/api/portraits/men/33.jpg', 'https://images.unsplash.com/photo-1496442226666-8d4a0e62e6e9', 'EUA', 'us', 'us', 'street_outreach');

-- 12. Ahmed K. (Egito) - urban
INSERT INTO public.missionaries (id, name, slug, location, latitude, longitude, years_in_field, lives_impacted, headline, full_story, current_support, goal_support, profile_image_url, cover_image_url, nationality, nationality_code, country_code, category, is_public)
VALUES ('10000000-0000-0000-0000-000000000012', 'Ahmed K.', 'ahmed', 'Cairo, Egito', 30.0444, 31.2357, '7 Anos', 'Unknown', 'Compartilhando a luz no deserto.', 'Discipulado um a um em cafés e universidades.', 2800, 3000, 'https://randomuser.me/api/portraits/men/78.jpg', 'https://images.unsplash.com/photo-1572252009286-268acec5ca0a', 'Egito', 'eg', 'eg', 'urban', false);

-- Projetos
INSERT INTO public.projects (missionary_id, title, description, goal, current, image_url) VALUES
('10000000-0000-0000-0000-000000000001', 'Reforma do Telhado', 'O telhado da creche precisa de reparos urgentes antes do inverno.', 15000, 4500, 'https://picsum.photos/seed/roof_project/800/600'),
('10000000-0000-0000-0000-000000000001', 'Material Escolar 2026', 'Kits completos para 50 crianças da comunidade.', 2500, 2500, 'https://picsum.photos/seed/school_supplies/800/600'),
('10000000-0000-0000-0000-000000000002', 'Novo Poço Artesiano', 'Perfuração de poço na aldeia de Marracuene.', 25000, 8000, 'https://picsum.photos/seed/water_well_project/800/600');

-- Localizações passadas
INSERT INTO public.past_locations (missionary_id, city, country, country_code, period, description) VALUES
('10000000-0000-0000-0000-000000000001', 'Port-au-Prince', 'Haiti', 'ht', '2015 - 2017', 'Apoio na reconstrução após terremoto e distribuição de alimentos.'),
('10000000-0000-0000-0000-000000000001', 'Luanda', 'Angola', 'ao', '2018 - 2019', 'Liderança de grupos de estudo bíblico e treinamento de professores.');
