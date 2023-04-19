import 'package:flutter/material.dart';

class LoadingStack extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const LoadingStack({
    required this.child,
    required this.isLoading,
    super.key,
  });

  @override
  State<LoadingStack> createState() => _LoadingStackState();
}

class _LoadingStackState extends State<LoadingStack> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          AnimatedOpacity(
            opacity: widget.isLoading ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Center(
              child: Container(
                color: Colors.white.withOpacity(0.2),
                child: Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
