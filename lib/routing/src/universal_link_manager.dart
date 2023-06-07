import 'package:flutter/services.dart';
import 'package:illuminate/routing/src/utils.dart';
import 'package:uni_links/uni_links.dart';

class UniversalLinkManager {
  static UniversalLinkManager? _instance;
  static UniversalLinkManager? get instance {
    return _instance;
  }

  UniversalLinkManager._({Uri? initialUri}) {
    _initialUri = initialUri;

    uriLinkStream.listen((Uri? uri) {
      if (uri == null) {
        return;
      }

      _delegate?.didReceiveUniversalLink(uri);
    }).onError((error, stacktrace) {
      logger.e('$_tag Error retrieving initial universal link', error, stacktrace);
    });
  }

  static const _tag = '[UniversalLinkManager] =>';

  UniversalLinkDelegate? _delegate;
  Uri? _initialUri;

  static Future<UniversalLinkManager> getInstance() async {
    if (_instance != null) {
      return _instance!;
    }

    Uri? initialUri;

    try {
      initialUri = await getInitialUri();
    } on PlatformException catch (error) {
      logger.e(error);
    }

    _instance = UniversalLinkManager._(
      initialUri: initialUri,
    );

    return _instance!;
  }

  void setDelegate(UniversalLinkDelegate delegate) {
    _delegate = delegate;

    if (_initialUri != null) {
      _delegate?.didLaunchThroughUniversalLink(_initialUri!);
    }
  }
}

mixin UniversalLinkDelegate {
  void didLaunchThroughUniversalLink(Uri uri);

  void didReceiveUniversalLink(Uri uri);
}
