// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/services.dart';

import '../utils/format_utils.dart';

Future<void> copyJson(Object value) async {
  await Clipboard.setData(ClipboardData(text: FormatUtils.prettyJson(value)));
}

void downloadJson(String fileName, Object value) {
  final content = FormatUtils.prettyJson(value);
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
}
