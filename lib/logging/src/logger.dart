import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:googleapis/logging/v2.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:illuminate/common/src/helpers.dart';
import 'package:illuminate/logging.dart';
import 'package:logger/logger.dart';

class Logging {
  static Logger? _logger;
  static Logger? get instance {
    return _logger;
  }

  static bool get hasInstance => _logger != null;

  static Future<Logger> createInstance({
    required String userIdentifier,
    Level level = Level.verbose,
    String? serviceAccount,
    Map<String, String>? metadata,
  }) async {
    if (_logger != null) {
      return _logger!;
    }

    print('Setting up logger..');

    _logger = Logger(
      filter: LoggingFilter(logLevel: level),
      printer: PrettyPrinter(
        // Disable colors for iOS (rendering doesn't work properly) and also for release builds
        colors: kDebugMode && Platform.isAndroid,
        noBoxingByDefault: true,
        methodCount: 0,
        printTime: true,
        lineLength: 300,
      ),
    );

    _logger?.i('[Logging] => Setup successfully');

    if (serviceAccount != null) {
      _logger?.i('[Logging] => Setting up cloud logging..');

      final cloudLogger = CloudLogger(id: userIdentifier);
      await cloudLogger.initialize(serviceAccount);

      Logger.addLogListener((event) {
        if (event.message is! String) {
          return;
        }

        cloudLogger.logEvent(event.message, labels: metadata);
      });
    }

    return _logger!;
  }
}

class LoggingFilter extends LogFilter {
  LoggingFilter({required this.logLevel}) : super();

  final Level logLevel;

  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= logLevel.index;
  }
}

class CloudLogger {
  CloudLogger({required this.id});

  final String id;

  LoggingApi? _cloudLogger;
  Map<String, dynamic>? _serviceAccount;

  Future<void> initialize(String serviceAccount) async {
    _serviceAccount = tryCast<Map<String, dynamic>>(jsonDecode(serviceAccount));
    if (_serviceAccount == null) {
      throw InvalidServiceAccountException(message: 'The service account could not be parsed to a Map<String, dynamic>');
    }

    final httpClient = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(_serviceAccount),
      [LoggingApi.loggingWriteScope],
    );

    _cloudLogger = LoggingApi(httpClient);
  }

  Future<void> logEvent(String message, {Map<String, String>? labels = const {}}) async {
    final projectId = tryCast<String>(_serviceAccount?['project_id']);
    if (_cloudLogger == null || projectId == null) {
      return;
    }

    final params = {
      'id': id,
    }..addAll(labels ?? {});

    final logEntry = LogEntry(
      logName: 'projects/$projectId/logs/app',
      jsonPayload: {
        'message': message,
      },
      resource: MonitoredResource(
        type: 'global',
      ),
      labels: params,
    );

    final request = WriteLogEntriesRequest(
      entries: [logEntry],
    );

    _cloudLogger!.entries.write(request);
  }
}
