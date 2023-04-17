import 'package:flutter/foundation.dart';

abstract class Providable extends ChangeNotifier {
  ProviderStatus get status => _status;
  ProviderStatus _status = ProviderStatus.initial;

  void setStatus(ProviderStatus value) {
    _status = value;
    notifyListeners();
  }
}

enum ProviderStatus {
  initial,
  error,
  loading,
  updating,
  success;

  bool get isInitial => this == ProviderStatus.initial;
  bool get isError => this == ProviderStatus.error;
  bool get isLoading => this == ProviderStatus.loading;
  bool get isUpdating => this == ProviderStatus.updating;
  bool get isSuccess => this == ProviderStatus.success;
}
