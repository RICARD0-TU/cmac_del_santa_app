import 'package:flutter/widgets.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  AppLifecycleObserver({required this.onResumed, required this.onPaused});

  final VoidCallback onResumed;
  final VoidCallback onPaused;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        onPaused();
    }
  }
}
