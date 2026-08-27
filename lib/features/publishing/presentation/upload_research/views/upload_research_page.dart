import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/core/presentation/widgets/custom_app_bar.dart';
import 'package:masar_pro/injection/injection_container.dart' as di;

import '../../bloc/publishing_bloc/publishing_bloc.dart';
import 'widgets/upload_research_body.dart';

class UploadResearchPage extends StatelessWidget {
  const UploadResearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<PublishingBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(title: 'newResearch'),
        body: const UploadResearchBody(),
      ),
    );
  }
}
