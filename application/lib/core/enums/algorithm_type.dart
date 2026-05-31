enum AlgorithmType {
  greedyPotentialReduction,
  paperInspiredCompaction,
  randomValidMoves,
}

extension AlgorithmTypeLabel on AlgorithmType {
  String get label {
    return switch (this) {
      AlgorithmType.greedyPotentialReduction => 'Greedy potential reduction',
      AlgorithmType.paperInspiredCompaction => 'Paper-inspired compaction',
      AlgorithmType.randomValidMoves => 'Random valid moves',
    };
  }
}
