import 'package:flutter/material.dart';

import '../controllers/simulation_controller.dart';
import '../widgets/app_header.dart';
import '../widgets/panels/bottom_analytics_panel.dart';
import '../widgets/panels/center_visualization_panel.dart';
import '../widgets/panels/left_config_panel.dart';
import '../widgets/panels/right_inspector_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SimulationController _controller;
  bool _showConfiguration = true;
  bool _showInspector = true;
  bool _fullscreenVisualization = false;
  bool _showAnalytics = false;

  @override
  void initState() {
    super.initState();
    _controller = SimulationController();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          body: Column(
            children: [
              AppHeader(controller: _controller),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 1200;
                    final isMobile = constraints.maxWidth < 800;
                    if (isMobile) {
                      final showMobilePanels = !_fullscreenVisualization;
                      return ListView(
                        padding: const EdgeInsets.all(14),
                        children: [
                          CenterVisualizationPanel(
                            controller: _controller,
                            isConfigurationVisible: _showConfiguration,
                            isInspectorVisible: _showInspector,
                            isFullscreen: _fullscreenVisualization,
                            onToggleConfiguration: () => setState(
                              () => _showConfiguration = !_showConfiguration,
                            ),
                            onToggleInspector: () => setState(
                              () => _showInspector = !_showInspector,
                            ),
                            onToggleFullscreen: () => setState(
                              () => _fullscreenVisualization =
                                  !_fullscreenVisualization,
                            ),
                          ),
                          if (showMobilePanels) ...[
                            const SizedBox(height: 16),
                            if (_showConfiguration) ...[
                              LeftConfigPanel(controller: _controller),
                              const SizedBox(height: 16),
                            ],
                            if (_showInspector) ...[
                              RightInspectorPanel(controller: _controller),
                              const SizedBox(height: 16),
                            ],
                            _AnalyticsToggle(
                              expanded: _showAnalytics,
                              onPressed: () => setState(
                                () => _showAnalytics = !_showAnalytics,
                              ),
                            ),
                            if (_showAnalytics) ...[
                              const SizedBox(height: 8),
                              BottomAnalyticsPanel(
                                controller: _controller,
                                isDesktop: false,
                              ),
                            ],
                          ],
                        ],
                      );
                    }

                    final showConfig =
                        _showConfiguration && !_fullscreenVisualization;
                    final showInspector =
                        _showInspector && !_fullscreenVisualization;
                    final showAnalytics =
                        _showAnalytics && !_fullscreenVisualization;

                    if (!isWide) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: CenterVisualizationPanel(
                                controller: _controller,
                                isConfigurationVisible: showConfig,
                                isInspectorVisible: showInspector,
                                isFullscreen: _fullscreenVisualization,
                                onToggleConfiguration: () => setState(
                                  () =>
                                      _showConfiguration = !_showConfiguration,
                                ),
                                onToggleInspector: () => setState(
                                  () => _showInspector = !_showInspector,
                                ),
                                onToggleFullscreen: () => setState(
                                  () => _fullscreenVisualization =
                                      !_fullscreenVisualization,
                                ),
                              ),
                            ),
                            if (!_fullscreenVisualization) ...[
                              const SizedBox(height: 10),
                              _AnalyticsToggle(
                                expanded: _showAnalytics,
                                onPressed: () => setState(
                                  () => _showAnalytics = !_showAnalytics,
                                ),
                              ),
                              if (showAnalytics) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 176,
                                  child: BottomAnalyticsPanel(
                                    controller: _controller,
                                    isDesktop: true,
                                  ),
                                ),
                              ],
                              if (showConfig || showInspector) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 280,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (showConfig)
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: LeftConfigPanel(
                                              controller: _controller,
                                            ),
                                          ),
                                        ),
                                      if (showConfig && showInspector)
                                        const SizedBox(width: 12),
                                      if (showInspector)
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: RightInspectorPanel(
                                              controller: _controller,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showConfig) ...[
                            SizedBox(
                              width: 300,
                              child: SingleChildScrollView(
                                child: LeftConfigPanel(controller: _controller),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: CenterVisualizationPanel(
                                    controller: _controller,
                                    isConfigurationVisible: showConfig,
                                    isInspectorVisible: showInspector,
                                    isFullscreen: _fullscreenVisualization,
                                    onToggleConfiguration: () => setState(
                                      () => _showConfiguration =
                                          !_showConfiguration,
                                    ),
                                    onToggleInspector: () => setState(
                                      () => _showInspector = !_showInspector,
                                    ),
                                    onToggleFullscreen: () => setState(
                                      () => _fullscreenVisualization =
                                          !_fullscreenVisualization,
                                    ),
                                  ),
                                ),
                                if (!_fullscreenVisualization) ...[
                                  const SizedBox(height: 10),
                                  _AnalyticsToggle(
                                    expanded: _showAnalytics,
                                    onPressed: () => setState(
                                      () => _showAnalytics = !_showAnalytics,
                                    ),
                                  ),
                                  if (showAnalytics) const SizedBox(height: 8),
                                  if (showAnalytics)
                                    SizedBox(
                                      height: 176,
                                      child: BottomAnalyticsPanel(
                                        controller: _controller,
                                        isDesktop: true,
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                          if (showInspector) ...[
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 300,
                              child: SingleChildScrollView(
                                child: RightInspectorPanel(
                                  controller: _controller,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _AnalyticsToggle extends StatelessWidget {
  const _AnalyticsToggle({required this.expanded, required this.onPressed});

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
        ),
        label: Text(expanded ? 'Hide analytics' : 'Show analytics'),
      ),
    );
  }
}
