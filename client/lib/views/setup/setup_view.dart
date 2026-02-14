import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/views/setup/data_setup.dart';
import 'package:time_keeper/views/setup/database_setup.dart';
import 'package:time_keeper/views/setup/integrations_setup.dart';
import 'package:time_keeper/views/setup/member_setup.dart';
import 'package:time_keeper/views/setup/session_setup.dart';

class SetupView extends HookConsumerWidget {
  const SetupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 5);

    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Session Setup'),
            Tab(text: 'Team Member Setup'),
            Tab(text: 'Integrations'),
            Tab(text: 'Data'),
            Tab(text: 'Database'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              SessionSetupTab(),
              MemberSetupTab(),
              IntegrationsSetupTab(),
              DataSetupTab(),
              DatabaseSetupTab(),
            ],
          ),
        ),
      ],
    );
  }
}
