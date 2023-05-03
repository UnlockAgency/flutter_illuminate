# Security

Helping you secure the app with either pin code or biometric authentication.

## Getting started

Start by wrapping your `MaterialApp` in an `AppLock` widget.

```dart
class App extends StatelessWidget {
    @override 
    Widget build(BuildContext context) {
        return AppLock(
            // Instance of GoRouter
            router: _router, 
            // The route path of the lockscreen
            lockScreenRoute: '/lockscreen',
            // The route name of the lockscreen
            lockScreenRouteName: 'lockscreen', 
            // Disable the lockscreen in certain situations.
            // Like, when the user hasn't setup it yet.
            shouldTriggerLockScreen: () async {
                return await SecurityManager.instance.getSecurityType() != null;
            },
            // This allows you to trigger the lockscreen after a certain amount of time, 
            // instead of immediately when the app goes to the baqckground
            backgroundLockLatency: const Duration(seconds: 30),
            // Your MaterialApp
            child: MaterialApp.router(
                ...
            )
        );
    }
}
```

You need to provide a way for the user to configure the lockscreen.

```dart
final instance = SecurityManager.instance;

// Check if the device supports biometric authentication
if (instance.biometricAuthenticationAvailable) { 
    instance.setSecurityType(SecurityType.biometric);

} else { 
    instance.setSecurityType(SecurityType.pincode);
    instance.setSecurityCode('1234');
}
```

Validation:

```dart
final securityType = await instance.getSecurityType();

if (securityType == SecurityType.biometric) { 
    await instance.authenticateBiometrically(reason: 'Please authenticate using biometric authentication');
} else {
    final isValid = await instance.securityCodeIsValid('0000');
}
```