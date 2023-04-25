import 'package:illuminate/logging.dart';
import 'package:logger/logger.dart';

final logger = Logging.instance ??
    Logger(
      printer: PrettyPrinter(
        colors: true,
        noBoxingByDefault: true,
        methodCount: 0,
      ),
    );
