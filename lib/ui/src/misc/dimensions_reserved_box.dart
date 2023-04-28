import 'package:flutter/material.dart';

class DimensionsReservedBox extends StatelessWidget {
  const DimensionsReservedBox({
    required this.isVisible,
    required this.child,
    this.height,
    this.width,
    super.key,
  });

  final double? height;
  final double? width;
  final bool isVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isVisible) {
      return child;
    }

    return SizedBox(
      height: height,
      width: width,
    );
  }
}
