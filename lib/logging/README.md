# Logging

## Getting started

If you'd like to log remotely to Google Cloud, create a service account at [the Google Cloud Console](https://console.cloud.google.com/) which has only the `Logs writer` permission.

Download the service account and store it in your `assets` folder, under for instance `assets/keys/service-account.json`.

Add the folder or file to your `pubspec.yaml` file:

```yaml
flutter:
  assets:
    - assets/keys/
```

## Usage

Create an instance of the logger and use it anywhere in your app.

```dart
// Optionally load the Google service account for remote logging
final serviceAccount = await rootBundle.loadString(
    'assets/keys/service-account.json',
);

// Get or create a unique id for this user
final loggingIdentifier = const Uuid().v4();

final logger = await Logging.createInstance(
    userIdentifier: loggingIdentifier,
    // Optionally define what levels need to be logged
    level: isRelease ? Level.nothing : Level.verbose,
    serviceAccount: serviceAccount,
);

// Log launch
PackageInfo packageInfo = await PackageInfo.fromPlatform();

final appName = packageInfo.appName;
final bundleIdentifier = packageInfo.packageName;
final version = packageInfo.version;
final buildNumber = packageInfo.buildNumber;

logger.i('''
---------------------------------------------
Launching $appName
    - Operating system: ${Platform.operatingSystem}
    - Locale: ${Foundation.platform.localeName}
    - Environment: ${config.flavor}
    - Bundle identifier: $bundleIdentifier
    - Version: $version
    - Build number: $buildNumber
---------------------------------------------
''');
```