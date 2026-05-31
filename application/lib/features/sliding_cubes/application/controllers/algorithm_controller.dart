import 'package:flutter/foundation.dart';

import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/compaction_result.dart';
import '../../domain/repositories/compaction_repository.dart';
import '../state/api_state.dart';

class AlgorithmController extends ChangeNotifier {
  AlgorithmController(this.repository);

  final CompactionRepository repository;

  ApiState<CompactionResult> _state = ApiState.idle();

  ApiState<CompactionResult> get state => _state;

  Future<void> compact(BlockConfiguration configuration) async {
    _state = ApiState.loading();
    notifyListeners();

    try {
      final result = await repository.compact(configuration);
      _state = ApiState.success(result);
    } catch (error) {
      _state = ApiState.failure(error.toString());
    }

    notifyListeners();
  }
}
