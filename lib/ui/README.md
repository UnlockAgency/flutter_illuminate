# UI

Basic widgets or UI managers to remove boilerplate code.

## Getting started

### Widgets 

#### Controls

```dart
// A gesture detector with alpha animation onPressDown
SimpleGestureDetector({
    onTap: () {
        //
    },
    enabled: true,
    config: GestureDetectorConfig(
        mode: GestureDetectorMode.opacity,
    ),
    child: Text('Title'),
);
```

```dart
// For Android: A Material Inkwell, for iOS: SimpleGestureDetector
const Tappable({
    onTap: () {
        //
    },
    gestureDetectorConfig: GestureDetectorConfig(
        mode: GestureDetectorMode.opacity,
    ),
    child: Text('Title'),
});
```

#### Flex

```dart
// Adds spacing between elements
SpacedColumn(
    spacing: 16.0,
    children: [
        Text('Title'),
        Text('Content'),
    ]
);

SpacedRow(
    spacing: 16.0,
    children: [
        Text('Title'),
        Text('Content'),
    ]
);
```

#### Miscellaneous

```dart
bool userHasPressedButton = false;

// When it should be hidden, the provided width and/or height is still reserved in the widget tree
DimensionsReservedBox(
    isVisible: userHasPressedButton,
    height: 75.0,
    child: Text('Reserved space'),
);
```

```dart
// Display a loading indicator overlay
LoadingStack(
    isLoading: false,
    child: Column(
        children: [
            Title('Title'),
            Title('Content'),
        ],
    ),
);
```

```dart
// Add edge fading to the top and bottom of a scroll view
ScrollViewShaderMask(
    stops: const [0.0, 0.075, 0.925, 1.0],
    colors: [
        Colors.black,
        Colors.transparent,
        Colors.transparent,
        Colors.black,
    ],
    child: SingleChildScrollView(
        child: Column(
            children: [
                Title('Title'),
                Title('Content'),
            ]
        ),
    ),
);
```

```dart
// Add a shimmer loading effect to the child widget
Skeleton(
    enabled: true,
    child: Container(
        padding: EdgeInsets.all(12.0),
        child: Text('Finished loading'),
    ),
);
```

```dart
// Using `flutter_svg`, render SVG assets from locally stored assets
SvgAsset(
    'assets/icons/plus_icon.svg', 
    size: Size.square(24.0),
    colorFilter: ColorFilter(Colors.white, BlendMode.srcIn),
);
```

### Mixins

#### Post frame

You might want to perform some logic after the widget has finished building. You could use:

```dart
SchedulerBinding.instance.addPostFrameCallback((_) { 
    // Do something
});
```

You could also add a mixin:

```dart
class App extends StatefullWidget { 
    // 
}

class _AppState extends State<App> with PostFrameMixin {
    @override
    void initState() {
        super.initState();

        postFrame(() {
            // Do something
        });
    }
}
```

#### Safe area

Easily access the safe area offsets of the device. Like for instance iOS devices with nodges. For such devices, you would want to add some extra padding add the top or bottom.

We've created both a `SafeAreaMixin`, as a `ContextAwareSafeAreaMixin`. The first can be used in a `StatelessWidget`:

```dart
class App extends StatelessWidget with SafeAreaMixin { 
    @override
    Widget build(BuildContext) {
        // Include the current BuildContext:
        final paddingBottom = 12.0 + safeArea(context, edge: SafeAreaEdge.bottom);

        return Scaffold(
            child: Container(
                color: Colors.blue,
                padding: EdgeInsets.all(16.0).copyWith(
                    bottom: paddingBottom,
                ),
                child: Center(
                    child: Text('Title'),
                ),
            ),
        );
    }
}
```

The `ContextAwareSafeAreaMixin` can be used in a `StatefullWidget`.

```dart
class App extends StatefullWidget { 
    // 
}

class _AppState extends State<App> with ContextAwareSafeAreaMixin {
    @override
    Widget build(BuildContext) {
        // Doesn't need the BuildContext:
        final paddingBottom = 12.0 + safeArea(SafeAreaEdge.bottom);

        return Scaffold(
            child: Container(
                color: Colors.blue,
                padding: EdgeInsets.all(16.0).copyWith(
                    bottom: paddingBottom,
                ),
                child: Center(
                    child: Text('Title'),
                ),
            ),
        );
    }
}
```

### Dialogs

We created a DialogManager to easily show platform specific dialogs.

```dart
final instance = DialogManager();

instance.alert(
    context,
    title: 'Dialog title',
    message: 'Dialog message',
    actions: [
        DialogAction(
            type: DialogActionType.cancellation,
            title: 'Cancel',
            onPressed: () {
                //
            }
        ),
        DialogAction(
            type: DialogActionType.standard,
            title: 'Close',
            onPressed: () {
                //
            }
        ),
        DialogAction(
            type: DialogActionType.destructive,
            title: 'Delete',
            onPressed: () {
                //
            }
        ),
    ],
);
```

### Pickers

Android has a standard date(time)Picker. For iOS you'd like to use a bottom sheet for this purpose. But you'd have to create it manually. We've created one for you.

```dart
final selectedDate = DateTime.now();

showCupertinoModalPopup(
    context: context,
    builder: (BuildContext builder) {
        return BottomSheetDatePicker(
            selected: selectedDate,
            strings: BottomSheetStrings(
                confirmButtonTitle: 'Done',
                cancelButtonTitle: 'Cancel',
            ),
            onCancel: () {},
            onConfirm: (date) {
                selectedDate = date;
            },
        );
    },
);

final selectedTime = DateTime.now();

showCupertinoModalPopup(
    context: context,
    builder: (BuildContext builder) {
        return BottomSheetTimePicker(
            selected: selectedTime,
            minuteInterval: 15,
            strings: BottomSheetStrings(
                confirmButtonTitle: 'Done',
                cancelButtonTitle: 'Cancel',
            ),
            onCancel: () {},
            onConfirm: (time) {
                selectedTime = time;
            },
        );
    },
);
```