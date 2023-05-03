import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:illuminate/routing/src/utils.dart';

class DynamicLinkManager {
  static DynamicLinkManager? _instance;
  static DynamicLinkManager? get instance {
    return _instance;
  }

  DynamicLinkManager._({PendingDynamicLinkData? initialDynamicLinkData}) {
    _initialDynamicLinkData = initialDynamicLinkData;

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      _delegate?.didReceiveDynamicLink(dynamicLinkData);
    }).onError((error) {
      logger.e(error);
    });
  }

  DynamicLinkDelegate? _delegate;
  PendingDynamicLinkData? _initialDynamicLinkData;

  static Future<DynamicLinkManager> getInstance() async {
    if (_instance != null) {
      return _instance!;
    }

    final initialDynamicLinkData = await FirebaseDynamicLinks.instance.getInitialLink();

    _instance = DynamicLinkManager._(
      initialDynamicLinkData: initialDynamicLinkData,
    );

    return _instance!;
  }

  void setDelegate(DynamicLinkDelegate delegate) {
    _delegate = delegate;

    if (_initialDynamicLinkData != null) {
      _delegate?.didLaunchThroughDynamicLink(_initialDynamicLinkData!);
    }
  }
}

mixin DynamicLinkDelegate {
  void didLaunchThroughDynamicLink(PendingDynamicLinkData data);

  void didReceiveDynamicLink(PendingDynamicLinkData data);
}
