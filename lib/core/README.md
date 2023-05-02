# Core

## Usage
Register the observer using for instance `get_it` and use it like the example below:

```dart
class App extends StatelessWidget
    late final _lifecycleStateObserver = getIt<AppLifecycleStateObserver>();

    Widget build(BuildContext context) {
        return MaterialApp(
            child: Screen(),
        );
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
        // Pass updates to the observer
        _lifecycleStateObserver.didChange(state);

        super.didChangeAppLifecycleState(state);
    }
}

class Screen extends StatelessWidget
    late final _lifecycleStateObserver = getIt<AppLifecycleStateObserver>();

    Widget build(BuildContext context) {
        return Scaffold(
            child: Center(
                // Get the current AppLifecycleState
                child: Text(_lifecycleStateObserver.current),
            ),
        );
    }
}
```