import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/example_configs.dart';
import '../models/block_position.dart';
import '../models/compact_request.dart';
import '../models/compact_response.dart';
import '../models/move_step.dart';
import '../models/validation_result.dart';
import '../services/compact_api_service.dart';
import '../services/random_config_service.dart';
import '../utils/connectivity_utils.dart';
import '../utils/coordinate_utils.dart';
import '../utils/format_utils.dart';
import '../validators/input_validator.dart';

enum DimensionMode { twoD, threeD }

enum AlgorithmChoice {
  greedyPotentialReduction,
  paperInspiredCompaction,
  randomValidMoves,
}

enum InputSource { sample, json, random, grid }

enum ApiRunStatus { ready, running, error }

class SimulationController extends ChangeNotifier {
  SimulationController({
    CompactApiService? apiService,
    RandomConfigService? randomConfigService,
  }) : _apiService = apiService ?? CompactApiService(),
       _randomConfigService =
           randomConfigService ?? const RandomConfigService() {
    loadSample(ExampleConfigs.examples2d.first);
  }

  final CompactApiService _apiService;
  final RandomConfigService _randomConfigService;
  Timer? _timer;

  DimensionMode dimensionMode = DimensionMode.twoD;
  AlgorithmChoice algorithm = AlgorithmChoice.greedyPotentialReduction;
  InputSource inputSource = InputSource.sample;
  List<BlockPosition> blocks = [];
  String jsonText = '';
  int maxSteps = 100;
  int gridSize = 10;
  int layerCount = 3;
  int randomBlockCount = 10;
  int randomGridSize = 8;
  int randomMaxZ = 3;
  ValidationResult validation = ValidationResult.valid();
  CompactResponse? result;
  int currentStep = 0;
  bool isRunning = false;
  bool isAnimatingStep = false;
  MoveStep? activeStep;
  MoveStep? activeSubStep;
  double animationProgress = 0;
  int activeSubStepIndex = 0;
  int activeSubStepCount = 0;
  int speedMs = 600;
  BlockPosition? selectedBlock;
  bool showFinalResult = false;
  bool showAllLayers = true;
  ApiRunStatus apiStatus = ApiRunStatus.ready;
  String? errorMessage;
  List<BlockPosition>? _committedBlocks;
  Stopwatch? _stepStopwatch;

  int get dimension => dimensionMode == DimensionMode.twoD ? 2 : 3;
  int get totalSteps => result?.totalSteps ?? result?.steps.length ?? 0;
  bool get hasResult => result != null;
  bool get canRun => validation.isValid && apiStatus != ApiRunStatus.running;
  String get backendStatus =>
      result?.status ?? (errorMessage == null ? 'idle' : 'error');
  String get simulationStatus {
    if (apiStatus == ApiRunStatus.running) {
      return 'loading';
    }
    if (isRunning) {
      return 'running';
    }
    if (errorMessage != null) {
      return 'error';
    }
    if (result != null && currentStep >= totalSteps) {
      return 'finished';
    }
    return result == null ? 'idle' : 'paused';
  }

  MoveStep? get currentMove {
    if (activeStep != null) {
      return activeStep;
    }
    if (result == null ||
        currentStep == 0 ||
        currentStep > result!.steps.length) {
      return null;
    }
    return result!.steps[currentStep - 1];
  }

  List<BlockPosition> get currentBlocks {
    if (showFinalResult && result != null) {
      return result!.finalBlocks;
    }
    if (result != null) {
      return _committedBlocks ??
          (result!.initialBlocks.isNotEmpty ? result!.initialBlocks : blocks);
    }
    return blocks;
  }

  List<BlockPosition> get validMoves {
    final block = selectedBlock;
    if (block == null) {
      return const [];
    }
    final occupied = currentBlocks.toSet();
    return ConnectivityUtils.neighbors(block, dimension)
        .where((candidate) => !occupied.contains(candidate))
        .where((candidate) => candidate.x < gridSize && candidate.y < gridSize)
        .where((candidate) => dimension == 2 || candidate.z < layerCount)
        .toList();
  }

  List<int> get potentialSeries {
    final apiSeries = result?.potentialSeries ?? const [];
    if (apiSeries.isNotEmpty) {
      return apiSeries;
    }
    final values = <int>[
      CoordinateUtils.potential(result?.initialBlocks ?? blocks),
    ];
    if (result != null) {
      for (var step = 1; step <= result!.steps.length; step++) {
        values.add(CoordinateUtils.potential(_blocksAtStep(step)));
      }
    }
    return values;
  }

