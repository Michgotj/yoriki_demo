import 'dart:async';

import 'package:flutter/material.dart';

enum ActivityTransition { becameActive, becameInactive }

class UserActivityDetector extends StatefulWidget {
  final Widget child;
  final Function(ActivityTransition) onActivityChanged;
  final Duration activityTimeout;

  const UserActivityDetector({
    super.key,
    required this.child,
    required this.onActivityChanged,
    required this.activityTimeout,
  });

  @override
  State<UserActivityDetector> createState() {
    return _UserActivityDetectorState();
  }
}

class _UserActivityDetectorState extends State<UserActivityDetector> {
  Timer? _uiTimer;

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        _stopTimer();
        widget.onActivityChanged(ActivityTransition.becameActive);
      },
      onPointerUp: (_) => _startTimer(),
      onPointerCancel: (_) => _startTimer(),
      child: widget.child,
    );
  }

  void _startTimer() {
    _uiTimer?.cancel();
    _uiTimer = Timer(
      widget.activityTimeout,
      () => widget.onActivityChanged(
        ActivityTransition.becameInactive,
      ),
    );
  }

  void _stopTimer() {
    _uiTimer?.cancel();
    _uiTimer = null;
  }
}
