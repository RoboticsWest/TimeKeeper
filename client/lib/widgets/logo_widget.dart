import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/branding_provider.dart';

class LogoWidget extends ConsumerWidget {
  final double? width;
  final double? height;

  const LogoWidget({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoBytes = ref.watch(brandingProvider.select((b) => b.logoBytes));

    if (logoBytes != null) {
      return Image.memory(logoBytes, width: width, height: height);
    }

    return Image.asset(
      'assets/logos/default_logo.png',
      width: width,
      height: height,
    );
  }
}
