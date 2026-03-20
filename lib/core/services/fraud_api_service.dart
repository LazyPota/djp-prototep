import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../domain/entities/trust_score.dart';
import '../utils/app_config.dart';

class FraudApiService {
  const FraudApiService({http.Client? client}) : _client = client;

  final http.Client? _client;

  static const Duration _requestTimeout = Duration(seconds: 30);

  Future<TrustScore> analyzeUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw Exception('Invalid URL format');
    }

    final client = _client ?? http.Client();
    try {
      final response = await client
          .post(
            Uri.parse(AppConfig.analyzeUrlEndpoint),
            headers: const {
              'content-type': 'application/json',
              'accept': 'application/json',
            },
            body: jsonEncode({'url': url}),
          )
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Server error (${response.statusCode})');
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw Exception('Unexpected JSON shape');
        }
        return TrustScore.fromJson(decoded);
      } on FormatException {
        throw Exception('Invalid response from server');
      }
    } on TimeoutException {
      throw Exception('Request timed out');
    } on SocketException {
      throw Exception('Network connection failed');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  Future<int?> fetchGlobalProtectedCount() async {
    final client = _client ?? http.Client();
    try {
      final response = await client
          .get(
            Uri.parse(AppConfig.globalStatsEndpoint),
            headers: const {'accept': 'application/json'},
          )
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final value = decoded['globalProtected'] ?? decoded['global_protected'];
          if (value is num) return value.toInt();
        }
      } on FormatException {
        return null;
      }
      return null;
    } on TimeoutException {
      return null;
    } on SocketException {
      return null;
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}
