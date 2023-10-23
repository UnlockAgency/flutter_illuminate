# Foundation

## Getting started
When building a Flutter app for iOS and Android, you often find yourself using `dart:io` to check which platform the app is running for. 

```dart
import 'dart:io';

print("I'm running on Android: ${Platform.isAndroid}");
print("I'm running on iOS: ${Platform.isIOS}");
```

However, when also including the web platform in your app, it's going to crash when importing the `io` library. This library isn't available when running the app in the browser.

We've solved this using conditional imports. 

```dart
import 'stubbed_file.dart'
    if (dart.library.io) 'logic_io.dart'
    if (dart.library.html) 'logic_web.dart';
```

We're importing a `stubed_file.dart`, which is a fallback, because we're also checking if we're able to load the `io` library. If so, that file is going to be imported instead. The same goes for the `html` library. When both of the libraries are missing, the `stubbed_file.dart` is exported. 

In the `*_io.dart` and `*_web.dart` files, we're able to import `dart:io` and `dart:html`. 

### Identifiying the platform

Instead of:

```dart
final isAndroid = Platform.isAndroid;
```

Use: 

```dart
Platform platform = Foundation.platform.current;
final isAndroid = Foundation.platform.isAndroid;
final isIOS = Foundation.platform.isIOS;
final isWeb = Foundation.platform.isWeb;
```