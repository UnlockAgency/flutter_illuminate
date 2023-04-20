import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:illuminate/routing/src/utils.dart';

class DynamicLinkManager {
  static DynamicLinkManager? _instance;
  static DynamicLinkManager get instance {
    return _instance ??= DynamicLinkManager._();
  }

  DynamicLinkManager._() {
    _initialize();
  }

  DynamicLinkDelegate? _delegate;
  PendingDynamicLinkData? _initialDynamicLinkData;

  Future<void> _initialize() async {
    _initialDynamicLinkData = await FirebaseDynamicLinks.instance.getInitialLink();

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      _delegate?.didReceiveDynamicLink(dynamicLinkData);
    }).onError((error) {
      logger.e(error);
    });
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
