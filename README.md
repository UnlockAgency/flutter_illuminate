# Illuminate

Created to remove boilerplate from your Flutter projects.

## Getting started

### Installation

Manually add the package to your `pubspec.yaml` file in the root of your project:

```yaml
dependencies:
  ...
  illuminate:
    git:
      url: git@github.com:UnlockAgency/flutter_illuminate.git
      # ref can be any valid Git reference: commit, branch, tag
      ref: v1.2.4
```

Saving the file in Visual Studio will automatically update dependencies. Otherwise run: `flutter pub get` in the root of your project.

### Usage

You're now able to use all of the components in your project:

```dart
import 'package:illuminate/ui.dart';

class App extends StatelessWidget { 
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            child: SpacedColumn(
                spacing: 12.0,
                children: [
                    Text('Title'),
                    // SpacedColumn adds spacing between these widgets.
                    Text('Content',)
                ]
            ),
        );
    }
}
```

### Local development

Thinking about expanding Illuminate, or does it need a bugfix? Change the package reference in your `pubspec.yaml` file:

```yaml
dependencies:
  ...
  illuminate:
    # Update to your locally checked out version of the repo
    path: ../packages/illuminate/
```

Running `flutter pub get` will instll your local version of the package. 

When hot reloading or restarting the app (`r` or `SHIFT + r`), will reflect the changes you made in the local package.

When you want to inspect your changes during development in your editor, you should open and save the `pubspec.yaml` file in Visual Studio or run `flutter pub get`.

Done? Commit and push the changes to Github and create a new release including tag and update your `ref`. 

## illuminate/common

Extensions or helper methods to use inside your project. 

[README](common/README.md)

## illuminate/core

Access core functionality of the app, for instance the current lifecycle state.

[README](core/README.md)

## illuminate/logging



[README](logging/README.md)