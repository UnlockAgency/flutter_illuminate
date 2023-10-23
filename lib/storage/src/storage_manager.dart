import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageManager {
  final String prefix;

  late FlutterSecureStorage _storage;

  StorageManager({
    required this.prefix,
    AndroidConfig? androidConfig,
    IOSConfig? iosConfig,
    WebConfig? webConfig,
  }) {
    _storage = FlutterSecureStorage(
      iOptions: IOSOptions(
        groupId: iosConfig?.groupId,
        accountName: iosConfig?.accountName,
        accessibility: iosConfig?.accessibility ?? KeychainAccessibility.unlocked,
      ),
      aOptions: AndroidOptions(
        sharedPreferencesName: null,
        encryptedSharedPreferences: false,
        resetOnError: androidConfig?.resetOnError ?? false,
      ),
      webOptions: webConfig != null
          ? WebOptions(
              dbName: webConfig.dbName,
              publicKey: webConfig.publicKey,
            )
          : WebOptions.defaultOptions,
    );
  }

  String _key(String key) {
    return '${prefix}_$key';
  }

  Future<String?> read(String key) async {
    return await _storage.read(
      key: _key(key),
    );
  }

  Future<Map<String, dynamic>?> readJson(String key) async {
    String? contents = await _storage.read(
      key: _key(key),
    );

    if (contents == null) {
      return null;
    }

    return jsonDecode(contents);
  }

  Future<void> write(String key, String? value) async {
    return await _storage.write(
      key: _key(key),
      value: value,
    );
  }

  Future<void> writeJson(String key, Map<String, dynamic>? value) async {
    return await _storage.write(
      key: _key(key),
      value: jsonEncode(value),
    );
  }

  Future<void> delete(String key) async {
    return await _storage.delete(
      key: _key(key),
    );
  }

  Future<void> deleteAll() async {
    return await _storage.deleteAll();
  }
}

class AndroidConfig {
  AndroidConfig({
    this.resetOnError = false,
  });

  final bool resetOnError;
}

class IOSConfig {
  IOSConfig({
    this.groupId,
    this.accountName = AppleOptions.defaultAccountName,
    this.accessibility = KeychainAccessibility.unlocked,
    this.synchronizable = false,
  });

  final String? groupId;
  final String? accountName;
  final KeychainAccessibility accessibility;
  final bool synchronizable;
}

class WebConfig {
  const WebConfig({
    required this.dbName,
    required this.publicKey,
  });

  final String dbName;
  final String publicKey;
}
