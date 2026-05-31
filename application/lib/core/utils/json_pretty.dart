import 'dart:convert';

class JsonPretty {
  const JsonPretty._();

  static String encode(Object? value) {
    return const JsonEncoder.withIndent('  ').convert(value);
  }
}
