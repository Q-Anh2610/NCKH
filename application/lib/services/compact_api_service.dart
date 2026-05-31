import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/compact_request.dart';
import '../models/compact_response.dart';

class CompactApiException implements Exception {
  const CompactApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CompactApiService {
  CompactApiService({
    http.Client? client,
    this.baseUrl = ApiConfig.baseUrl,
    this.timeout = const Duration(seconds: 120),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  Future<CompactResponse> compact(CompactRequest request) async {
    final uri = Uri.parse('$baseUrl${ApiConfig.compactEndpoint}');
    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String message = '-';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final result = CompactResponse.fromJson(decoded);
            message = result.message.isEmpty ? '-' : result.message;
          }
        } catch (_) {
          // Ignore parsing errors for HTTP error status codes, as the body could be plain text (e.g. "Internal Server Error")
        }
        throw CompactApiException(
          'API request failed.\n'
          'URL: $uri\n'
          'HTTP ${response.statusCode}\n'
          'Message: $message\n'
          'Body: ${_truncate(response.body)}',
        );
      }

      Object? decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException catch (error) {
        throw CompactApiException(
          'API returned malformed JSON.\n'
          'URL: $uri\n'
          'HTTP ${response.statusCode}\n'
          'Parse error: $error\n'
          'Body: ${_truncate(response.body)}',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw CompactApiException(
          'API returned an invalid payload.\n'
          'URL: $uri\n'
          'HTTP ${response.statusCode}\n'
          'Body: ${_truncate(response.body)}',
        );
      }

      final result = CompactResponse.fromJson(decoded);
      if (!result.success || result.status == 'invalid_input') {
        throw CompactApiException(
          'Backend rejected the input.\n'
          'URL: $uri\n'
          'HTTP ${response.statusCode}\n'
          'Message: ${result.message.isEmpty ? '-' : result.message}\n'
          'Body: ${_truncate(response.body)}',
        );
      }
      return result;
    } on TimeoutException {
      throw CompactApiException(
        'Backend timed out.\nURL: $uri\nTimeout: ${timeout.inSeconds}s',
      );
    } on FormatException catch (error) {
      throw CompactApiException(
        'API response could not be parsed by the app model.\n'
        'URL: $uri\n'
        'Parse error: $error',
      );
    } on http.ClientException catch (error) {
      throw CompactApiException(
        'Backend unavailable.\n'
        'URL: $uri\n'
        'Error: ${error.message}\n'
        'If this only happens in the browser, check CORS on the API server.',
      );
    }
  }

  String _truncate(String value) {
    const max = 1200;
    if (value.length <= max) {
      return value;
    }
    return '${value.substring(0, max)}...';
  }
}
