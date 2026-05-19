import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JoshuaProjectApi {
  final String apiKey;
  static const String baseUrl = "https://api.joshuaproject.net/v1";

  JoshuaProjectApi({required this.apiKey});

  /// Busca grupos étnicos por país ou nome
  Future<List<dynamic>> fetchPeopleGroups({String? countryCode, String? query}) async {
    final url = Uri.parse("$baseUrl/people_groups.json?api_key=$apiKey" + 
        (countryCode != null ? "&rog3=$countryCode" : "") +
        (query != null ? "&name=$query" : ""));

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Falha ao carregar dados do Joshua Project");
      }
    } catch (e) {
      return [];
    }
  }

  /// Retorna estatísticas de "Não Alcançados" (Unreached)
  Future<Map<String, dynamic>> fetchGlobalStats() async {
    // Implementação mock/cache por enquanto
    return {
      "total_people_groups": 17400,
      "unreached_groups": 7400,
      "unreached_percentage": 42.5,
    };
  }
}

// Provider
final joshuaProjectProvider = Provider<JoshuaProjectApi>((ref) {
  // Em produção, isso viria de .env ou Config
  const apiKey = String.fromEnvironment('JOSHUA_PROJECT_API_KEY', defaultValue: '');
  return JoshuaProjectApi(apiKey: apiKey);
});
