# Changelog

## 1.8.0

### Flutter upgrade
- Upgraded all packages to latest
- Removed deprecated code
- Added EdgeToEdgeWrapper

## 1.7.3

### Bugfixes
- Added an extra check to only fetch one refresh token at a time

## 1.7.2

### New features
- Allowing no token refresh option for oAuth

## v1.7.0

### New features
- Upgrades for web development
- Add possibility to disable triggering the lockscreen on launch

## v1.6.2

### Bugfix
- [UI] Pass along `strings`, `onCancel` and `padding` parameters to date- and timepicker

## v1.6.1

### Developer related
- Upgrade `flutter_secure_storage: ^9.0.0`
- Use a custom JSONTransformer for HTTP responses
- Implement the new status change listeners for lifecycle events

## v1.6.0

### Improvements
- Removed duplicate `logger` instances and start using the general one
- Replaced `DioError` with `DioException`

### Developer related
- Require `flutter: ^3.17`
- Require `dart: ^3.0.0`
- Upgrade `dio: ^5.0.0`
- Upgrade `illuminate: ^2.0.0`

### Breaking changes
- GoRouter migration from [6.0 to 7.0](https://docs.google.com/document/d/10Xbpifbs4E-zh6YE5akIO8raJq_m3FIXs6nUGdOspOg/edit)
- GoRouter migration from [8.0 to 9.0](https://docs.google.com/document/d/16plvWc9ablQsUs7w6bWDpTZ7PwMP4YUhV-qMQ3iljE0/edit)
- GoRouter migration from [9.0 to 10.0](https://docs.google.com/document/d/1vjupshmFJtfGSOppZxp7Tzkq7dotcLxCcpdluuNYe1o/edit)

## v1.5.2

### Improvements
- [Network] Adding an onTokenRefreshFailure listener
- [Network] Migrated onAuthenticationFailure to a delegate

### Bugfix
- [Logging] Check if a message is of String type before sending to Google Cloud Logging

## v1.5.1

### Bugfix
- [UI] Disabling back button functionality when barrierDismissable is false for dialogs

## v1.5.0

### New features
- [UI] Added MarkdownText widget

## v1.4.2

### Bugfix
- [UI] Don't reset the timer for the carousel when autoplay isn't enabled

## v1.4.1

### New features
- [UI] Added a CachedImage widget, for caching remote images

### Developer related
- [UI] Removed FadeInNetworkImage

## 1.4.0

### New features
- [Routing] Added UniversalLinkManager using uni_links

## 1.3.6

### Improvements
- [UI] Added error fallback widget to FadeInNetworkImage

## 1.3.4

### New features
- [UI] Added Carousel for widgets or images

## 1.3.3

### New features
- [Common] Added Tuple<A, B>
- [Common] Added Coordintes class and distance calculation

## 1.3.0

### Breaking changes
- Fixed storage key prefix for SecurityManager 
- Disabled encrypted shared preferences for Android secure storage, it now uses KeyStore by default

### Developer related
- Added README's to all components

## 1.2.4

### New features
Added TrackingService to package


## 1.0.0

### New features
Initial setup
