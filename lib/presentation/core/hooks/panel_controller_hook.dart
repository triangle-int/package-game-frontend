import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

PanelController usePanelController() {
  return use(const _PanelControllerHook());
}

class _PanelControllerHook extends Hook<PanelController> {
  const _PanelControllerHook();

  @override
  _PanelControllerHookState createState() => _PanelControllerHookState();
}

class _PanelControllerHookState
    extends HookState<PanelController, _PanelControllerHook> {
  late final PanelController panelController;

  @override
  void initHook() {
    super.initHook();
    panelController = PanelController();
  }

  @override
  PanelController build(BuildContext context) {
    return panelController;
  }
}
