import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:illuminate/storage.dart';

const storageKeyAccessToken = "oauth_access_token";
const storageKeyRefreshToken = "oauth_refresh_token";
const storageKeyTokenExpirationDate = "oauth_access_token_expiration_date";

final storageManager = StorageManager(
  prefix: 'oauth',
  iosConfig: IOSConfig(
    accessibility: KeychainAccessibility.first_unlock,
  ),
);
