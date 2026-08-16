import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../config/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
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
            'الطلبات النشطة',
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
                  'لا توجد طلبات حالياً',
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

                String statusAr = order.status;
                if (order.status == 'pending') {
                  statusAr = 'قيد الانتظار';
                } else if (order.status == 'processing') {
                  statusAr = 'قيد المعالجة';
                } else if (order.status == 'missing_info') {
                  statusAr = 'معلومات ناقصة';
                } else if (order.status == 'completed') {
                  statusAr = 'مكتمل';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: UnifiedTaskCard(
                    title: order.subject,
                    subtitle:
                        'الحالة: $statusAr • المرفقات: ${order.attachments.length}',
                    progress: order.status == 'completed' ? 1.0 : 0.0,
                    taskType: UnifiedTaskType.fromOrderType(order.taskType),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsPage(order: order),
                        ),
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
