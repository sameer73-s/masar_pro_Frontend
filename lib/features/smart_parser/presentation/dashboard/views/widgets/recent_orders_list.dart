import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../config/app_colors.dart';
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

                return Card(
                  elevation: 0,
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.slateGray.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.background,
                      child: Icon(
                        order.isReady
                            ? Icons.assignment
                            : Icons.assignment_late,
                        color: order.isReady
                            ? AppColors.deepNavy
                            : AppColors.accentGold,
                      ),
                    ),
                    title: Text(
                      order.subject,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    subtitle: Text(
                      'الحالة: $statusAr • المرفقات: ${order.attachments.length}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
