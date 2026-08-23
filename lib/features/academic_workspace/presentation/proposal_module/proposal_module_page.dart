import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/app_colors.dart';
import '../../../../core/presentation/widgets/custom_app_bar.dart';
import '../../../../injection/injection_container.dart' as di;
import 'bloc/proposal_module_bloc.dart';
import 'proposal_module_body.dart';

class ProposalModulePage extends StatelessWidget {
  const ProposalModulePage({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<ProposalModuleBloc>()
        ..add(LoadProposalProjectRequested(projectId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Proposal'),
        body: SafeArea(
          child: ProposalModuleBody(projectId: projectId),
        ),
      ),
    );
  }
}
