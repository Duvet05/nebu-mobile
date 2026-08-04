# wifi_scan_android

Android-only local fork of
[wifi_scan 0.4.1+2](https://pub.dev/packages/wifi_scan), retained under its
original MIT license.

The upstream iOS implementation is only a stub because iOS does not expose an
API for enumerating nearby Wi-Fi networks. Removing that no-op platform keeps
the Nebu iOS dependency graph fully on Swift Package Manager and avoids a
CocoaPods requirement without removing working functionality.
