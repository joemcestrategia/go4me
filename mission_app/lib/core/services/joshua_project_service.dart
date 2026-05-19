import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo simplificado para País
class JoshuaCountry {
  final String name;
  final String region;
  final String rog3; // ROG3 code from API
  final String iso3; // ISO 3166-1 alpha-3 (e.g. AFG, BRA)
  final String iso2code; // ISO 3166-1 alpha-2 from API (e.g. AF, BR)
  final double percentEvangelical;
  final double percentChristianity;
  final double percentBuddhism;
  final double percentEthnicReligions;
  final double percentHinduism;
  final double percentIslam;
  final double percentNonReligious;
  final double percentOtherSmall;
  final int population;
  final int populationUnreached; // PoplPeoplesLR
  final int numPeopleGroups;
  final int numUnreachedPeopleGroups;
  final int numFrontierPeopleGroups; // CntPeoplesFPG
  final String primaryReligion;
  final String capital;
  final String officialLang;
  final String window1040; // Y or N
  final String jpScaleText;

  // ROG3 → ISO 3166-1 alpha-2 mapping for flag URLs
  static const _rog3ToIso2 = {
    'BRA': 'br',
    'JPN': 'jp',
    'IND': 'in',
    'CHN': 'cn',
    'MOZ': 'mz',
    'NGA': 'ng',
    'USA': 'us',
    'EGY': 'eg',
    'RUS': 'ru',
    'DEU': 'de',
    'FRA': 'fr',
    'GBR': 'gb',
    'KOR': 'kr',
    'PRK': 'kp',
    'IRN': 'ir',
    'SAU': 'sa',
    'TUR': 'tr',
    'IDN': 'id',
    'AUS': 'au',
    'ZAF': 'za',
    'KEN': 'ke',
    'ARG': 'ar',
    'CHL': 'cl',
    'COL': 'co',
    'MEX': 'mx',
    'CAN': 'ca',
    'ESP': 'es',
    'ITA': 'it',
    'POL': 'pl',
    'UKR': 'ua',
    'PAK': 'pk',
    'VNM': 'vn',
    'THA': 'th',
    'PHL': 'ph',
    'PER': 'pe',
    'MYS': 'my',
    'BGD': 'bd',
    'ETH': 'et',
    'TZA': 'tz',
    'GHA': 'gh',
    'AFG': 'af',
    'IRQ': 'iq',
    'SYR': 'sy',
    'LBN': 'lb',
    'JOR': 'jo',
    'ISR': 'il',
    'MMR': 'mm',
    'NPL': 'np',
    'LKA': 'lk',
    'KHM': 'kh',
    'LAO': 'la',
    'SWE': 'se',
    'NOR': 'no',
    'FIN': 'fi',
    'DNK': 'dk',
    'NLD': 'nl',
    'BEL': 'be',
    'CHE': 'ch',
    'AUT': 'at',
    'PRT': 'pt',
    'GRC': 'gr',
    'ROU': 'ro',
    'HUN': 'hu',
    'CZE': 'cz',
    'NZL': 'nz',
  };

  String get iso2 {
    if (iso2code.isNotEmpty) return iso2code.toLowerCase();
    return _rog3ToIso2[iso3] ?? _rog3ToIso2[rog3] ?? rog3.toLowerCase();
  }

  String get flagUrl => 'https://flagcdn.com/w80/$iso2.png';

  JoshuaCountry({
    required this.name,
    required this.region,
    required this.rog3,
    this.iso3 = '',
    this.iso2code = '',
    this.percentEvangelical = 0.0,
    this.percentChristianity = 0.0,
    this.percentBuddhism = 0.0,
    this.percentEthnicReligions = 0.0,
    this.percentHinduism = 0.0,
    this.percentIslam = 0.0,
    this.percentNonReligious = 0.0,
    this.percentOtherSmall = 0.0,
    this.population = 0,
    this.populationUnreached = 0,
    this.numPeopleGroups = 0,
    this.numUnreachedPeopleGroups = 0,
    this.numFrontierPeopleGroups = 0,
    this.primaryReligion = '',
    this.capital = '',
    this.officialLang = '',
    this.window1040 = '',
    this.jpScaleText = '',
  });

