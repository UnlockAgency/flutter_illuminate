# Storage

Providing a basic interaction layer for both Android and iOS secure storage implementations.

> Keychain is used for iOS. AES encryption is used for Android. AES secret key is encrypted with RSA and RSA key is stored in KeyStore.

## Getting started

Initialize a `StorageManager` and get to work:

```dart
final instance = StorageManager(
    prefix: 'app_name',
    iosConfig: IOSConfig(),
    androidConfig: AndroidConfig(),
);

// You can pass along these options:
class AndroidConfig {
  final bool resetOnError;

  AndroidConfig({
    this.resetOnError = false,
  });
}

class IOSConfig {
  final String? groupId;
  final String? accountName;
  final KeychainAccessibility accessibility;
  final bool synchronizable;

  IOSConfig({
    this.groupId,
    this.accountName = AppleOptions.defaultAccountName,
    this.accessibility = KeychainAccessibility.unlocked,
    this.synchronizable = false,
  });
}
```

Then read and write using:

```dart
await instance.write('string_key', 'value');
String? value = await instance.read('string_key');

await instance.writeJson('json_key', {'key': 'value'});
Map<String, dynamic>? json = await instance.readJson('json_key');

// Single key deletion
await instance.delete('string_key'); 

// Delete all
await instance.deleteAll();
```