import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/core/presentation/widgets/custom_app_bar.dart';

import 'widgets/pub_dashboard_body.dart';

class PubDashboardPage extends StatelessWidget {
  const PubDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'academicPublishing'),
      body: const PubDashboardBody(),
    );
  }
}
