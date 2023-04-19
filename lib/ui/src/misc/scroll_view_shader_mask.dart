import 'package:flutter/material.dart';

class ScrollViewShaderMask extends StatelessWidget {
  const ScrollViewShaderMask({
    super.key,
    required this.child,
    this.stops = const [0.0, 0.1, 0.9, 1.0],
    this.colors,
  });

  final Widget child;
  final List<double> stops;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // Colors.black isn't used concretely, only for the fractions of the vector
          colors: colors ?? [Colors.black, Colors.transparent, Colors.transparent, Colors.black],
          stops: stops,
        ).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: child,
    );
  }
}
