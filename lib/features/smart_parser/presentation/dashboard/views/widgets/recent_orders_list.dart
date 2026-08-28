import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../config/app_colors.dart';
import '../../../../../../core/presentation/widgets/premium_page_route.dart';
import '../../../../../../core/presentation/widgets/unified_task_card.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../../order_details/views/order_details_page.dart';

class RecentOrdersList extends StatefulWidget {
  const RecentOrdersList({super.key});

  @override
  State<RecentOrdersList> createState() => _RecentOrdersListState();
}

class _RecentOrdersListState extends State<RecentOrdersList> {
  List<OrderEntity> _orders = [];

  String _localizedStatus(String status) {
    switch (status) {
      case 'pending':
        return 'orderStatusPending'.tr();
      case 'processing':
        return 'orderStatusProcessing'.tr();
      case 'missing_info':
        return 'orderStatusMissingInfo'.tr();
      case 'completed':
        return 'orderStatusCompleted'.tr();
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    return BlocListener<DashboardBloc, DashboardState>(
      listenWhen: (previous, current) => current is DashboardOrdersUpdated,
      listener: (context, state) {
        debugPrint('[DEBUG] RecentOrdersList listener received state: $state');
        if (state is DashboardOrdersUpdated) {
          debugPrint(
            '[DEBUG] RecentOrdersList listener updating state with ${state.orders.length} orders',
          );
          setState(() {
            _orders = state.orders;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'activeOrders'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.deepNavy,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          if (_orders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'noOrdersCurrently'.tr(),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.slateGray,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final statusLabel = _localizedStatus(order.status);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: UnifiedTaskCard(
                    title: order.subject,
                    subtitle: 'orderCardSubtitle'.tr(
                      args: [statusLabel, '${order.attachments.length}'],
                    ),
                    progress: order.status == 'completed' ? 1.0 : 0.0,
                    taskType: UnifiedTaskType.fromOrderType(order.taskType),
                    onTap: () {
                      Navigator.of(context).push(
                        premiumPageRoute<void>(OrderDetailsPage(order: order)),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