  void setDimension(DimensionMode mode) {
    if (dimensionMode == mode) {
      return;
    }
    dimensionMode = mode;
    layerCount = mode == DimensionMode.threeD ? 3 : layerCount;
    loadSample(ExampleConfigs.forDimension(dimension).first);
  }

  void setAlgorithm(AlgorithmChoice choice) {
    algorithm = choice;
    notifyListeners();
  }

  void setInputSource(InputSource source) {
    inputSource = source;
    notifyListeners();
  }

  void setMaxSteps(int value) {
    maxSteps = value;
    _syncJson();
    validate();
  }

  void loadSample(ExampleConfig example) {
    dimensionMode = example.dimension == 3
        ? DimensionMode.threeD
        : DimensionMode.twoD;
    blocks = List<BlockPosition>.from(example.blocks);
    _afterConfigurationChanged();
  }

  void toggleBlock(BlockPosition block) {
    if (block.dimension != dimension || !block.isNonNegative) {
      return;
    }
    final next = [...blocks];
    if (next.contains(block)) {
      next.remove(block);
      if (selectedBlock == block) {
        selectedBlock = null;
      }
    } else {
      next.add(block);
      selectedBlock = block;
    }
    blocks = next;
    _afterConfigurationChanged();
  }

  void selectBlock(BlockPosition block) {
    selectedBlock = block;
    notifyListeners();
  }

  void clearGrid() {
    blocks = [];
    selectedBlock = null;
    _afterConfigurationChanged();
  }

  void normalizeToOrigin() {
    blocks = CoordinateUtils.normalizeToOrigin(blocks);
    _afterConfigurationChanged();
  }

  void expandGrid() {
    gridSize = (gridSize + 2).clamp(4, 30);
    notifyListeners();
  }

  void addLayer() {
    layerCount = (layerCount + 1).clamp(1, 12);
    notifyListeners();
  }

  void removeLayer() {
    if (layerCount <= 1) {
      return;
    }
    layerCount--;
    blocks = blocks.where((block) => block.z < layerCount).toList();
    _afterConfigurationChanged();
  }

  void setRandomBlockCount(int value) {
    randomBlockCount = value;
    notifyListeners();
  }

  void setRandomGridSize(int value) {
    randomGridSize = value;
    gridSize = value;
    notifyListeners();
  }

  void setRandomMaxZ(int value) {
    randomMaxZ = value;
    layerCount = value + 1;
    notifyListeners();
  }

  void generateRandom() {
    blocks = _randomConfigService.generate(
      dimension: dimension,
      numberOfBlocks: randomBlockCount,
      gridSize: randomGridSize,
      maxZ: randomMaxZ,
    );
    gridSize = randomGridSize;
    if (dimension == 3) {
      layerCount = randomMaxZ + 1;
    }
    _afterConfigurationChanged();
  }

  void updateJsonText(String value) {
    jsonText = value;
    notifyListeners();
  }

