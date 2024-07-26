# lightmachine

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.







##Desktop solution based on Chromium Embedded Framework
https://github.com/hlwhl/webview_cef

#Run for mac:
1. Download and place precompiled framework for macOs according instruction https://github.com/hlwhl/webview_cef
pay attention: according to instruction you should place files to the directory /macos of plugin - not the project
2. Run fix_cocoapods_macos.sh
3. Because of cocoapods bug, in the files:
'macos/Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig',
'macos/Pods/Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig',
'macos/Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig',
replace strings
'-ObjC Embedded Framework ' to ''
'-framework "Chromium"' to '-framework "Chromium Embedded Framework"'

or run dart run fix_chromium.dart

4. Run

#Run on Windows
1. flutter clean
2. flutter pub get
3. Run