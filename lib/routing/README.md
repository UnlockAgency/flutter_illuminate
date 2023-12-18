# Routing

Helping you parse the dynamic links your app can receive.

## Get started

### Dynamic Links

```dart
class App extends StatelessWidget implements DynamicLinkDelegate { 
    @override
    Widget build(BuildContext context) { 
        DynamicLinkManager.getInstance().then((instance) { 
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

### Universal Links

```dart
class App extends StatelessWidget implements UniversalLinkDelegate { 
    @override
    Widget build(BuildContext context) { 
        UniversalLinkManager.getInstance().then((instance) { 
            // Register the App as delegate for dynamic links
            instance.setDelegate(this);
        });

        return MaterialApp(
            child: Text('App'),
        );
    }

    @override
    void didLaunchThroughUniversalLink(Uri uri) { 
        handleIncomingUniversalLinks(uri: uri);
    }

    @override
    void didReceiveUniversalLink(Uri uri) { 
        handleIncomingDynamicLinks(uri: uri);
    }

    Future<void> handleIncomingUniversalLinks({required Uri uri}) async {
        // Do something with the data
        final path = uri.path;
    }
}
```