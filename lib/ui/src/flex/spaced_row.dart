import 'package:flutter/material.dart';

class SpacedRow extends Row {
  SpacedRow({
    super.key,
    super.mainAxisAlignment,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    required List<Widget> children,
    required double spacing,
  }) : super(
          children: children.fold<List<Widget>>(
            [],
            (result, widget) {
              if (result.isNotEmpty) {
                result.add(SizedBox(width: spacing));
              }

              result.add(widget);
              return result;
            },
          ),
        );
}
