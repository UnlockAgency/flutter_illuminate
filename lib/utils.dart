import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    colors: true,
    noBoxingByDefault: true,
    methodCount: 0,
  ),
);
