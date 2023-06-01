import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    required this.length,
    required this.selectedIndex,
    this.onTap,
    this.color = const Color(0xFFDCDCDC),
    this.activeColor = const Color(0xffffffff),
    this.width = 12,
    this.activeWidth = 32,
    this.height = 8,
    this.animationDuration = const Duration(milliseconds: 300),
    super.key,
  });

  final int length;
  final int selectedIndex;
  final void Function(int)? onTap;

  final Color color;
  final Color activeColor;

  final double activeWidth;
  final double width;
  final double height;

  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<int>.generate(length, (index) => index).map((index) {
            return circleBar(
              isActive: index == selectedIndex,
              index: index,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget circleBar({
    required bool isActive,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isActive && onTap != null) {
          onTap!(index);
        }
      },
      child: AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeInSine,
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 16,
        ),
        height: height,
        width: isActive ? activeWidth : width,
        decoration: BoxDecoration(
          color: isActive ? activeColor : color,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}
