import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../config/app_colors.dart';
import '../../../../../config/strings.dart';
import '../../../../../core/presentation/widgets/custom_app_bar.dart';
import '../../../domain/entities/order_entity.dart';
import '../bloc/order_details_bloc.dart';
import '../../../../../injection/injection_container.dart' as di;
import 'widgets/order_details_body.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: Strings.orderDetails.tr()),
      body: BlocProvider(
        create: (_) => di.locator<OrderDetailsBloc>(),
        child: SafeArea(
          top: false,
          child: OrderDetailsBody(order: order),
        ),
      ),
    );
  }
}