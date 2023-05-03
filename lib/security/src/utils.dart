import 'package:logger/logger.dart';
import 'package:illuminate/storage.dart';

final logger = Logger(
  printer: PrettyPrinter(
    colors: true,
    noBoxingByDefault: true,
    methodCount: 0,
  ),
);

final storageManager = StorageManager(
  prefix: 'illuminate_security',
);
