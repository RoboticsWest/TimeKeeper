import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnimatedInfiniteHorizontalList extends HookConsumerWidget {
  final List<Widget> children;
  final double childWidth;
  final int scrollSpeed;

  const AnimatedInfiniteHorizontalList({
    super.key,
    required this.children,
    required this.childWidth,
    this.scrollSpeed = 5,
  });

  double _getChildrenTotalWidth() {
    return children.length * childWidth;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final animationController = useAnimationController(
      duration: Duration(
        seconds: (children.isEmpty ? 1 : children.length) * scrollSpeed,
      ),
    );
    final animationInitialized = useRef(false);

    void initInfAni() {
      if (animationInitialized.value) return;
      if (children.isEmpty) return;

      animationInitialized.value = true;
      animationController.addListener(() {
        final resetPosition = _getChildrenTotalWidth();
        final currentScroll = animationController.value * resetPosition * 2;

        if (currentScroll >= resetPosition &&
            scrollController.hasClients &&
            children.isNotEmpty) {
          animationController.forward(from: 0.0);
        } else {
          if (scrollController.hasClients) {
            scrollController.jumpTo(currentScroll);
          }
        }
      });
      animationController.repeat();
    }

    useEffect(() {
      Future.delayed(const Duration(seconds: 2), () {
        initInfAni();
      });
      return null;
    }, [children.length]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        if (availableWidth < _getChildrenTotalWidth()) {
          // infinite list
          return RepaintBoundary(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: CustomScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return RepaintBoundary(
                        child: children.elementAtOrNull(
                          index % children.length,
                        ),
                      );
                    }, childCount: children.length * 2),
                  ),
                ],
              ),
            ),
          );
        } else {
          // static normal list
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
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
