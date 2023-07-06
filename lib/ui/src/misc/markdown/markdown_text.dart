import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:illuminate/common.dart';

enum MarkdownContainer {
  listView,
  column;
}

class MarkdownText extends StatelessWidget {
  const MarkdownText(
    this.text, {
    this.style,
    this.onTapLink,
    this.scrollController,
    this.selectable = false,
    this.container = MarkdownContainer.listView,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final void Function(String?)? onTapLink;
  final ScrollController? scrollController;
  final bool selectable;
  final MarkdownContainer container;

  @override
  Widget build(BuildContext context) {
    final stylesheet = MarkdownStyleSheet(
      a: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.underline,
      ),
      p: style ?? Theme.of(context).textTheme.bodyMedium,
    );

    if (container == MarkdownContainer.listView) {
      return Markdown(
        shrinkWrap: true,
        controller: scrollController,
        selectable: selectable,
        data: text,
        styleSheet: stylesheet,
        onTapLink: _onTapLink,
      );
    }

    return MarkdownBody(
      shrinkWrap: true,
      selectable: selectable,
      data: text,
      styleSheet: stylesheet,
      onTapLink: _onTapLink,
    );
  }

  void _onTapLink(text, url, title) {
    onTapLink?.call(url);

    if (url != null) {
      openExternally(url);
    }
  }
}
