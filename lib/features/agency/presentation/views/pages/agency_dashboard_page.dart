import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_colors.dart';
import '../../../../../core/presentation/widgets/custom_app_bar.dart';
import '../../../../../core/presentation/widgets/date_selector_chip.dart';
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
  static const _tabs = [
    'All',
    'Pending',
    'Processing',
    'Completed',
  ];

  late final List<DateTime> _dates;
  int _selectedDateIndex = 0;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    _dates = List.generate(7, (i) => start.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<AgencyBloc>()
        ..add(const FetchAgencyTasksRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(
          title: 'Active Tasks',
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 16),
              child: Center(
                child: NotificationBell(hasActiveNotifications: true),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                SizedBox(
                  height: 82,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dates.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return DateSelectorChip(
                        date: _dates[index],
                        isSelected: index == _selectedDateIndex,
                        onTap: () =>
                            setState(() => _selectedDateIndex = index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                const Expanded(child: AgencyDashboardBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
