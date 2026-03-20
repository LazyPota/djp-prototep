import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state_providers.dart';
import 'main_shell_screen.dart';
import 'onboarding_screen.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasOnboarded = ref.watch(hasOnboardedProvider);

    return hasOnboarded.when(
      data: (value) => value ? const MainShellScreen() : const OnboardingScreen(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Startup error: $e')),
      ),
    );
  }
}
