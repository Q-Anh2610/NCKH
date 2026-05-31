import '../entities/block_configuration.dart';

class PotentialCalculator {
  const PotentialCalculator();

  int calculate(BlockConfiguration configuration) {
    return configuration.blocks.fold<int>(0, (sum, block) {
      return sum + block.x.abs() + block.y.abs() + (block.z ?? 0).abs();
    });
  }
}
