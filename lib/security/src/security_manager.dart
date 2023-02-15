library security;

import 'package:illuminate/security/src/types/security_type.dart';
import 'package:illuminate/security/src/types/storage_key.dart';
import 'package:local_auth/local_auth.dart';
import 'package:illuminate/security/src/utils.dart';

class SecurityManager {
  static SecurityManager? _instance;
  static SecurityManager get instance {
    return _instance ??= SecurityManager._();
  }

  final LocalAuthentication _auth = LocalAuthentication();

  SecurityManager._() {
    //
  }

  void setSecurityType(SecurityType type) {
    storageManager.write(StorageKey.securityType.value, type.value);
  }

  Future<SecurityType?> getSecurityType() async {
    String? type = await storageManager.read(StorageKey.securityType.value);

    if (type == null) {
      return null;
    }

    return SecurityType.fromString(type);
  }

  Future<bool> get biometricAuthenticationAvailable async {
    if (!await _auth.canCheckBiometrics) {
      return false;
    }

    // Check if the user has setup biometric authentication on the device
    final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
    if (availableBiometrics.isEmpty) {
      return false;
    }

    return true;
  }

  Future<bool> authenticateBiometrically({String reason = 'Please authenticate to continue in the app'}) {
    return _auth.authenticate(
      localizedReason: reason,
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }

  Future<void> setSecurityCode(String code) async {
    await storageManager.write(StorageKey.pincode.value, code);
  }

  Future<bool> securityCodeIsValid(String code) async {
    String? savedCode = await storageManager.read(StorageKey.pincode.value);
    if (savedCode == null) {
      logger.d("No pincode stored in storage");
      return false;
    }

    return code == savedCode;
  }
}
