import 'dart:io';

// Fix for package:webview_cef, see https://github.com/hlwhl/webview_cef/issues/27
void main() {

  print('Start fixing xcconfigs');
  const List paths = [
    'macos/Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig',
    'macos/Pods/Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig',
    'macos/Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig',
  ];

  for (final path in paths) {
    File(path).writeAsStringSync(
      File(path)
          .readAsStringSync()
          .replaceAll('-ObjC Embedded Framework ', '')
          .replaceAll('-framework "Chromium"', '-framework "Chromium Embedded Framework"'),
    );
  }

  print('Done fixing xcconfig.');
}