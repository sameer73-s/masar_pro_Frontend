import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/typography.dart';
import 'package:masar_pro/core/network/api_config.dart';
import 'package:masar_pro/core/presentation/widgets/app_error_dialog.dart';
import 'package:masar_pro/core/presentation/widgets/primary_button.dart';
import 'package:masar_pro/core/presentation/widgets/pub/ai_worker_card.dart';
import 'package:masar_pro/core/presentation/widgets/pub/publishing_progress_header.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../bloc/publishing_bloc/publishing_bloc.dart';

class ManuscriptPreparationBody extends StatefulWidget {
  const ManuscriptPreparationBody({
    super.key,
    required this.projectId,
    required this.journalId,
    this.journalName,
  });

  final String projectId;
  final String journalId;
  final String? journalName;

  @override
  State<ManuscriptPreparationBody> createState() =>
      _ManuscriptPreparationBodyState();
}

class _ManuscriptPreparationBodyState extends State<ManuscriptPreparationBody> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    context.read<PublishingBloc>().add(
          PrepareManuscriptRequested(widget.projectId, widget.journalId),
        );
  }

  void _retry() {
    context.read<PublishingBloc>().add(
          PrepareManuscriptRequested(widget.projectId, widget.journalId),
        );
  }

  Future<void> _downloadPackage(String packageUrl) async {
    if (_isDownloading) return;

    final url = packageUrl.startsWith('http')
        ? packageUrl
        : '${ApiConfig.normalizedBaseUrl}$packageUrl';
    final uri = Uri.tryParse(url);
    if (uri == null) {
      await AppErrorDialog.show(context, message: 'invalidPackageUrl'.tr());
      return;
    }

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
              : 'couldNotOpenFile'.tr(),
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
      return 'submission_package.zip';
    }
    return cleaned.replaceAll(RegExp(r'[^\w.\-]+'), '_');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PublishingBloc, PublishingState>(
      listenWhen: (previous, current) =>
          current is PublishingFailure && previous is! PublishingFailure,
      listener: (context, state) {
        if (state is! PublishingFailure) return;
        AppErrorDialog.show(
          context,
          message: state.error.tr(),
          okButtonText: 'retry'.tr(),
          onOk: _retry,
        );
      },
      child: BlocBuilder<PublishingBloc, PublishingState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PublishingProgressHeader(currentStage: 2),
                const SizedBox(height: 20),
                Expanded(child: _buildContent(state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(PublishingState state) {
    if (state is PublishingManuscriptPrepared) {
      return _PackageReadyView(
        journalName: widget.journalName,
        isDownloading: _isDownloading,
        onDownload: () => _downloadPackage(state.packageUrl),
      );
    }

    if (state is PublishingFailure) {
      return const SizedBox.shrink();
    }

    return const _PreparationProgressView();
  }
}

class _PreparationProgressView extends StatelessWidget {
  const _PreparationProgressView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AIWorkerCard(
          taskTitle: 'formattingManuscript'.tr(),
          progress: 0.62,
          state: AIWorkerState.processing,
        ),
        const SizedBox(height: 10),
        AIWorkerCard(
          taskTitle: 'generatingCoverLetter'.tr(),
          progress: 0,
          state: AIWorkerState.waiting,
        ),
      ],
    );
  }
}

class _PackageReadyView extends StatelessWidget {
  const _PackageReadyView({
    required this.journalName,
    required this.isDownloading,
    required this.onDownload,
  });

  final String? journalName;
  final bool isDownloading;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final subtitle = journalName?.trim();

    return Column(
      children: [
        const Spacer(),
        const Icon(
          Icons.check_circle_rounded,
          size: 56,
          color: Color(0xFF22C55E),
        ),
        const SizedBox(height: 16),
        Text(
          'submissionPackageReady'.tr(),
          textAlign: TextAlign.center,
          style: AppTypography.bodyTitle(color: AppColors.primary),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
        ],
        const Spacer(),
        PrimaryButton(
          text: 'downloadPackage'.tr(),
          onPressed: onDownload,
          isLoading: isDownloading,
          width: double.infinity,
          height: 52,
          icon: Icons.download_rounded,
        ),
      ],
    );
  }
}
