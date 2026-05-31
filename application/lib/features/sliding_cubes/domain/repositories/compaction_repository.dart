import '../entities/block_configuration.dart';
import '../entities/compaction_result.dart';

abstract class CompactionRepository {
  Future<CompactionResult> compact(BlockConfiguration configuration);
}
