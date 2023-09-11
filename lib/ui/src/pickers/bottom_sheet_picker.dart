import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:illuminate/ui.dart';

class BottomSheetStrings {
  final String confirmButtonTitle;
  final String cancelButtonTitle;

  const BottomSheetStrings({
    this.confirmButtonTitle = "Confirm",
    this.cancelButtonTitle = "Cancel",
  });
}

class BottomSheetPicker extends StatelessWidget with SafeAreaMixin {
  final Widget child;
  final BottomSheetStrings strings;
  final void Function() onConfirm;
  final void Function()? onCancel;
  final EdgeInsets? padding;

  const BottomSheetPicker({
    required this.child,
    required this.onConfirm,
    this.strings = const BottomSheetStrings(),
    this.padding,
    this.onCancel,
    super.key,
  });

  MainAxisAlignment get _buttonAlignment => onCancel != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = this.padding ??
        EdgeInsets.only(
          top: 12,
          right: 12,
          bottom: 4 + safeArea(context, edge: SafeAreaEdge.bottom),
          left: 12,
        );

    return Container(
      padding: padding,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SpacedRow(
            mainAxisAlignment: _buttonAlignment,
            spacing: 12,
            children: [
              onCancel != null
                  ? _button(
                      strings.cancelButtonTitle,
                      cancellation: true,
                      onPressed: () {
                        Navigator.of(context).pop();

                        onCancel?.call();
                      },
                    )
                  : Container(),
              _button(
                strings.confirmButtonTitle,
                onPressed: () {
                  onConfirm();
                },
              )
            ],
          ),
          SizedBox(
            height: 240,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _button(String title, {required void Function() onPressed, bool cancellation = false}) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      minSize: 32,
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: CupertinoColors.systemBlue,
          fontWeight: cancellation ? FontWeight.normal : FontWeight.bold,
        ),
      ),
    );
  }
}
