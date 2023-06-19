import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  const CachedImage({
    required this.url,
    this.imageBuilder,
    this.fit,
    this.placeholder,
    this.errorBuilder,
    super.key,
  });

  final String url;
  final BoxFit? fit;
  final Widget Function(BuildContext, ImageProvider)? imageBuilder;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: imageBuilder,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorBuilder,
    );
  }
}
