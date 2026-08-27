import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/core/presentation/widgets/app_error_dialog.dart';

import '../../../bloc/publishing_bloc/publishing_bloc.dart';
import '../../../readiness_result/views/readiness_result_page.dart';
import 'publishing_ai_pipeline.dart';
import 'upload_research_form.dart';

class UploadResearchBody extends StatefulWidget {
  const UploadResearchBody({super.key});

  @override
  State<UploadResearchBody> createState() => _UploadResearchBodyState();
}

class _UploadResearchBodyState extends State<UploadResearchBody> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  File? _selectedFile;
  String? _selectedFileName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _mockPickFile() async {
    final file = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}mock_manuscript.docx',
    );
    await file.writeAsString('Mock manuscript for Academic Publishing.');
    if (!mounted) return;
    setState(() {
      _selectedFile = file;
      _selectedFileName = 'research_manuscript.docx';
    });
  }

  void _onSubmit() {
    if (_isSubmitting) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_selectedFile == null) {
      AppErrorDialog.show(
        context,
        message: 'pleaseSelectManuscriptFile'.tr(),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    context.read<PublishingBloc>().add(
          CreateResearchRequested(_titleController.text.trim()),
        );
  }

  void _onResearchCreated(String projectId) {
    final file = _selectedFile;
    if (file == null) {
      setState(() => _isSubmitting = false);
      AppErrorDialog.show(
        context,
        message: 'pleaseSelectManuscriptFile'.tr(),
      );
      return;
    }
    context.read<PublishingBloc>().add(
          UploadManuscriptRequested(projectId, file),
        );
  }

  void _onManuscriptUploaded(String projectId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ReadinessResultPage(projectId: projectId),
      ),
    );
  }

  bool _isPipelineActive(PublishingState state) {
    return state is PublishingLoading ||
        state is PublishingResearchCreated ||
        state is PublishingManuscriptUploaded;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PublishingBloc, PublishingState>(
      listenWhen: (previous, current) =>
          current is PublishingResearchCreated ||
          current is PublishingManuscriptUploaded ||
          current is PublishingFailure,
      listener: (context, state) {
        if (state is PublishingResearchCreated) {
          _onResearchCreated(state.projectId);
        } else if (state is PublishingManuscriptUploaded) {
          _onManuscriptUploaded(state.version.projectId);
        } else if (state is PublishingFailure) {
          setState(() => _isSubmitting = false);
          AppErrorDialog.show(context, message: state.error.tr());
        }
      },
      builder: (context, state) {
        if (_isPipelineActive(state)) {
          return PublishingAiPipeline(state: state);
        }

        return UploadResearchForm(
          formKey: _formKey,
          titleController: _titleController,
          fileName: _selectedFileName,
          onPickFile: _mockPickFile,
          onSubmit: _onSubmit,
          enabled: !_isSubmitting,
        );
      },
    );
  }
}
