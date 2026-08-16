import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../config/strings.dart';
import '../../../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../../../../core/presentation/widgets/app_success_dialog.dart';
import '../../../../../agency/presentation/views/pages/agency_dashboard_page.dart';
import '../../bloc/order_details_bloc.dart';
import '../../bloc/order_details_state.dart';
import 'order_details_form.dart';
import '../../../../domain/entities/order_entity.dart';

class OrderDetailsBody extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsBody({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderDetailsBloc, OrderDetailsState>(
      listener: (context, state) {
        if (state is OrderDetailsSaved) {
          AppSuccessDialog.show(
            context,
            message: Strings.success.tr(args: ['Saved']),
            onOk: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const AgencyDashboardPage(),
                ),
              );
            },
          );
        } else if (state is OrderDetailsContentGenerated) {
          AppSuccessDialog.show(
            context,
            message: Strings.success.tr(args: ['Generated']),
            onOk: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const AgencyDashboardPage(),
                ),
              );
            },
          );
        } else if (state is OrderDetailsFailure) {
          AppErrorDialog.show(context, message: state.message);
        }
      },
      child: OrderDetailsForm(order: order),
    );
  }
}
