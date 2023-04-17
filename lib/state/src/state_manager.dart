import 'package:flutter/material.dart';

class StateManager {
  static StateManager? _instance;
  static StateManager get instance {
    return _instance ??= StateManager._();
  }

  StateManager._() {
    //
  }

  Widget? _errorWidget;
  Widget? get errorWidget => _errorWidget;

  Widget? _loadingWidget;
  Widget? get loadingWidget => _loadingWidget;

  void registerLoadingWidget(Widget widget) {
    _loadingWidget = widget;
  }

  void registerErrorWidget(Widget widget) {
    _errorWidget = widget;
  }
}
