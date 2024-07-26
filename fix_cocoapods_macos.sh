#! /bin/sh
flutter clean

rm -Rf macos/Podfile.lock
rm -Rf macos/Pods
rm -Rf macos/.symlinks
rm -Rf macos/Flutter/ephemeral

flutter pub get

cd macos || exit
pod install --repo-update
cd .. || exit