  factory JoshuaCountry.fromJson(Map<String, dynamic> json) {
    return JoshuaCountry(
      name: json['Ctry'] ?? json['Name'] ?? '',
      region: json['RegionName'] ?? json['Region'] ?? '',
      rog3: json['ROG3'] ?? '',
      iso3: json['ISO3'] ?? '',
      iso2code: json['ISO2'] ?? '',
      percentEvangelical: (json['PercentEvangelical'] ?? 0).toDouble(),
      percentChristianity: (json['PercentChristianity'] ?? 0).toDouble(),
      percentBuddhism: (json['PercentBuddhism'] ?? 0).toDouble(),
      percentEthnicReligions: (json['PercentEthnicReligions'] ?? 0).toDouble(),
      percentHinduism: (json['PercentHinduism'] ?? 0).toDouble(),
      percentIslam: (json['PercentIslam'] ?? 0).toDouble(),
      percentNonReligious: (json['PercentNonReligious'] ?? 0).toDouble(),
      percentOtherSmall: (json['PercentOtherSmall'] ?? 0).toDouble(),
      population: (json['Population'] ?? 0).toInt(),
      populationUnreached: (json['PoplPeoplesLR'] ?? 0).toInt(),
      numPeopleGroups: (json['CntPeoples'] ?? json['NumPeopleGroups'] ?? 0)
          .toInt(),
      numUnreachedPeopleGroups:
          (json['CntPeoplesLR'] ?? json['NumUnreachedPeopleGroups'] ?? 0)
              .toInt(),
      numFrontierPeopleGroups: (json['CntPeoplesFPG'] ?? 0).toInt(),
      primaryReligion: json['ReligionPrimary'] ?? json['PrimaryReligion'] ?? '',
      capital: json['Capital'] ?? '',
      officialLang: json['OfficialLang'] ?? '',
      window1040: json['Window1040'] ?? '',
      jpScaleText: json['JPScaleText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Ctry': name,
      'RegionName': region,
      'ROG3': rog3,
      'ISO3': iso3,
      'ISO2': iso2code,
      'PercentEvangelical': percentEvangelical,
      'PercentChristianity': percentChristianity,
      'PercentBuddhism': percentBuddhism,
      'PercentEthnicReligions': percentEthnicReligions,
      'PercentHinduism': percentHinduism,
      'PercentIslam': percentIslam,
      'PercentNonReligious': percentNonReligious,
      'PercentOtherSmall': percentOtherSmall,
      'Population': population,
      'PoplPeoplesLR': populationUnreached,
      'CntPeoples': numPeopleGroups,
      'CntPeoplesLR': numUnreachedPeopleGroups,
      'CntPeoplesFPG': numFrontierPeopleGroups,
      'ReligionPrimary': primaryReligion,
      'Capital': capital,
      'OfficialLang': officialLang,
      'Window1040': window1040,
      'JPScaleText': jpScaleText,
    };
  }
}

// Modelo simplificado para Grupo de Pessoas
class JoshuaPeopleGroup {
  final String peopNameInCountry;
  final int population;
  final double percentChristian;
  final double latitude;
  final double longitude;
  final String country;
  final String primaryReligion;
  final String language;
  final String rop3;

  JoshuaPeopleGroup({
    required this.peopNameInCountry,
    required this.population,
    required this.percentChristian,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.primaryReligion = '',
    this.language = '',
    this.rop3 = '',
  });

  factory JoshuaPeopleGroup.fromJson(Map<String, dynamic> json) {
    return JoshuaPeopleGroup(
      peopNameInCountry: json['PeopNameInCountry'] ?? '',
      population: json['Population'] ?? 0,
      percentChristian: (json['PercentChristian'] ?? 0).toDouble(),
      latitude: (json['Latitude'] ?? 0).toDouble(),
      longitude: (json['Longitude'] ?? 0).toDouble(),
      country: json['Ctry'] ?? '',
      primaryReligion: json['PrimaryReligion'] ?? '',
      language: json['Language'] ?? '',
      rop3: json['ROP3'] ?? '',
    );
  }
}

class JoshuaProjectService {
  static const String _baseUrl = 'https://api.joshuaproject.net';
  static const String _apiKey = 'd8f0e36facd3'; // Chave fornecida pelo usuário
  static const String _cacheFileName = 'countries_cache.json';

  Future<dynamic> get _cacheFile async {
    if (kIsWeb) return null;
    return null; // Placeholder para evitar dependência direta de File no getter
  }

