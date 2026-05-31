import 'package:flutter/material.dart';

import '../../data/datasources/sample_configuration_source.dart';

class SampleSelector extends StatelessWidget {
  const SampleSelector({
    super.key,
    required this.samples,
    required this.onChanged,
  });

  final List<SampleConfiguration> samples;
  final ValueChanged<SampleConfiguration> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<SampleConfiguration>(
      decoration: const InputDecoration(labelText: 'Sample configuration'),
      isExpanded: true,
      items: samples
          .map(
            (sample) => DropdownMenuItem(
              value: sample,
              child: Text(sample.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (sample) {
        if (sample != null) {
          onChanged(sample);
        }
      },
    );
  }
}
