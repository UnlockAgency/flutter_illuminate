import 'package:logger/logger.dart';
import 'package:illuminate/storage.dart';

final logger = Logger(
  printer: PrettyPrinter(
    colors: true,
    noBoxingByDefault: true,
    methodCount: 0,
  ),
);

const storageKeyAccessToken = "oauth_access_token";
const storageKeyRefreshToken = "oauth_refresh_token";

final storageManager = StorageManager(
  prefix: 'oauth',
);