  void applyJson() {
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('JSON root must be an object.');
      }
      final parsedDimension = decoded['dimension'];
      final parsedBlocks = decoded['blocks'];
      final parsedMaxSteps = decoded['max_steps'] ?? decoded['maxSteps'];
      if (parsedDimension is! num || parsedBlocks is! List) {
        throw const FormatException('JSON must contain dimension and blocks.');
      }
      dimensionMode = parsedDimension.toInt() == 3
          ? DimensionMode.threeD
          : DimensionMode.twoD;
      blocks = parsedBlocks.map(BlockPosition.fromJson).toList();
      if (parsedMaxSteps is num) {
        maxSteps = parsedMaxSteps.toInt();
      }
      errorMessage = null;
      _afterConfigurationChanged(syncJson: false);
    } catch (error) {
      validation = ValidationResult.invalid(['Invalid JSON: $error']);
      errorMessage = 'Invalid JSON';
      notifyListeners();
    }
  }

  void formatJson() {
    try {
      jsonText = FormatUtils.prettyJson(jsonDecode(jsonText));
      notifyListeners();
    } catch (_) {
      _syncJson();
      notifyListeners();
    }
  }

  void clearJson() {
    jsonText = '';
    blocks = [];
    _afterConfigurationChanged(syncJson: false);
  }

  void validate() {
    validation = InputValidator.validate(
      dimension: dimension,
      blocks: blocks,
      maxSteps: maxSteps,
    );
    notifyListeners();
  }

  Future<void> runAlgorithm() async {
    validate();
    if (!validation.isValid) {
      return;
    }
    _timer?.cancel();
    isRunning = false;
    _clearStepAnimation();
    apiStatus = ApiRunStatus.running;
    errorMessage = null;
    currentStep = 0;
    _clearStepAnimation();
    _committedBlocks = null;
    showFinalResult = false;
    notifyListeners();

    try {
      final response = await _apiService.compact(
        CompactRequest(
          dimension: dimension,
          blocks: blocks,
          maxSteps: maxSteps,
        ),
      );
      result = response;
      currentStep = 0;
      _committedBlocks = response.initialBlocks.isNotEmpty
          ? List<BlockPosition>.from(response.initialBlocks)
          : List<BlockPosition>.from(blocks);
      apiStatus = ApiRunStatus.ready;
      notifyListeners();
      if (response.steps.isNotEmpty) {
        startAutoRun();
      }
    } on CompactApiException catch (error) {
      apiStatus = ApiRunStatus.error;
      errorMessage = error.message;
      notifyListeners();
    } catch (error) {
      apiStatus = ApiRunStatus.error;
      errorMessage = 'Unexpected error: $error';
      notifyListeners();
    }
  }

  void stepForward() {
    if (result == null || currentStep >= totalSteps || isAnimatingStep) {
      return;
    }
    _startStepAnimation();
  }

  void stepBack() {
    if (currentStep <= 0 || isAnimatingStep) {
      return;
    }
    _timer?.cancel();
    isRunning = false;
    currentStep--;
    _committedBlocks = _blocksAtStep(currentStep);
    _clearStepAnimation();
    notifyListeners();
  }

  void startAutoRun() {
    if (result == null || currentStep >= totalSteps) {
      return;
    }
    isRunning = true;
    if (!isAnimatingStep) {
      _startStepAnimation();
    }
    notifyListeners();
  }

  void replay() {
    if (result == null) {
      return;
    }
    pause();
    currentStep = 0;
    _committedBlocks = result?.initialBlocks.isNotEmpty == true
        ? List<BlockPosition>.from(result!.initialBlocks)
        : List<BlockPosition>.from(blocks);
    _clearStepAnimation();
    showFinalResult = false;
    notifyListeners();
    startAutoRun();
  }

  void pause() {
    if (!isAnimatingStep) {
      _timer?.cancel();
    }
    isRunning = false;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    isRunning = false;
    currentStep = 0;
    _committedBlocks = result?.initialBlocks.isNotEmpty == true
        ? List<BlockPosition>.from(result!.initialBlocks)
        : List<BlockPosition>.from(blocks);
    _clearStepAnimation();
    showFinalResult = false;
    notifyListeners();
  }

  void jumpToStep(int step) {
    _timer?.cancel();
    isRunning = false;
    currentStep = step.clamp(0, totalSteps);
    _committedBlocks = _blocksAtStep(currentStep);
    _clearStepAnimation();
    showFinalResult = false;
    notifyListeners();
  }

  void jumpToFinal() {
    _timer?.cancel();
    isRunning = false;
    currentStep = totalSteps;
    _committedBlocks = result?.finalBlocks.isNotEmpty == true
        ? List<BlockPosition>.from(result!.finalBlocks)
        : _blocksAtStep(totalSteps);
    _clearStepAnimation();
    showFinalResult = false;
    notifyListeners();
  }

  void setSpeedMs(int value) {
    speedMs = value.clamp(400, 700);
    notifyListeners();
  }

  void setShowFinalResult(bool value) {
    showFinalResult = value;
    notifyListeners();
  }

  void setShowAllLayers(bool value) {
    showAllLayers = value;
    notifyListeners();
  }

  Map<String, dynamic> exportPayload() {
    return result?.toJson() ??
        {
          'dimension': dimension,
          'blocks': blocks.map((block) => block.toJson()).toList(),
          'max_steps': maxSteps,
        };
  }

  Map<String, dynamic> finalConfigurationPayload() {
    final finalBlocks = result?.finalBlocks ?? currentBlocks;
    return {
      'dimension': dimension,
      'blocks': finalBlocks.map((block) => block.toJson()).toList(),
    };
  }

  List<BlockPosition> _blocksAtStep(int step) {
    final response = result;
    if (response == null) {
      return blocks;
    }
    if (step <= 0) {
      return response.initialBlocks.isNotEmpty
          ? response.initialBlocks
          : blocks;
    }
    final boundedStep = step.clamp(0, response.steps.length);
    var current = response.initialBlocks.isNotEmpty
        ? List<BlockPosition>.from(response.initialBlocks)
        : List<BlockPosition>.from(blocks);
    for (var index = 0; index < boundedStep; index++) {
      final move = response.steps[index];
      current = move.blocksAfter.isNotEmpty
          ? move.blocksAfter
          : CoordinateUtils.applyMove(current, move.from, move.to);
    }
    return current;
  }

  void _afterConfigurationChanged({bool syncJson = true}) {
    result = null;
    currentStep = 0;
    _timer?.cancel();
    _committedBlocks = null;
    _clearStepAnimation();
    isRunning = false;
    selectedBlock = null;
    showFinalResult = false;
    errorMessage = null;
    apiStatus = ApiRunStatus.ready;
    if (dimension == 3 && blocks.isNotEmpty) {
      final maxZ = blocks
          .map((block) => block.z)
          .reduce((a, b) => a > b ? a : b);
      layerCount = layerCount > maxZ + 1 ? layerCount : maxZ + 1;
    }
    if (syncJson) {
      _syncJson();
    }
    validation = InputValidator.validate(
      dimension: dimension,
      blocks: blocks,
      maxSteps: maxSteps,
    );
    notifyListeners();
  }

  void _syncJson() {
    jsonText = FormatUtils.prettyJson({
      'dimension': dimension,
      'blocks': blocks.map((block) => block.toJson()).toList(),
      'max_steps': maxSteps,
    });
  }

  void _startStepAnimation() {
    final response = result;
    if (response == null ||
        currentStep >= response.steps.length ||
        isAnimatingStep) {
      isRunning = false;
      notifyListeners();
      return;
    }

    activeStep = response.steps[currentStep];
    final subSteps = _axisAlignedSubSteps(
      activeStep!,
      _committedBlocks ?? currentBlocks,
    );
    if (subSteps.isEmpty) {
      _completeActiveStep(allowFallbackMove: true);
      return;
    }
    activeSubStepIndex = 0;
    activeSubStepCount = subSteps.length;
    activeSubStep = subSteps.first;
    animationProgress = 0;
    isAnimatingStep = true;
    showFinalResult = false;
    _runSubStepTimer();
    notifyListeners();
  }

  void _runSubStepTimer() {
    _stepStopwatch = Stopwatch()..start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final elapsed = _stepStopwatch?.elapsedMilliseconds ?? speedMs;
      final nextProgress = (elapsed / speedMs).clamp(0.0, 1.0);
      animationProgress = nextProgress;
      if (nextProgress >= 1.0) {
        _completeActiveSubStep();
      } else {
        notifyListeners();
      }
    });
  }

  void _completeActiveSubStep() {
    _timer?.cancel();
    _stepStopwatch?.stop();
    final subStep = activeSubStep;
    final step = activeStep;
    if (subStep == null || step == null) {
      _completeActiveStep(allowFallbackMove: false);
      return;
    }

    final base = _committedBlocks ?? currentBlocks;
    _committedBlocks = CoordinateUtils.applyMove(
      base,
      subStep.from,
      subStep.to,
    );

    final subSteps = _axisAlignedSubSteps(
      step,
      _committedBlocks ?? currentBlocks,
    );
    final nextIndex = activeSubStepIndex + 1;
    if (nextIndex >= subSteps.length) {
      _completeActiveStep(allowFallbackMove: false);
      return;
    }

    activeSubStepIndex = nextIndex;
    activeSubStepCount = subSteps.length;
    activeSubStep = subSteps[nextIndex];
    animationProgress = 0;
    isAnimatingStep = true;
    _runSubStepTimer();
    notifyListeners();
  }

  void _completeActiveStep({required bool allowFallbackMove}) {
    _timer?.cancel();
    _stepStopwatch?.stop();
    final step = activeStep;
    if (step == null) {
      isAnimatingStep = false;
      animationProgress = 0;
      notifyListeners();
      return;
    }

    _committedBlocks = step.blocksAfter.isNotEmpty
        ? List<BlockPosition>.from(step.blocksAfter)
        : allowFallbackMove
        ? CoordinateUtils.applyMove(
            _committedBlocks ?? currentBlocks,
            step.from,
            step.to,
          )
        : List<BlockPosition>.from(_committedBlocks ?? currentBlocks);
    currentStep++;
    _clearStepAnimation();

    if (currentStep >= totalSteps) {
      isRunning = false;
      notifyListeners();
      return;
    }

    notifyListeners();
    if (isRunning) {
      _startStepAnimation();
    }
  }

  List<MoveStep> _axisAlignedSubSteps(
    MoveStep step,
    List<BlockPosition> occupiedBlocks,
  ) {
    final from = step.from;
    final to = step.to;
    if (from == null || to == null || from.dimension != to.dimension) {
      return const [];
    }

    final path = _findCollisionFreeAxisPath(from, to, occupiedBlocks);
    if (path.length < 2) {
      return const [];
    }

    return [
      for (var index = 0; index < path.length - 1; index++)
        MoveStep(
          step: step.step,
          from: path[index],
          to: path[index + 1],
          type: step.type,
          potentialBefore: index == 0 ? step.potentialBefore : null,
          potentialAfter: index == path.length - 2 ? step.potentialAfter : null,
          connected: index == path.length - 2 ? step.connected : null,
          finished: index == path.length - 2 ? step.finished : null,
        ),
    ];
  }

  List<BlockPosition> _findCollisionFreeAxisPath(
    BlockPosition from,
    BlockPosition to,
    List<BlockPosition> occupiedBlocks,
  ) {
    final occupied = occupiedBlocks.toSet()..remove(from);
    final orders = from.dimension == 3
        ? const [
            [0, 1, 2],
            [0, 2, 1],
            [1, 0, 2],
            [1, 2, 0],
            [2, 0, 1],
            [2, 1, 0],
          ]
        : const [
            [0, 1],
            [1, 0],
          ];

    for (final order in orders) {
      final path = _buildAxisAlignedPath(from, to, order);
      if (_pathIsClear(path, occupied)) {
        return path;
      }
    }
    return const [];
  }

  List<BlockPosition> _buildAxisAlignedPath(
    BlockPosition from,
    BlockPosition to,
    List<int> axisOrder,
  ) {
    final path = <BlockPosition>[from];
    var current = from;

    for (final axis in axisOrder) {
      final next = switch (axis) {
        0 when current.x != to.x =>
          current.dimension == 3
              ? BlockPosition([to.x, current.y, current.z])
              : BlockPosition([to.x, current.y]),
        1 when current.y != to.y =>
          current.dimension == 3
              ? BlockPosition([current.x, to.y, current.z])
              : BlockPosition([current.x, to.y]),
        2 when current.dimension == 3 && current.z != to.z => BlockPosition([
          current.x,
          current.y,
          to.z,
        ]),
        _ => current,
      };
      if (next != current) {
        current = next;
        path.add(current);
      }
    }

    return path;
  }

  bool _pathIsClear(List<BlockPosition> path, Set<BlockPosition> occupied) {
    for (var index = 1; index < path.length; index++) {
      final from = path[index - 1];
      final to = path[index];
      for (final point in _axisSegmentCells(from, to)) {
        if (occupied.contains(point)) {
          return false;
        }
      }
    }
    return true;
  }

  List<BlockPosition> _axisSegmentCells(BlockPosition from, BlockPosition to) {
    final cells = <BlockPosition>[];
    final dx = to.x.compareTo(from.x);
    final dy = to.y.compareTo(from.y);
    final dz = to.z.compareTo(from.z);
    final distance =
        (to.x - from.x).abs() + (to.y - from.y).abs() + (to.z - from.z).abs();

    for (var step = 1; step <= distance; step++) {
      if (from.dimension == 3) {
        cells.add(
          BlockPosition([
            from.x + dx * step,
            from.y + dy * step,
            from.z + dz * step,
          ]),
        );
      } else {
        cells.add(BlockPosition([from.x + dx * step, from.y + dy * step]));
      }
    }
    return cells;
  }

  void _clearStepAnimation() {
    activeStep = null;
    activeSubStep = null;
    animationProgress = 0;
    activeSubStepIndex = 0;
    activeSubStepCount = 0;
    isAnimatingStep = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
