import 'package:flutter/services.dart';

import '../utils/format_utils.dart';

Future<void> copyJson(Object value) async {
  await Clipboard.setData(ClipboardData(text: FormatUtils.prettyJson(value)));
}

void downloadJson(String fileName, Object value) {
  throw UnsupportedError('JSON download is only available on Flutter web.');
}
