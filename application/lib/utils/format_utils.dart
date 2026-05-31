import 'dart:convert';

class FormatUtils {
  const FormatUtils._();

  static String prettyJson(Object? value) {
    return const JsonEncoder.withIndent('  ').convert(value);
  }
}
