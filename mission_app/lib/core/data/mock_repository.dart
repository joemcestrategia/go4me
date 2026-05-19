import 'package:go4me/core/models/missionary.dart';

// MOCK REPOSITORY (Expanded)
class MockRepository {
  // Helper para imagens de capa automáticas baseadas no país
  static String _getCoverForLocation(String location) {
    // Extrai o país da string "Cidade, País"
    final country = location.split(',').last.trim();

    const Map<String, String> countryImages = {
      'Chile':
          'https://images.unsplash.com/photo-1542359498-4f8a84e6d420', // Montanhas/Andes
      'Moçambique':
          'https://images.unsplash.com/photo-1544985338-782a20987320', // Savana/África
      'Japão':
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e', // Osaka/Tóquio
      'Brasil':
          'https://images.unsplash.com/photo-1596395817838-2dd476e3381a', // Amazônia
      'Alemanha':
          'https://images.unsplash.com/photo-1599946347371-68eb71b16afc', // Berlim
      'China':
          'https://images.unsplash.com/photo-1548266652-99cf27701ced', // Shanghai
      'Nigéria':
          'https://images.unsplash.com/photo-1618255955776-857502c28656', // Lagos
      'Ucrânia':
          'https://images.unsplash.com/photo-1560743641-729481156829', // Kiev
      'Índia':
          'https://images.unsplash.com/photo-1566552881560-0be862a7c445', // Mumbai
      'Peru':
          'https://images.unsplash.com/photo-1587595431973-160d0d94add1', // Cusco
      'EUA':
          'https://images.unsplash.com/photo-1496442226666-8d4a0e62e6e9', // NYC
      'Egito':
          'https://images.unsplash.com/photo-1572252009286-268acec5ca0a', // Cairo
    };

    return countryImages[country] ??
        'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b'; // Fallback Travel
  }

  // 1. João Paulo (Americas - Active)
  static final MissionaryData joaoPaulo = MissionaryData(
    id: '1',
    name: 'João Paulo',
    slug: 'joaopaulo',
    location: 'Santiago, Chile',
    latitude: -33.4489,
    longitude: -70.6693,
    yearsInField: '5 Anos',
    livesImpacted: '1.200+',
    headline: 'Levando esperança aos pés das montanhas.',
    fullStory:
        'Meu chamado começou em 2019, quando visitei pela primeira vez as comunidades rurais do Chile. Hoje, trabalhamos com educação infantil e apoio social em áreas de difícil acesso.\n\nSua parceria permite que continuemos firmes nesta missão por mais um ano.\n\nPreciso de R\$ 5.000 mensais para manter o projeto ativo, cobrindo aluguel do espaço, materiais escolares e alimentação.',
    currentSupport: 3750,
    goalSupport: 5000,
    profileImageUrl:
        'https://cdn.pixabay.com/photo/2018/08/28/12/41/avatar-3637425_960_720.png',
    coverImageUrl: _getCoverForLocation('Santiago, Chile'),
    nationality: 'Brasil',
    nationalityCode: 'br',
    countryCode: 'cl',
    pastLocations: [
      PastLocation(
        city: 'Port-au-Prince',
        country: 'Haiti',
        countryCode: 'ht',
        period: '2015 - 2017',
        description:
            'Apoio na reconstrução de casas após o terremoto e distribuição de alimentos.',
      ),
      PastLocation(
        city: 'Luanda',
        country: 'Angola',
        countryCode: 'ao',
        period: '2018 - 2019',
        description:
            'Liderança de grupos de estudo bíblico e treinamento de professores locais.',
      ),
    ],
    recentDonors: [
      Donor(
        id: '1',
        name: 'Maria Souza',
        avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        amount: 50,
        timeAgo: 'há 2 horas',
      ),
      Donor(
        id: '2',
        name: 'Pedro Santos',
        avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
        amount: 100,
        timeAgo: 'há 5 horas',
      ),
    ],
    oneTimeProjects: [
      Project(
        id: 'p1',
        title: 'Reforma do Telhado',
        description:
            'O telhado da creche precisa de reparos urgentes antes do inverno.',
        goal: 15000,
        current: 4500,
        imageUrl:
            'https://picsum.photos/seed/roof_project/800/600', // Roof construction
      ),
      Project(
        id: 'p2',
        title: 'Material Escolar 2026',
        description: 'Kits completos para 50 crianças da comunidade.',
        goal: 2500,
        current: 2500, // Completed
        imageUrl:
            'https://picsum.photos/seed/school_supplies/800/600', // School supplies
      ),
    ],
  );

