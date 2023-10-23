import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:illuminate/foundation.dart';

class DialogAction {
  final DialogActionType type;
  final String title;
  final void Function() onPressed;

  const DialogAction({
    required this.type,
    required this.title,
    required this.onPressed,
  });
}

enum DialogActionType {
  destructive,
  cancellation,
  standard;
}

class DialogManager extends DialogService {
  @override
  Future<void> alert(
    BuildContext context, {
    required String title,
    required String message,
    bool barrierDismissible = true,
    List<DialogAction> actions = const [],
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => barrierDismissible,
          child: Builder(builder: (context) {
            if (Foundation.platform.isIOS) {
              return _CupertinoAlertDialog(
                title: title,
                message: message,
                actions: actions,
              );
            }

            return _AlertDialog(
              title: title,
              message: message,
              actions: actions,
            );
          }),
        );
      },
    );
  }
}

class _AlertDialog extends StatelessWidget {
  const _AlertDialog({
    required this.title,
    required this.message,
    this.actions = const [],
  });

  final String title;
  final String message;
  final List<DialogAction> actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: actions.map((action) {
        Color? color;
        FontWeight fontWeight = FontWeight.bold;

        if (action.type == DialogActionType.destructive) {
          color = Colors.red.shade600;
        } else if (action.type == DialogActionType.standard) {
          color = Theme.of(context).primaryColor;
        }

        return TextButton(
          onPressed: action.onPressed,
          child: Container(
            padding: const EdgeInsets.all(14),
            child: Text(
              action.title,
              style: TextStyle(
                color: color,
                fontWeight: fontWeight,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CupertinoAlertDialog extends StatelessWidget {
  const _CupertinoAlertDialog({
    required this.title,
    required this.message,
    this.actions = const [],
  });

  final String title;
  final String message;
  final List<DialogAction> actions;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: actions.map((action) {
        return CupertinoDialogAction(
          isDefaultAction: action.type == DialogActionType.standard,
          isDestructiveAction: action.type == DialogActionType.destructive,
          onPressed: action.onPressed,
          child: Text(
            action.title,
            style: action.type != DialogActionType.destructive
                ? const TextStyle(
                    color: CupertinoColors.activeBlue,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}

abstract class DialogService {
  //
  Future<void> alert(
    BuildContext context, {
    required String title,
    required String message,
    bool barrierDismissible = true,
    List<DialogAction> actions = const [],
  });
}
