import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgAsset extends StatelessWidget {
  final String asset;
  final Color? color;
  final Size? size;

  const SvgAsset(
    this.asset, {
    this.size,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size?.width,
      width: size?.height,
      child: SvgPicture.asset(
        asset,
        height: size?.width,
        width: size?.height,
        color: color,
      ),
    );
  }
}