  // 2. Sarah Jenkins (Africa - Low Funding)
  static final MissionaryData sarahJenkins = MissionaryData(
    id: '2',
    name: 'Sarah Jenkins',
    slug: 'sarah',
    location: 'Maputo, Moçambique',
    latitude: -25.9692,
    longitude: 32.5732,
    yearsInField: '2 Anos',
    livesImpacted: '300+',
    headline: 'Construindo poços, levando vida.',
    fullStory:
        'Trabalhamos na perfuração de poços artesianos em aldeias remotas de Moçambique, levando água potável e a mensagem do Evangelho.',
    currentSupport: 1200,
    goalSupport: 6000,
    profileImageUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
    coverImageUrl: _getCoverForLocation('Maputo, Moçambique'),
    nationality: 'EUA',
    countryCode: 'us',
    oneTimeProjects: [
      Project(
        id: 'p3',
        title: 'Novo Poço Artesiano',
        description: 'Perfuração de poço na aldeia de Marracuene.',
        goal: 25000,
        current: 8000,
        imageUrl:
            'https://picsum.photos/seed/water_well_project/800/600', // Water well
      ),
    ],
  );

  // 3. Kenji Sato (Asia - Medium Funding)
  static final MissionaryData kenjiSato = MissionaryData(
    id: '3',
    name: 'Kenji Sato',
    slug: 'kenji',
    location: 'Osaka, Japão',
    latitude: 34.6937,
    longitude: 135.5023,
    yearsInField: '8 Anos',
    livesImpacted: '500+',
    headline: 'Plantando igrejas no coração do Japão.',
    fullStory:
        'O Japão é um dos países menos alcançados. Nosso foco é discipulado urbano e plantação de igrejas domésticas.',
    currentSupport: 4500,
    goalSupport: 8000,
    profileImageUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    coverImageUrl: _getCoverForLocation('Osaka, Japão'),
    nationality: 'Japão',
    countryCode: 'jp',
  );

  // 4. Ana & Carlos (Amazonia - Fully Funded)
  static final MissionaryData anaCarlos = MissionaryData(
    id: '4',
    name: 'Ana & Carlos',
    slug: 'anacarlos',
    location: 'Manaus, Brasil',
    latitude: -3.1190,
    longitude: -60.0217,
    yearsInField: '12 Anos',
    livesImpacted: '3.000+',
    headline: 'Navegando pelos rios para salvar vidas.',
    fullStory:
        'Utilizamos nosso barco médico "Esperança" para levar atendimento médico e odontológico às comunidades ribeirinhas da Amazônia.',
    currentSupport: 7200,
    goalSupport: 7000,
    profileImageUrl:
        'https://randomuser.me/api/portraits/lego/1.jpg', // Couple or generic
    coverImageUrl: _getCoverForLocation('Manaus, Brasil'),
    nationality: 'Brasil',
    countryCode: 'br',
  );

  // 5. David Miller (Europe - Urgent Need)
  static final MissionaryData davidMiller = MissionaryData(
    id: '5',
    name: 'David Miller',
    slug: 'david',
    location: 'Berlim, Alemanha',
    latitude: 52.5200,
    longitude: 13.4050,
    yearsInField: '3 Anos',
    livesImpacted: '150+',
    headline: 'Acolhendo refugiados com amor.',
    fullStory:
        'Trabalho em campos de refugiados na Europa, oferecendo aulas de idioma, integração cultural e apoio espiritual.',
    currentSupport: 1800,
    goalSupport: 5000,
    profileImageUrl: 'https://randomuser.me/api/portraits/men/12.jpg',
    coverImageUrl: _getCoverForLocation('Berlim, Alemanha'),
    nationality: 'EUA',
    countryCode: 'us',
  );

  // 6. Li Wei (Asia - China - Sensitive)
  static final MissionaryData liWei = MissionaryData(
    id: '6',
    name: 'Li Wei',
    slug: 'liwei',
    location: 'Shanghai, China',
    latitude: 31.2304,
    longitude: 121.4737,
    yearsInField: '6 Anos',
    livesImpacted: 'Unknown',
    headline: 'Treinando líderes locais.',
    fullStory:
        'Focamos no treinamento teológico de líderes locais para fortalecer a igreja subterrânea.',
    currentSupport: 3200,
    goalSupport: 4000,
    profileImageUrl: 'https://randomuser.me/api/portraits/women/33.jpg',
    coverImageUrl: _getCoverForLocation('Shanghai, China'),
    nationality: 'China',
    countryCode: 'cn',
    isPublic: false, // Private profile
  );

  // 7. Pastor Emmanuel (Africa - Nigeria)
  static final MissionaryData pastorEmmanuel = MissionaryData(
    id: '7',
    name: 'Pr. Emmanuel',
    slug: 'emmanuel',
    location: 'Lagos, Nigéria',
    latitude: 6.5244,
    longitude: 3.3792,
    yearsInField: '15 Anos',
    livesImpacted: '5.000+',
    headline: 'Evangelismo em massa e cruzadas.',
    fullStory:
        'Realizamos grandes cruzadas evangelísticas e plantação de igrejas em áreas rurais da Nigéria.',
    currentSupport: 2500,
    goalSupport: 3000,
    profileImageUrl: 'https://randomuser.me/api/portraits/men/55.jpg',
    coverImageUrl: _getCoverForLocation('Lagos, Nigéria'),
    nationality: 'Nigéria',
    countryCode: 'ng',
  );

