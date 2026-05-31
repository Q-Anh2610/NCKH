import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/json_pretty.dart';
import '../../domain/entities/compaction_result.dart';

class ResultExportPanel extends StatelessWidget {
  const ResultExportPanel({super.key, required this.result});

  final CompactionResult? result;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: result == null
              ? null
              : () async {
                  await Clipboard.setData(
                    ClipboardData(text: JsonPretty.encode(result!.toJson())),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Result JSON copied')),
                    );
                  }
                },
          icon: const Icon(Icons.copy),
          label: const Text('Copy result JSON'),
        ),
        OutlinedButton.icon(
          onPressed: result == null ? null : () {},
          icon: const Icon(Icons.download),
          label: const Text('Download steps.json'),
        ),
      ],
    );
  }
}
