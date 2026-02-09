import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Creates an animated infinite list which will scroll forever
// Under the hood this creates 2 duplicate lists, one after the other
// And animates the scroll to give the illusion of infinite scrolling
// Once the second list is fully visible, the scroll position is reset to the start
class AnimatedInfiniteVerticalList extends HookConsumerWidget {
  final List<Widget> children;
  final double childHeight;
  final int scrollSpeed;
  final bool duplicateWhenChildrenOdd;

  const AnimatedInfiniteVerticalList({
    super.key,
    required this.children,
    required this.childHeight,
    this.scrollSpeed = 5,
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
    final scrollController = useScrollController();
    final animationController = useAnimationController(
      duration: Duration(
        seconds: (items.isEmpty ? 1 : items.length) * scrollSpeed,
      ),
    );
    final animationInitialized = useRef(false);

    void initInfAni() {
      if (animationInitialized.value) return;
      if (items.isEmpty) return;

      animationInitialized.value = true;
      animationController.addListener(() {
        final resetPosition = _getChildrenTotalHeight();
        final currentScroll = animationController.value * resetPosition * 2;

        if (currentScroll >= resetPosition &&
            scrollController.hasClients &&
            items.isNotEmpty) {
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
    }, [items.length]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        if (availableHeight < _getChildrenTotalHeight(actual: true)) {
          // infinite list
          return RepaintBoundary(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return RepaintBoundary(
                        child: items.elementAtOrNull(index % items.length),
                      );
                    }, childCount: items.length * 2),
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
