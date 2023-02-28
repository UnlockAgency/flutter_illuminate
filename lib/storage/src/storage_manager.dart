import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageManager {
  final String prefix;

  late FlutterSecureStorage _storage;

  StorageManager({
    required this.prefix,
    AndroidConfig? androidConfig,
    IOSConfig? iosConfig,
  }) {
    _storage = FlutterSecureStorage(
      iOptions: IOSOptions(
        groupId: iosConfig?.groupId,
        accountName: iosConfig?.accountName,
      ),
      aOptions: AndroidOptions(
          // TODO:check why it's not working
          // sharedPreferencesName: androidConfig?.sharedPreferencesName,
          // encryptedSharedPreferences: androidConfig?.encryptedSharedPreferences ?? false,
          // resetOnError: androidConfig?.resetOnError ?? false,
          ),
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
}

class AndroidConfig {
  final String? sharedPreferencesName;
  final bool encryptedSharedPreferences;
  final bool resetOnError;

  AndroidConfig({
    this.sharedPreferencesName,
    this.encryptedSharedPreferences = false,
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
