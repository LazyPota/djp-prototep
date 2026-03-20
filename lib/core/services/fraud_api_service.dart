import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/trust_score.dart';
import '../utils/app_config.dart';

class FraudApiService {
  const FraudApiService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<TrustScore> analyzeUrl(String url) async {
    final client = _client ?? http.Client();
    try {
      final response = await client.post(
        Uri.parse(AppConfig.analyzeUrlEndpoint),
        headers: const {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Server error (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected JSON shape');
      }

      return TrustScore.fromJson(decoded);
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  Future<int?> fetchGlobalProtectedCount() async {
    final client = _client ?? http.Client();
    try {
      final response = await client.get(
        Uri.parse(AppConfig.globalStatsEndpoint),
        headers: const {'accept': 'application/json'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final value = decoded['globalProtected'] ?? decoded['global_protected'];
        if (value is num) return value.toInt();
      }
      return null;
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}
