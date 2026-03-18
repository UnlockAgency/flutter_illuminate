import 'package:illuminate/logging.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

final logger =
    Logging.instance ??
    Logger(
      level: (kIsWeb && kReleaseMode) ? Level.error : Level.trace,
      printer: PrettyPrinter(colors: true, noBoxingByDefault: true, methodCount: 0),
    );
