import 'package:flutter/cupertino.dart';
import 'package:illuminate/ui.dart';

class BottomSheetDatePicker extends StatefulWidget {
  final void Function(DateTime) onConfirm;
  final void Function()? onCancel;
  final BottomSheetStrings strings;
  final DateTime? selected;
  final EdgeInsets? padding;
  final int? minimumYear;
  final int? maximumYear;
  final DateTime? minimumDate;
  final DateTime? maximumDate;

  const BottomSheetDatePicker({
    required this.onConfirm,
    this.strings = const BottomSheetStrings(),
    this.onCancel,
    this.selected,
    this.padding,
    this.minimumYear,
    this.maximumYear,
    this.minimumDate,
    this.maximumDate,
    super.key,
  });

  @override
  State<BottomSheetDatePicker> createState() => _BottomSheetDatePickerState();
}

class _BottomSheetDatePickerState extends State<BottomSheetDatePicker> with SafeAreaMixin {
  late DateTime _date;

  @override
  void initState() {
    super.initState();

    setState(() => _date = widget.selected ?? DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetPicker(
      onConfirm: () {
        widget.onConfirm(_date);
        Navigator.of(context).pop();
      },
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        onDateTimeChanged: (value) {
          setState(() => _date = value);
        },
        initialDateTime: widget.selected ?? DateTime.now(),
        minimumYear: widget.minimumYear ?? 1,
        maximumYear: widget.maximumYear,
        minimumDate: widget.minimumDate,
        maximumDate: widget.maximumDate,
      ),
    );
  }
}
