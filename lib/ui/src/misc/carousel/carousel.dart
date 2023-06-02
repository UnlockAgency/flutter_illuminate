import 'dart:async';

import 'package:flutter/material.dart';
import 'package:illuminate/ui/src/misc/carousel/page_indicator.dart';

class Carousel extends StatefulWidget {
  const Carousel({
    required this.controller,
    required this.items,
    this.duration = const Duration(milliseconds: 350),
    this.interval = const Duration(seconds: 5),
    this.autoPlay = true,
    this.showPageIndicator = false,
    this.backgroundColor = const Color(0xFFDCDCDC),
    this.indicatorAlignment,
    this.indicatorColor = const Color(0x80ffffff),
    this.indicatorActiveColor = Colors.white,
    super.key,
  });

  factory Carousel.images({
    required List<String> urls,
    PageController? controller,
    backgroundColor = const Color(0xFFDCDCDC),
  }) {
    return Carousel(
      controller: controller ?? PageController(),
      showPageIndicator: true,
      backgroundColor: backgroundColor,
      autoPlay: false,
      items: urls.map((url) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                url,
              ),
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }

  final PageController controller;
  final List<Widget> items;

  final Color backgroundColor;

  final Duration duration;
  final Duration interval;
  final bool autoPlay;

  final bool showPageIndicator;
  final Alignment? indicatorAlignment;
  final Color indicatorColor;
  final Color indicatorActiveColor;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _currentPage = widget.controller.initialPage;

    if (widget.autoPlay) {
      _timer = Timer.periodic(widget.interval, (timer) {
        handleCarousel();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColoredBox(
          color: widget.backgroundColor,
          child: PageView.builder(
            controller: widget.controller,
            padEnds: false,
            physics: const ClampingScrollPhysics(),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              return widget.items[index];
            },
            onPageChanged: (value) => setState(() {
              _currentPage = value;
            }),
          ),
        ),
        if (widget.showPageIndicator)
          Align(
            alignment: widget.indicatorAlignment ?? Alignment.bottomCenter,
            child: PageIndicator(
              length: widget.items.length,
              selectedIndex: _currentPage,
              color: widget.indicatorColor,
              activeColor: widget.indicatorActiveColor,
            ),
          )
      ],
    );
  }

  void handleCarousel() {
    if (_currentPage < widget.items.length - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }

    widget.controller.animateToPage(
      _currentPage,
      duration: widget.duration,
      curve: Curves.easeIn,
    );

    setState(() {});
  }
}
