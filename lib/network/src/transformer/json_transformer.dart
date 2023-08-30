import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:illuminate/utils.dart';

class JSONTransformer extends SyncTransformer {
  JSONTransformer() : super(jsonDecodeCallback: _decodeJson);
}

Future<dynamic> _decodeJson(String response) async {
  try {
    // Taken from https://github.com/flutter/flutter/blob/135454af32477f815a7525073027a3ff9eff1bfd/packages/flutter/lib/src/services/asset_bundle.dart#L87-L93
    // 50 KB of data should take 2-3 ms to parse on a Moto G4, and about 400 μs on a Pixel 4.
    if (response.codeUnits.length < 50 * 1024) {
      return jsonDecode(response);
    }

    // For strings larger than 50 KB, run the computation in an isolate to
    // avoid causing main thread jank.
    return await compute(jsonDecode, response);
  } on FormatException catch (_) {
    return {};
  } catch (e, stacktrace) {
    logger.e('Error decoding response', error: e, stackTrace: stacktrace);
  }
}
