import 'package:flutter/material.dart';
import 'package:illuminate/state/src/providable.dart';
import 'package:illuminate/state/src/state_manager.dart';
import 'package:provider/provider.dart';

class Consumable<T extends Providable> extends StatelessWidget {
  const Consumable({
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.onTapReload,
    super.key,
  });

  final Widget Function(
    BuildContext context,
    T provider,
  ) builder;

  final Widget Function(
    BuildContext context,
    T provider,
  )? errorBuilder;

  final Widget Function(
    BuildContext context,
    T provider,
  )? loadingBuilder;

  final void Function()? onTapReload;

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(builder: (context, provider, child) {
      if (provider.status.isError) {
        if (errorBuilder != null) {
          return errorBuilder!(context, provider);
        }

        if (StateManager.instance.errorWidget != null) {
          return StateManager.instance.errorWidget!;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            // TODO: Default error state
            Text('Something went wrong, please try again'),
          ],
        );
      }

      if (provider.status.isInitial || provider.status.isSuccess || provider.status.isUpdating) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            builder(context, provider),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: provider.status.isUpdating ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    color: Colors.white.withOpacity(0.5),
                    child: _loadingIndicator(),
                  ),
                ),
              ),
            ),
          ],
        );
      }

      if (loadingBuilder != null) {
        return loadingBuilder!(context, provider);
      }

      if (StateManager.instance.loadingWidget != null) {
        return StateManager.instance.loadingWidget!;
      }

      return _loadingIndicator();
    });
  }

  Widget _loadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(
        top: 48,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
