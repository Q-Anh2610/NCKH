import 'package:flutter/material.dart';

class JsonInputEditor extends StatelessWidget {
  const JsonInputEditor({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onApply,
    required this.onFormat,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onApply;
  final VoidCallback onFormat;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          minLines: 8,
          maxLines: 12,
          onChanged: onChanged,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: const InputDecoration(
            labelText: 'Configuration JSON',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.check),
              label: const Text('Apply JSON'),
            ),
            OutlinedButton.icon(
              onPressed: onFormat,
              icon: const Icon(Icons.format_align_left),
              label: const Text('Format'),
            ),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }
}
