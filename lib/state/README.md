# State

Extending the popular state management library `Provider`.

## Getting started

Start by creating a providable class:

```dart
class ProfileProvider extends Providable { 
    final _apiClient = ApiClient();

    Profile? _profile;
    Profile? get profile => _profile;

    Future<void> load() async { 
        setStatus(ProviderStatus.loading);

        try {
            _profile = await _apiClient.getProfile();
        } catch(error) { 
            setStatus(ProviderStatus.error);
            return;
        }
        
        setStatus(ProviderStatus.success);
    }
}
```

Then register it inside your app:

```dart
class App extends StatelessWidget { 
    @override
    Widget build(BuildContext context) { 
        return ChangeNotifierProvider<ProfileProvider>(
            create: (_) => ProfileProvider()..load(),
            child: Column(
                children: [
                    Text('Title of the view, never updated'),

                    // The consumer of the provider
                    Consumable<ProfileProvider>(
                        builder: (context, provider) {
                            return Text(provider.profile.name);
                        },
                    ),
                ],
            ),
        );
    }
}
```

The `Consumable` widget provides basic loading, error and update states. You can override these per `Consumable` widget, like:

```dart
Consumable<ProfileProvider>(
    // Loading state:
    loadingBuilder: (context, provider) {
        return SkeletonCard(height: 75.0);
    },

    // Error state:
    errorBuilder: (context, provider) {
        return Column(
            children: [
                Text('Something went wrong'),

                TextButton(
                    onPressed: () {
                        provider.load();
                    },
                    child: Text('Retry'),
                ),
            ]
        );
    },

    // Successful state:
    builder: (context, provider) {
        return Text(provider.profile.name);
    },
),
```

However, defining these custom state widgets causes a lot of maintenance when you would want to update these. You could also override the defaults using the `StateManager`:

```dart
StateManager.instance.registerLoadingWidget(
    SkeletonCard(height: 75.0),
);

StateManager.instance.registerErrorWidget(
    Column(
        children: [
            Text('Something went wrong'),
        ],
    ),
);
```