import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/presentation/widgets/academic_journey_header.dart';
import '../../../../core/presentation/widgets/premium_page_route.dart';
import '../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/presentation/widgets/pub/ai_worker_card.dart';
import '../../domain/entities/academic_project.dart';
import '../research_module/research_module_page.dart';
import 'bloc/proposal_module_bloc.dart';

class ProposalModuleBody extends StatefulWidget {
  const ProposalModuleBody({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProposalModuleBody> createState() => _ProposalModuleBodyState();
}

class _ProposalModuleBodyState extends State<ProposalModuleBody> {
  bool _isDownloading = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null || path.isEmpty) {
      if (!mounted) return;
      await AppErrorDialog.show(
        context,
        message: 'couldNotAccessSelectedFile'.tr(),
      );
      return;
    }

    if (!mounted) return;
    context.read<ProposalModuleBloc>().add(
      UploadProposalRequested(projectId: widget.projectId, file: File(path)),
    );
  }

  Future<void> _downloadProposal(String? fileUrl) async {
    final raw = (fileUrl ?? '').trim();
    if (raw.isEmpty) {
      await AppErrorDialog.show(
        context,
        message: 'noProposalFileAvailable'.tr(),
      );
      return;
    }

    final url = raw.startsWith('http')
        ? raw
        : '${ApiConfig.normalizedBaseUrl}$raw';
    final uri = Uri.tryParse(url);
    if (uri == null) {
      await AppErrorDialog.show(
        context,
        message: 'invalidProposalFileUrl'.tr(),
      );
      return;
    }

    if (uri.scheme == 'http' || uri.scheme == 'https') {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        await _downloadAndOpenLocally(url, uri);
      }
      return;
    }

    await _downloadAndOpenLocally(url, uri);
  }

  Future<void> _downloadAndOpenLocally(String url, Uri uri) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final dir = await getTemporaryDirectory();
      final fileName = _fileNameFromUri(uri);
      final savePath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
      await dio.download(url, savePath);

      final openResult = await OpenFilex.open(savePath);
      if (!mounted) return;
      if (openResult.type != ResultType.done) {
        await AppErrorDialog.show(
          context,
          message: openResult.message.isNotEmpty
              ? openResult.message
              : 'couldNotOpenProposalFile'.tr(),
        );
      }
    } catch (_) {
      if (mounted) {
        await AppErrorDialog.show(context, message: 'downloadFailed'.tr());
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  static String _fileNameFromUri(Uri uri) {
    final last = uri.pathSegments.isNotEmpty
        ? Uri.decodeComponent(uri.pathSegments.last)
        : '';
    final cleaned = last.split('?').first.trim();
    if (cleaned.isEmpty || !cleaned.contains('.')) {
      return 'proposal.pdf';
    }
    return cleaned.replaceAll(RegExp(r'[^\w.\-]+'), '_');
  }

  void _approve() {
    context.read<ProposalModuleBloc>().add(
      ApproveProposalRequested(widget.projectId),
    );
  }

  void _generateWithAi() {
    context.read<ProposalModuleBloc>().add(
      GenerateProposalRequested(widget.projectId),
    );
  }

  void _skipProposal() {
    context.read<ProposalModuleBloc>().add(
      SkipProposalRequested(widget.projectId),
    );
  }

  void _proceedToResearch(AcademicProject project) {
    Navigator.of(
      context,
    ).push(premiumPageRoute<void>(ResearchModulePage(projectId: project.id)));
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    return BlocConsumer<ProposalModuleBloc, ProposalModuleState>(
      listener: (context, state) {
        if (state is ProposalModuleFailure) {
          AppErrorDialog.show(context, message: state.error);
        }
        if (state is ProposalModuleSkipSuccess) {
          Navigator.of(context).pushReplacement(
            premiumPageRoute<void>(
              ResearchModulePage(projectId: state.project.id),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ProposalModuleGenerating) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AIWorkerCard(
                  taskTitle: 'generatingProposal'.tr(),
                  progress: 0.55,
                  state: AIWorkerState.processing,
                ),
              ],
            ),
          );
        }

        if (state is ProposalModuleLoading || state is ProposalModuleInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentPurple),
          );
        }

        if (state is ProposalModuleFailure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'retry'.tr(),
                    onPressed: () {
                      context.read<ProposalModuleBloc>().add(
                        LoadProposalProjectRequested(widget.projectId),
                      );
                    },
                    width: 160,
                    height: 42,
                    borderRadius: 10,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! ProposalModuleLoaded) {
          return const SizedBox.shrink();
        }

        final project = state.project;
        final status = project.proposalStatus.trim().toUpperCase();
        final hasFile = (project.proposalFileUrl ?? '').trim().isNotEmpty;
        final isApproved = status == 'APPROVED';
        final isInReview = status == 'REVIEW' || (hasFile && !isApproved);

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(
              project.title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            AcademicJourneyHeader(
              proposalStatus: project.proposalStatus,
              researchStatus: project.researchStatus,
              publishingStatus: project.publishingStatus,
            ),
            const SizedBox(height: 28),
            if (isApproved)
              _ApprovedSection(onProceed: () => _proceedToResearch(project))
            else if (isInReview)
              _ReviewSection(
                isDownloading: _isDownloading,
                onDownload: () => _downloadProposal(project.proposalFileUrl),
                onApprove: _approve,
              )
            else
              _UploadSection(
                onGenerate: _generateWithAi,
                onUpload: _pickAndUpload,
                onSkip: _skipProposal,
              ),
          ],
        );
      },
    );
  }
}

