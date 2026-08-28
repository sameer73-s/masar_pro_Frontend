import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_colors.dart';
import '../../../../../config/constants.dart';
import '../../../../../core/presentation/widgets/custom_app_bar.dart';
import '../../../../../core/presentation/widgets/filter_tab_bar.dart';
import '../../../../../core/presentation/widgets/notification_bell.dart';
import '../../../../../injection/injection_container.dart' as di;
import '../../../domain/enums/task_status.dart';
import '../../bloc/agency_bloc/agency_bloc.dart';
import '../bodies/agency_dashboard_body.dart';

class AgencyDashboardPage extends StatefulWidget {
  const AgencyDashboardPage({super.key});

  @override
  State<AgencyDashboardPage> createState() => _AgencyDashboardPageState();
}

class _AgencyDashboardPageState extends State<AgencyDashboardPage> {
  int _selectedTabIndex = 0;

  List<String> get _tabs => [
    'allTasks'.tr(),
    'orderStatusPending'.tr(),
    'orderStatusProcessing'.tr(),
    'orderStatusCompleted'.tr(),
  ];

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    return BlocProvider(
      create: (_) =>
          di.locator<AgencyBloc>()..add(const FetchAgencyTasksRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'activeTasks',
          actions: const [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 4),
              child: Center(
                child: NotificationBell(hasActiveNotifications: true),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth >= 1100
                  ? 32.0
                  : constraints.maxWidth >= 650
                  ? 28.0
                  : 20.0;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: kSpacing8),
                        Builder(
                          builder: (context) {
                            return FilterTabBar(
                              tabs: _tabs,
                              selectedIndex: _selectedTabIndex,
                              onTabSelected: (index) {
                                setState(() => _selectedTabIndex = index);
                                context.read<AgencyBloc>().add(
                                  FetchAgencyTasksRequested(
                                    statusFilter: switch (index) {
                                      1 => TaskStatus.pendingApproval,
                                      2 => TaskStatus.processing,
                                      3 => TaskStatus.completed,
                                      _ => null,
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: kSpacing12),
                        const Expanded(child: AgencyDashboardBody()),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
