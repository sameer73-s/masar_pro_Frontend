import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../config/strings.dart';
import '../../../../../../config/app_colors.dart';
import '../../../../domain/entities/order_entity.dart';

class ParsedOrderCard extends StatelessWidget {
  final OrderEntity order;

  const ParsedOrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 2,
      child: ListTile(
        title: Text(Strings.parsedOrder.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${Strings.taskType.tr(args: [order.taskType])}\n${Strings.status.tr(args: [order.status])}'),
        isThreeLine: true,
      ),
    );
  }
}