  // 8. Elena Ivanov (Europe - Ukraine)
  static final MissionaryData elenaIvanov = MissionaryData(
    id: '8',
    name: 'Elena Ivanov',
    slug: 'elena',
    location: 'Kiev, Ucrânia',
    latitude: 50.4501,
    longitude: 30.5234,
    yearsInField: '1 Ano',
    livesImpacted: '800+',
    headline: 'Apoio humanitário em tempos de crise.',
    fullStory:
        'Distribuímos alimentos, roupas e Bíblias para famílias deslocadas pela guerra.',
    currentSupport: 4800,
    goalSupport: 6000,
    profileImageUrl: 'https://randomuser.me/api/portraits/women/48.jpg',
    coverImageUrl: _getCoverForLocation('Kiev, Ucrânia'),
    nationality: 'Ucrânia',
    countryCode: 'ua',
  );

  // 9. Raj Patel (Asia - India)
  static final MissionaryData rajPatel = MissionaryData(
    id: '9',
    name: 'Raj Patel',
    slug: 'raj',
    location: 'Mumbai, Índia',
    latitude: 19.0760,
    longitude: 72.8777,
    yearsInField: '10 Anos',
    livesImpacted: '2.500+',
    headline: 'Resgatando crianças das ruas.',
    fullStory:
        'Mantemos um orfanato e escola para crianças em situação de rua nos subúrbios de Mumbai.',
    currentSupport: 1500, // Very low
    goalSupport: 4500,
    profileImageUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
    coverImageUrl: _getCoverForLocation('Mumbai, Índia'),
    nationality: 'Índia',
    countryCode: 'in',
  );

  // 10. Carmen Rodriguez (South America - Peru)
  static final MissionaryData carmenRodriguez = MissionaryData(
    id: '10',
    name: 'Carmen R.',
    slug: 'carmen',
    location: 'Cusco, Peru',
    latitude: -13.5319,
    longitude: -71.9675,
    yearsInField: '4 Anos',
    livesImpacted: '400+',
    headline: 'Traduzindo a Bíblia para o Quechua.',
    fullStory:
        'Nosso projeto foca na tradução bíblica e alfabetização nas montanhas dos Andes.',
    currentSupport: 2200,
    goalSupport: 3500,
    profileImageUrl: 'https://randomuser.me/api/portraits/women/12.jpg',
    coverImageUrl: _getCoverForLocation('Cusco, Peru'),
    nationality: 'Peru',
    countryCode: 'pe',
  );

  // 11. John Doe (North America - USA - Urban Ministry)
  static final MissionaryData johnDoe = MissionaryData(
    id: '11',
    name: 'John Doe',
    slug: 'john',
    location: 'Nova Iorque, EUA',
    latitude: 40.7128,
    longitude: -74.0060,
    yearsInField: '3 Anos',
    livesImpacted: '200+',
    headline: 'Missão urbana em meio aos arranha-céus.',
    fullStory:
        'Trabalhamos com moradores de rua e viciados no Bronx, levando esperança e reabilitação.',
    currentSupport: 5500,
    goalSupport: 8000, // Needs more because cost of living is high
    profileImageUrl: 'https://randomuser.me/api/portraits/men/33.jpg',
    coverImageUrl: _getCoverForLocation('Nova Iorque, EUA'),
    nationality: 'EUA',
    countryCode: 'us',
  );

  // 12. Ahmed (Middle East - Sensitive)
  static final MissionaryData ahmed = MissionaryData(
    id: '12',
    name: 'Ahmed K.',
    slug: 'ahmed',
    location: 'Cairo, Egito',
    latitude: 30.0444,
    longitude: 31.2357,
    yearsInField: '7 Anos',
    livesImpacted: 'Unknown',
    headline: 'Compartilhando a luz no deserto.',
    fullStory:
        'Discipulado um a um e pequenos grupos em cafés e universidades.',
    currentSupport: 2800,
    goalSupport: 3000,
    profileImageUrl: 'https://randomuser.me/api/portraits/men/78.jpg',
    coverImageUrl: _getCoverForLocation('Cairo, Egito'),
    nationality: 'Egito',
    countryCode: 'eg',
    isPublic: false, // Private profile
  );

  static final List<MissionaryData> allMissionaries = [
    joaoPaulo,
    sarahJenkins,
    kenjiSato,
    anaCarlos,
    davidMiller,
    liWei,
    pastorEmmanuel,
    elenaIvanov,
    rajPatel,
    carmenRodriguez,
    johnDoe,
    ahmed,
  ];

  static Future<MissionaryData> getMissionaryBySlug(String slug) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return allMissionaries.firstWhere(
      (m) => m.slug == slug,
      orElse: () => joaoPaulo,
    );
  }

  static Future<List<MissionaryData>> getAllMissionaries() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return allMissionaries;
  }
}
