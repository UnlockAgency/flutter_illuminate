# Tracking

Making it easier for you to add Firebase Analytics to your app.

## Getting started

Make sure you have configured Firebase for your project. Events won't work if you haven't done so.

Register screens:

```dart
enum Screen implements Screenable {

    onboardingStart('Onboarding / Start'),
    dashboard('Dashboard');

    const Screen(this.name);

    @override
    final String name;
}
```

And events:

```dart
// Define all possible event names
enum EventName implements EventNameable {
    openSignIn('open_sign_in');
    
    const EventName(this.value);

    @override
    final String value;
}

// And create your events, with optional payload
class OpenSignInEvent implements Event {
    OpenSignInEvent();

    @override
    Map<String, dynamic>? get parameters => null;

    @override
    EventName get name => EventName.openSignIn;
}
```

And possibly user properties:

```dart
enum UserProperty implements UserPropertyable {
    locale(name: 'locale');

    const UserProperty({required this.name});

    @override
    final String name;
}
```

Then start tracking:

```dart
final manager = TrackingManager();
await manager.screenView(
    Screen.onboardingStart, 
    parameters: {
        'param': 'value',
    },
);

await manager.logEvent(OpenSignInEvent());

await manager.updateUserProperty(
    property: UserProperty.locale,
    value: 'nl_NL'
);
```

