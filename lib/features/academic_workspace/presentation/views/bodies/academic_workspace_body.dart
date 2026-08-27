import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../config/app_colors.dart';
import '../../../../../config/app_theme.dart';
import '../../../../../config/strings.dart';
import '../../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../../../core/presentation/widgets/app_success_dialog.dart';
import '../../../../../core/presentation/widgets/empty_widget.dart';
import '../../../../../core/presentation/widgets/primary_button.dart';
import '../../../domain/entities/academic_project.dart';
import '../../bloc/academic_workspace_bloc/academic_workspace_bloc.dart';
import '../widgets/academic_project_card.dart';
import '../widgets/create_academic_project_sheet.dart';

class AcademicWorkspaceBody extends StatefulWidget {
  const AcademicWorkspaceBody({super.key});

  @override
  State<AcademicWorkspaceBody> createState() => _AcademicWorkspaceBodyState();
}

class _AcademicWorkspaceBodyState extends State<AcademicWorkspaceBody> {
  List<AcademicProject> _projects = const [];

  Future<void> _onRefresh() async {
    final bloc = context.read<AcademicWorkspaceBloc>();
    bloc.add(const FetchAcademicProjectsRequested());
    await bloc.stream.firstWhere(
      (state) =>
          state is AcademicProjectsLoaded || state is AcademicWorkspaceFailure,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return BlocConsumer<AcademicWorkspaceBloc, AcademicWorkspaceState>(
      listener: (context, state) {
        if (state is AcademicWorkspaceFailure) {
          AppErrorDialog.show(
            context,
            message: state.error.tr(),
            okButtonText: Strings.retry.tr(),
            onOk: () => context.read<AcademicWorkspaceBloc>().add(
                  const FetchAcademicProjectsRequested(),
                ),
            secondaryButtonText: Strings.ok.tr(),
            onSecondaryAction: () {},
          );
        } else if (state is AcademicProjectCreated) {
          context.read<AcademicWorkspaceBloc>().add(
                const FetchAcademicProjectsRequested(),
              );
          AppSuccessDialog.show(
            context,
            message: 'academicProjectCreated'.tr(),
          );
        } else if (state is AcademicPhaseStatusUpdated) {
          context.read<AcademicWorkspaceBloc>().add(
                const FetchAcademicProjectsRequested(),
              );
        } else if (state is AcademicProjectsLoaded) {
          _projects = state.projects;
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AcademicWorkspaceLoading || state is AcademicWorkspaceInitial;

        return Column(
          key: ValueKey(locale.languageCode),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: isLoading && _projects.isEmpty
                    ? const _AcademicProjectsSkeleton()
                    : _ProjectsList(
                        projects: state is AcademicProjectsLoaded
                            ? state.projects
                            : _projects,
                        onRefresh: _onRefresh,
                        showInlineLoading: isLoading && _projects.isNotEmpty,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(
                text: 'newAcademicProject'.tr(),
                icon: Icons.add_rounded,
                onPressed: () => CreateAcademicProjectSheet.show(context),
                width: double.infinity,
                height: 48,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProjectsList extends StatelessWidget {
  const _ProjectsList({
    required this.projects,
    required this.onRefresh,
    required this.showInlineLoading,
  });

  final List<AcademicProject> projects;
  final Future<void> Function() onRefresh;
  final bool showInlineLoading;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.accentPurple,
      child: projects.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                EmptyWidget(message: 'noAcademicProjectsYet'),
              ],
            )
          : Stack(
              children: [
                ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: projects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      AcademicProjectCard(project: projects[index]),
                ),
                if (showInlineLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.accentPurple,
                      backgroundColor: AppColors.surfacePurple,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _AcademicProjectsSkeleton extends StatelessWidget {
  const _AcademicProjectsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmer,
      highlightColor: AppColors.background,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppShapes.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
