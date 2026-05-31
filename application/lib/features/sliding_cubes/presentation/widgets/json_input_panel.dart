import 'package:flutter/material.dart';

import '../../../../core/utils/coordinate_parser.dart';
import '../../../../core/utils/json_pretty.dart';
import '../../domain/entities/block_configuration.dart';

class JsonInputPanel extends StatefulWidget {
  const JsonInputPanel({
    super.key,
    required this.configuration,
    required this.onParsed,
  });

  final BlockConfiguration configuration;
  final ValueChanged<BlockConfiguration> onParsed;

  @override
  State<JsonInputPanel> createState() => _JsonInputPanelState();
}

class _JsonInputPanelState extends State<JsonInputPanel> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: JsonPretty.encode(widget.configuration.toJson()),
    );
  }

  @override
  void didUpdateWidget(covariant JsonInputPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.configuration != widget.configuration) {
      _controller.text = JsonPretty.encode(widget.configuration.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          minLines: 6,
          maxLines: 10,
          decoration: InputDecoration(
            labelText: 'JSON coordinates',
            errorText: _error,
            border: const OutlineInputBorder(),
          ),
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            try {
              final parsed = CoordinateParser.parseConfiguration(
                _controller.text,
              );
              setState(() => _error = null);
              widget.onParsed(parsed);
            } catch (error) {
              setState(() => _error = error.toString());
            }
          },
          icon: const Icon(Icons.data_object),
          label: const Text('Apply JSON'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