  Future<List<JoshuaCountry>> getCountries() async {
    // Check Cache Strategy
    if (!kIsWeb) {
      // Logic for mobile cache if we restore it later
    }

    // Fetch from API
    // Correct Endpoint: v1/countries.json
    final url = Uri.parse('$_baseUrl/v1/countries.json?api_key=$_apiKey');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final countries = data
            .map((json) => JoshuaCountry.fromJson(json))
            .toList();

        // Save to cache
        _saveToCache(countries);

        return countries;
      } else {
        // Fallback
        print('Erro API Countries: ${response.statusCode}');
        return _getFallbackCountries();
      }
    } catch (e) {
      print('Erro de conexão Countries: $e');
      return _getFallbackCountries();
    }
  }

  Future<void> _saveToCache(List<JoshuaCountry> countries) async {
    if (kIsWeb) return;
    // Logica de cache desativada para simplificar build web
  }

  Future<List<JoshuaPeopleGroup>> getPeopleGroupsByCountry(
    String countryCode,
  ) async {
    // Usando ROG3 code para filtrar
    // Correct Endpoint: v1/people_groups.json
    final url = Uri.parse(
      '$_baseUrl/v1/people_groups.json?api_key=$_apiKey&rog3=$countryCode',
    );
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => JoshuaPeopleGroup.fromJson(json)).toList();
      } else {
        print('Erro API People Groups: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erro de conexão People Groups: $e');
      return [];
    }
  }

  List<JoshuaCountry> _getFallbackCountries() {
    return [
      JoshuaCountry(
        name: 'Brazil',
        region: 'Americas',
        rog3: 'BRA',
        percentEvangelical: 24.4,
        population: 214000000,
        numPeopleGroups: 310,
        numUnreachedPeopleGroups: 28,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Japan',
        region: 'Asia',
        rog3: 'JPN',
        percentEvangelical: 0.5,
        population: 125000000,
        numPeopleGroups: 69,
        numUnreachedPeopleGroups: 23,
        primaryReligion: 'Buddhism',
      ),
      JoshuaCountry(
        name: 'India',
        region: 'Asia',
        rog3: 'IND',
        percentEvangelical: 2.2,
        population: 1400000000,
        numPeopleGroups: 2300,
        numUnreachedPeopleGroups: 2000,
        primaryReligion: 'Hinduism',
      ),
      JoshuaCountry(
        name: 'China',
        region: 'Asia',
        rog3: 'CHN',
        percentEvangelical: 7.4,
        population: 1440000000,
        numPeopleGroups: 520,
        numUnreachedPeopleGroups: 420,
        primaryReligion: 'Non-Religious',
      ),
      JoshuaCountry(
        name: 'Mozambique',
        region: 'Africa',
        rog3: 'MOZ',
        percentEvangelical: 12.0,
        population: 32000000,
        numPeopleGroups: 63,
        numUnreachedPeopleGroups: 8,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Nigeria',
        region: 'Africa',
        rog3: 'NGA',
        percentEvangelical: 30.0,
        population: 211000000,
        numPeopleGroups: 530,
        numUnreachedPeopleGroups: 90,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'United States',
        region: 'Americas',
        rog3: 'USA',
        percentEvangelical: 25.0,
        population: 331000000,
        numPeopleGroups: 480,
        numUnreachedPeopleGroups: 40,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Egypt',
        region: 'Africa',
        rog3: 'EGY',
        percentEvangelical: 3.0,
        population: 104000000,
        numPeopleGroups: 45,
        numUnreachedPeopleGroups: 20,
        primaryReligion: 'Islam',
      ),
      // Adding robust fallback set for map visualization
      JoshuaCountry(
        name: 'Russia',
        region: 'Europe',
        rog3: 'RUS',
        percentEvangelical: 1.2,
        population: 144000000,
        numPeopleGroups: 180,
        numUnreachedPeopleGroups: 100,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Germany',
        region: 'Europe',
        rog3: 'DEU',
        percentEvangelical: 2.1,
        population: 83000000,
        numPeopleGroups: 90,
        numUnreachedPeopleGroups: 20,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'France',
        region: 'Europe',
        rog3: 'FRA',
        percentEvangelical: 1.0,
        population: 67000000,
        numPeopleGroups: 100,
        numUnreachedPeopleGroups: 30,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'United Kingdom',
        region: 'Europe',
        rog3: 'GBR',
        percentEvangelical: 7.8,
        population: 67000000,
        numPeopleGroups: 105,
        numUnreachedPeopleGroups: 25,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'South Korea',
        region: 'Asia',
        rog3: 'KOR',
        percentEvangelical: 16.0,
        population: 52000000,
        numPeopleGroups: 45,
        numUnreachedPeopleGroups: 5,
        primaryReligion: 'Non-Religious',
      ),
      JoshuaCountry(
        name: 'North Korea',
        region: 'Asia',
        rog3: 'PRK',
        percentEvangelical: 0.8,
        population: 26000000,
        numPeopleGroups: 8,
        numUnreachedPeopleGroups: 7,
        primaryReligion: 'Non-Religious',
      ),
      JoshuaCountry(
        name: 'Iran',
        region: 'Asia',
        rog3: 'IRN',
        percentEvangelical: 1.0,
        population: 87000000,
        numPeopleGroups: 95,
        numUnreachedPeopleGroups: 80,
        primaryReligion: 'Islam',
      ),
      JoshuaCountry(
        name: 'Saudi Arabia',
        region: 'Asia',
        rog3: 'SAU',
        percentEvangelical: 0.4,
        population: 36000000,
        numPeopleGroups: 40,
        numUnreachedPeopleGroups: 35,
        primaryReligion: 'Islam',
      ),
      JoshuaCountry(
        name: 'Turkey',
        region: 'Asia',
        rog3: 'TUR',
        percentEvangelical: 0.0,
        population: 85000000,
        numPeopleGroups: 60,
        numUnreachedPeopleGroups: 50,
        primaryReligion: 'Islam',
      ),
      JoshuaCountry(
        name: 'Indonesia',
        region: 'Asia',
        rog3: 'IDN',
        percentEvangelical: 5.0,
        population: 275000000,
        numPeopleGroups: 780,
        numUnreachedPeopleGroups: 200,
        primaryReligion: 'Islam',
      ),
      JoshuaCountry(
        name: 'Australia',
        region: 'Oceania',
        rog3: 'AUS',
        percentEvangelical: 12.0,
        population: 26000000,
        numPeopleGroups: 120,
        numUnreachedPeopleGroups: 15,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'South Africa',
        region: 'Africa',
        rog3: 'ZAF',
        percentEvangelical: 21.0,
        population: 60000000,
        numPeopleGroups: 55,
        numUnreachedPeopleGroups: 6,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Kenya',
        region: 'Africa',
        rog3: 'KEN',
        percentEvangelical: 48.0,
        population: 55000000,
        numPeopleGroups: 112,
        numUnreachedPeopleGroups: 20,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Argentina',
        region: 'Americas',
        rog3: 'ARG',
        percentEvangelical: 9.0,
        population: 46000000,
        numPeopleGroups: 50,
        numUnreachedPeopleGroups: 8,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Chile',
        region: 'Americas',
        rog3: 'CHL',
        percentEvangelical: 18.0,
        population: 19000000,
        numPeopleGroups: 30,
        numUnreachedPeopleGroups: 3,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Colombia',
        region: 'Americas',
        rog3: 'COL',
        percentEvangelical: 10.0,
        population: 52000000,
        numPeopleGroups: 110,
        numUnreachedPeopleGroups: 12,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Mexico',
        region: 'Americas',
        rog3: 'MEX',
        percentEvangelical: 8.0,
        population: 130000000,
        numPeopleGroups: 320,
        numUnreachedPeopleGroups: 50,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Canada',
        region: 'Americas',
        rog3: 'CAN',
        percentEvangelical: 7.0,
        population: 39000000,
        numPeopleGroups: 200,
        numUnreachedPeopleGroups: 30,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Spain',
        region: 'Europe',
        rog3: 'ESP',
        percentEvangelical: 1.0,
        population: 47000000,
        numPeopleGroups: 50,
        numUnreachedPeopleGroups: 10,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Italy',
        region: 'Europe',
        rog3: 'ITA',
        percentEvangelical: 1.1,
        population: 59000000,
        numPeopleGroups: 60,
        numUnreachedPeopleGroups: 12,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Poland',
        region: 'Europe',
        rog3: 'POL',
        percentEvangelical: 0.3,
        population: 38000000,
        numPeopleGroups: 20,
        numUnreachedPeopleGroups: 5,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Ukraine',
        region: 'Europe',
        rog3: 'UKR',
        percentEvangelical: 3.0,
        population: 44000000,
        numPeopleGroups: 55,
        numUnreachedPeopleGroups: 10,
        primaryReligion: 'Christianity',
      ),
      JoshuaCountry(
        name: 'Pakistan',
        region: 'Asia',
        rog3: 'PAK',
        percentEvangelical: 0.6,
        population: 230000000,
        numPeopleGroups: 400,
        numUnreachedPeopleGroups: 370,
        primaryReligion: 'Islam',
      ),
      JoshuaCountry(
        name: 'Vietnam',
        region: 'Asia',
        rog3: 'VNM',
        percentEvangelical: 1.8,
        population: 100000000,
        numPeopleGroups: 120,
        numUnreachedPeopleGroups: 60,
        primaryReligion: 'Buddhism',
      ),
      JoshuaCountry(
        name: 'Thailand',
        region: 'Asia',
        rog3: 'THA',
        percentEvangelical: 0.6,
        population: 72000000,
        numPeopleGroups: 100,
        numUnreachedPeopleGroups: 65,
        primaryReligion: 'Buddhism',
      ),
      JoshuaCountry(
        name: 'Philippines',
        region: 'Asia',
        rog3: 'PHL',
        percentEvangelical: 12.0,
        population: 115000000,
        numPeopleGroups: 185,
        numUnreachedPeopleGroups: 25,
        primaryReligion: 'Christianity',
      ),
    ];
  }
}

final joshuaProjectServiceProvider = Provider<JoshuaProjectService>((ref) {
  return JoshuaProjectService();
});
