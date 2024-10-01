import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:illuminate/foundation.dart';

class UniversalDialog {
  const UniversalDialog({
    required this.title,
    required this.message,
    this.barrierDismissible = true,
    this.actions = const [],
  });

  final String title;
  final String message;
  final bool barrierDismissible;
  final List<DialogAction> actions;
}

class DialogAction {
  const DialogAction({
    required this.type,
    required this.title,
    this.onPressed,
  });

  final DialogActionType type;
  final String title;
  final void Function()? onPressed;
}

enum DialogActionType {
  destructive,
  cancellation,
  standard;
}

class DialogManager extends DialogService {
  DialogPresentable? _delegate;

  @override
  void setDelegate(DialogPresentable delegate) {
    _delegate = delegate;
  }

  @override
  Future<void> present({required UniversalDialog dialog}) async {
    await _delegate?.shouldPresentDialog(dialog: dialog);
  }

  @override
  Future<void> alert(
    BuildContext context, {
    required UniversalDialog dialog,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: dialog.barrierDismissible,
      builder: (BuildContext context) {
        return PopScope(
          canPop: dialog.barrierDismissible,
          child: Builder(builder: (context) {
            if (Foundation.platform.isIOS) {
              return _CupertinoAlertDialog(
                title: dialog.title,
                message: dialog.message,
                actions: dialog.actions,
              );
            }

            return _AlertDialog(
              title: dialog.title,
              message: dialog.message,
              actions: dialog.actions,
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
          onPressed: action.onPressed ??
              () {
                context.pop();
              },
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
          onPressed: action.onPressed ??
              () {
                context.pop();
              },
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
  void setDelegate(DialogPresentable delegate);

  Future<void> present({
    required UniversalDialog dialog,
  });

  Future<void> alert(
    BuildContext context, {
    required UniversalDialog dialog,
  });
}

mixin DialogPresentable {
  Future<void> shouldPresentDialog({required UniversalDialog dialog});
}
