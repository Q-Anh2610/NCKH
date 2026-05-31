import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/compaction_result.dart';

class HuggingFaceApiClient {
  HuggingFaceApiClient({Uri? endpoint})
    : endpoint =
          endpoint ??
          Uri.parse(
            'https://sliding-cubes-lab-sliding-cubes-api.hf.space/compact',
          );

  final Uri endpoint;

  Future<CompactionResult> compact(BlockConfiguration configuration) async {
    final requestJson = configuration.toJson();
    final requestBody = jsonEncode(requestJson);

    debugPrint('==============================');
    debugPrint('CALLING HUGGING FACE API');
    debugPrint('URL: $endpoint');
    debugPrint('REQUEST JSON: $requestJson');
    debugPrint('REQUEST BODY: $requestBody');
    debugPrint('==============================');

    try {
      final response = await http
          .post(
            endpoint,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('==============================');
      debugPrint('API RESPONSE RECEIVED');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE BODY: ${response.body}');
      debugPrint('==============================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final decoded = jsonDecode(response.body);

          debugPrint('DECODED JSON: $decoded');

          if (decoded is! Map<String, dynamic>) {
            throw Exception(
              'Response không phải Map<String, dynamic>. Response thật: $decoded',
            );
          }

          final result = CompactionResult.fromJson(decoded);

          debugPrint('PARSE SUCCESS');
          debugPrint('TOTAL STEPS: ${result.totalSteps}');

          return result;
        } catch (parseError, stackTrace) {
          debugPrint('==============================');
          debugPrint('PARSE JSON ERROR');
          debugPrint('ERROR: $parseError');
          debugPrint('STACK TRACE: $stackTrace');
          debugPrint('RAW BODY: ${response.body}');
          debugPrint('==============================');

          throw Exception('API gọi thành công nhưng lỗi đọc JSON: $parseError');
        }
      }

      debugPrint('==============================');
      debugPrint('API STATUS ERROR');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==============================');

      throw Exception('API trả lỗi ${response.statusCode}: ${response.body}');
    } catch (error, stackTrace) {
      debugPrint('==============================');
      debugPrint('COMPACT API ERROR');
      debugPrint('ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('==============================');

      throw Exception('Không gọi được Hugging Face API: $error');
    }
  }
}
