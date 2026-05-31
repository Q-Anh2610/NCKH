import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/compaction_result.dart';
import '../../domain/repositories/compaction_repository.dart';
import '../datasources/huggingface_api_client.dart';

class CompactionRepositoryImpl implements CompactionRepository {
  const CompactionRepositoryImpl(this.apiClient);

  final HuggingFaceApiClient apiClient;

  @override
  Future<CompactionResult> compact(BlockConfiguration configuration) {
    return apiClient.compact(configuration);
  }
}
