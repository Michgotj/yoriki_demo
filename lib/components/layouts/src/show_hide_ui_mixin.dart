import 'package:flutter/widgets.dart';

mixin ShowHideUIMixin<T extends StatefulWidget> on State<T> {

  bool _isUIVisible = true;

  void showUI() {
    if (mounted) {
      setState(() {
        _isUIVisible = true;
      });
    }
  }

  void hideUI() {
    if (mounted) {
      setState(() {
        _isUIVisible = false;
      });
    }
  }

  void toggleUI() {
    if (mounted) {
      setState(() {
        _isUIVisible = !_isUIVisible;
      });
    }
  }

  bool get isUIVisible => _isUIVisible;

}