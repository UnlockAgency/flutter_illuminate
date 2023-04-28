import 'package:flutter/material.dart';
import 'package:illuminate/common.dart';

class SpacedColumn extends Column {
  SpacedColumn({
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
          children: children.insertBetween(
            SizedBox(height: spacing),
          ),
        );
}
