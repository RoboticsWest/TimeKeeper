import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Creates an animated infinite list which scrolls forever vertically.
///
/// Uses a paint-only Transform.translate approach instead of scrollController.jumpTo()
/// to avoid triggering expensive layout passes every frame.
class AnimatedInfiniteVerticalList extends HookConsumerWidget {
  final List<Widget> children;
  final double childHeight;
  final int scrollSpeedMs;
  final bool duplicateWhenChildrenOdd;

  const AnimatedInfiniteVerticalList({
    super.key,
    required this.children,
    required this.childHeight,
    this.scrollSpeedMs = 2000,
    this.duplicateWhenChildrenOdd = true,
  });

  List<Widget> _getChildren() {
    if (duplicateWhenChildrenOdd && children.length % 2 != 0) {
      return List.from(children)..addAll(children);
    } else {
      return children;
    }
  }

  double _getChildrenTotalHeight({bool actual = false}) {
    if (actual) {
      return children.length * childHeight;
    } else {
      return _getChildren().length * childHeight;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = _getChildren();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        if (items.isNotEmpty &&
            availableHeight < _getChildrenTotalHeight(actual: true)) {
          return _InfiniteScrolling(
            items: items,
            childHeight: childHeight,
            scrollSpeedMs: scrollSpeedMs,
          );
        } else {
          // Static normal list — fits on screen
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return RepaintBoundary(
                      child: children.elementAtOrNull(index),
                    );
                  }, childCount: children.length),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class _InfiniteScrolling extends HookWidget {
  final List<Widget> items;
  final double childHeight;
  final int scrollSpeedMs;

  const _InfiniteScrolling({
    required this.items,
    required this.childHeight,
    required this.scrollSpeedMs,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = items.length * childHeight;
    final duration = Duration(
      milliseconds: (items.isEmpty ? 1 : items.length) * scrollSpeedMs,
    );
    final animationController = useAnimationController(duration: duration);

    useEffect(() {
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          animationController.repeat();
        }
      });
      return null;
    }, [items.length]);

    // Build the item list once, wrap in RepaintBoundary
    final column = RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in items) SizedBox(height: childHeight, child: item),
          for (final item in items) SizedBox(height: childHeight, child: item),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: ClipRect(
            child: OverflowBox(
              maxHeight: totalHeight * 2,
              alignment: Alignment.topCenter,
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  final offset = animationController.value * totalHeight;
                  return Transform.translate(
                    offset: Offset(0, -offset),
                    child: child,
                  );
                },
                child: column,
              ),
            ),
          ),
        );
      },
    );
  }
}
