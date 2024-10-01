import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgAsset extends StatelessWidget {
  final String asset;
  final Color? color;
  final ColorFilter? colorFilter;
  final Size? size;

  SvgAsset(
    this.asset, {
    super.key,
    this.size,
    ColorFilter? colorFilter,
    @Deprecated('You should use colorFilter instead') this.color,
  }) : colorFilter = colorFilter ?? _getColorFilter(color, BlendMode.srcIn);

  static ColorFilter? _getColorFilter(Color? color, BlendMode colorBlendMode) => color == null
      ? null
      : ColorFilter.mode(
          color,
          colorBlendMode,
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size?.height,
      width: size?.width,
      child: SvgPicture.asset(
        asset,
        height: size?.height,
        width: size?.width,
        colorFilter: colorFilter,
      ),
    );
  }
}