class _UploadSection extends StatelessWidget {
  const _UploadSection({
    required this.onGenerate,
    required this.onUpload,
    required this.onSkip,
  });

  final VoidCallback onGenerate;
  final VoidCallback onUpload;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'getStartedProposal'.tr(),
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'generateOrUploadHint'.tr(),
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        _ActionCard(
          icon: Icons.auto_awesome_outlined,
          title: 'generateWithAi'.tr(),
          subtitle: 'generateProposalSubtitle'.tr(),
          onTap: onGenerate,
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.upload_file_outlined,
          title: 'uploadExistingProposal'.tr(),
          subtitle: 'uploadProposalSubtitle'.tr(),
          onTap: onUpload,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: 'skipProposal'.tr(),
          onPressed: onSkip,
          backgroundColor: AppColors.surfacePurple,
          textColor: AppColors.textSecondary,
          width: double.infinity,
          height: 48,
          borderRadius: AppShapes.cardRadius,
        ),
      ],
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.isDownloading,
    required this.onDownload,
    required this.onApprove,
  });

  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfacePurple,
            borderRadius: BorderRadius.circular(AppShapes.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'proposalUnderReview'.tr(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'proposalReviewHint'.tr(),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: isDownloading ? 'downloading'.tr() : 'downloadProposal'.tr(),
          onPressed: isDownloading ? null : onDownload,
          width: double.infinity,
          height: 48,
          borderRadius: 12,
          backgroundColor: AppColors.surfacePurple,
          textColor: AppColors.accentPurple,
          icon: Icons.download_outlined,
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          text: 'approveProposal'.tr(),
          onPressed: onApprove,
          width: double.infinity,
          height: 56,
          borderRadius: 12,
          icon: Icons.check_circle_outline,
        ),
      ],
    );
  }
}

class _ApprovedSection extends StatelessWidget {
  const _ApprovedSection({required this.onProceed});

  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.greenLight,
            borderRadius: BorderRadius.circular(AppShapes.cardRadius),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.verified_outlined, size: 40, color: AppColors.success),
              const SizedBox(height: 12),
              Text(
                'proposalApproved'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'proposalApprovedHint'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: 'proceedToFullResearch'.tr(),
          onPressed: onProceed,
          width: double.infinity,
          height: 52,
          borderRadius: 12,
          icon: Icons.arrow_forward_rounded,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppShapes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppShapes.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.surfacePurple,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.accentPurple, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
