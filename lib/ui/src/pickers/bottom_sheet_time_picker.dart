import 'package:flutter/cupertino.dart';
import 'package:illuminate/ui.dart';

class BottomSheetTimePicker extends StatefulWidget {
  final void Function(DateTime) onConfirm;
  final BottomSheetStrings strings;
  final void Function()? onCancel;
  final int minuteInterval;
  final DateTime? selected;
  final EdgeInsets? padding;

  const BottomSheetTimePicker({
    required this.onConfirm,
    this.strings = const BottomSheetStrings(),
    this.onCancel,
    this.minuteInterval = 1,
    this.selected,
    this.padding,
    super.key,
  });

  @override
  State<BottomSheetTimePicker> createState() => _BottomSheetTimePickerState();
}

class _BottomSheetTimePickerState extends State<BottomSheetTimePicker> with SafeAreaMixin {
  late DateTime _date;

  @override
  void initState() {
    super.initState();

    final date = widget.selected ?? DateTime.now();
    final initialDate = DateTime(
      date.year,
      date.month,
      date.day,
      date.hour,
      (date.minute % widget.minuteInterval * widget.minuteInterval).toInt(),
    );

    setState(() => _date = initialDate);
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.selected ?? DateTime.now();
    final initialDate = DateTime(
      date.year,
      date.month,
      date.day,
      date.hour,
      (date.minute % widget.minuteInterval * widget.minuteInterval).toInt(),
    );

    return BottomSheetPicker(
      onConfirm: () {
        widget.onConfirm(_date);
        Navigator.of(context).pop();
      },
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        onDateTimeChanged: (value) {
          setState(() => _date = value);
        },
        initialDateTime: initialDate,
        minuteInterval: widget.minuteInterval,
      ),
    );
  }
}
