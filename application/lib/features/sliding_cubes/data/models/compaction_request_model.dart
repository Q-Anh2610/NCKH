import '../../domain/entities/block_configuration.dart';

class CompactionRequestModel {
  const CompactionRequestModel(this.configuration);

  final BlockConfiguration configuration;

  Map<String, dynamic> toJson() => configuration.toJson();
}
