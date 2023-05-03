# Routing

Helping you parse the dynamic links your app can receive.

## Get started

```dart
final dynamicLinkManager = await DynamicLinkManager.getInstance();

class App extends StatelessWidget implements DynamicLinkDelegate { 
    @override
    Widget build(BuildContext context) { 
        DynamicLinkManager.getInstance((instance) { 
            // Register the App as delegate for dynamic links
            instance.setDelegate(this);
        });

        return MaterialApp(
            child: Text('App'),
        );
    }

    @override
    void didLaunchThroughDynamicLink(PendingDynamicLinkData data) { 
        handleIncomingDynamicLinks(data: data);
    }

    @override
    void didReceiveDynamicLink(PendingDynamicLinkData data) { 
        handleIncomingDynamicLinks(data: data);
    }

    Future<void> handleIncomingDynamicLinks({required PendingDynamicLinkData data}) async {
        // Do something with the data
        final path = data.link.path;
    }
}
```