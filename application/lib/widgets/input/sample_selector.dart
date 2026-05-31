import 'package:flutter/material.dart';

import '../../data/example_configs.dart';

class SampleSelector extends StatelessWidget {
  const SampleSelector({
    super.key,
    required this.samples,
    required this.onChanged,
  });

  final List<ExampleConfig> samples;
  final ValueChanged<ExampleConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ExampleConfig>(
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Sample configuration'),
      items: samples.map((sample) {
        return DropdownMenuItem(
          value: sample,
          child: Text(
            sample.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (sample) {
        if (sample != null) {
          onChanged(sample);
        }
      },
    );
  }
}
