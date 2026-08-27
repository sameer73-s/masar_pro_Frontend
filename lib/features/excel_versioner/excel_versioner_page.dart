import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/app_colors.dart';
import '../../core/presentation/widgets/app_error_dialog.dart';
import '../../core/presentation/widgets/custom_app_bar.dart';
import '../../core/presentation/widgets/primary_button.dart';
import '../../core/utils/responsive_layout.dart';
import '../../injection/injection_container.dart' as di;
import 'presentation/bloc/excel_versioner_bloc.dart';
import 'presentation/bloc/excel_versioner_event.dart';
import 'presentation/bloc/excel_versioner_state.dart';
import 'widgets/upload_card.dart';
import 'widgets/options_card.dart';
import 'widgets/results_card.dart';

class ExcelVersionerPage extends StatelessWidget {
  const ExcelVersionerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<ExcelVersionerBloc>(),
      child: const _ExcelVersionerView(),
    );
  }
}

class _ExcelVersionerView extends StatefulWidget {
  const _ExcelVersionerView();

  @override
  State<_ExcelVersionerView> createState() => _ExcelVersionerViewState();
}

class _ExcelVersionerViewState extends State<_ExcelVersionerView> {
  PlatformFile? _selectedFile;
  final TextEditingController _promptController = TextEditingController();
  int _versionCount = 2;
  bool _changeStyle = false;
  bool _changeNumbers = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _onReset(BuildContext context) {
    setState(() {
      _selectedFile = null;
      _promptController.clear();
      _versionCount = 2;
      _changeStyle = false;
      _changeNumbers = false;
    });
    context.read<ExcelVersionerBloc>().add(const ResetExcelVersioner());
  }

  void _submit(BuildContext context) {
    if (_selectedFile == null) {
      AppErrorDialog.show(context, message: 'pleaseSelectExcelFile'.tr());
      return;
    }
    if (_promptController.text.trim().isEmpty) {
      AppErrorDialog.show(
        context,
        message: 'pleaseEnterModificationPrompt'.tr(),
      );
      return;
    }

    context.read<ExcelVersionerBloc>().add(
          GenerateVersionsRequested(
            file: _selectedFile!,
            prompt: _promptController.text.trim(),
            versionCount: _versionCount,
            changeStyle: _changeStyle,
            changeNumbers: _changeNumbers,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'excelVersionerTitle'),
      body: BlocConsumer<ExcelVersionerBloc, ExcelVersionerState>(
        listener: (context, state) {
          if (state is ExcelVersionerFailure) {
            AppErrorDialog.show(context, message: state.message);
          }
        },
        builder: (context, state) {
          final isProcessing =
              state is ExcelVersionerUploading || state is ExcelVersionerProcessing;
          final isSuccess = state is ExcelVersionerSuccess;

          final content = SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UploadCard(
                  selectedFile: _selectedFile,
                  onFileSelected: (file) {
                    setState(() => _selectedFile = file);
                  },
                  onClear: () {
                    setState(() => _selectedFile = null);
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColors.slateGray.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: AppColors.deepNavy,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'modificationDescriptionTitle'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Directionality(
                          textDirection: Directionality.of(context),
                          child: TextField(
                            controller: _promptController,
                            maxLines: 5,
                            enabled: !isProcessing && !isSuccess,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'modificationPromptHint'.tr(),
                              hintStyle: TextStyle(
                                color: AppColors.slateGray.withValues(alpha: 0.5),
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.accentGold,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.deepNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OptionsCard(
                  versionCount: _versionCount,
                  changeStyle: _changeStyle,
                  changeNumbers: _changeNumbers,
                  onVersionCountChanged: isProcessing || isSuccess
                      ? (val) {}
                      : (val) => setState(() => _versionCount = val),
                  onStyleChanged: isProcessing || isSuccess
                      ? (val) {}
                      : (val) => setState(() => _changeStyle = val),
                  onNumbersChanged: isProcessing || isSuccess
                      ? (val) {}
                      : (val) => setState(() => _changeNumbers = val),
                ),
                const SizedBox(height: 16),
                if (!isSuccess)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.slateGray.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          if (isProcessing) ...[
                            Text(
                              state is ExcelVersionerUploading
                                  ? 'uploadingFileCalculatingCells'.tr()
                                  : 'creatingVersionOf'.tr(args: [
                                      '${(state as ExcelVersionerProcessing).currentVersion}',
                                      '${state.totalVersions}',
                                    ]),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.deepNavy,
                              ),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              color: AppColors.accentGold,
                              backgroundColor: AppColors.background,
                              minHeight: 6,
                            ),
                          ] else
                            PrimaryButton(
                              text: 'createVersions'.tr(),
                              onPressed: () => _submit(context),
                              icon: Icons.rocket_launch_outlined,
                              width: double.infinity,
                              height: 52,
                            ),
                        ],
                      ),
                    ),
                  ),
                if (state is ExcelVersionerSuccess) ...[
                  const SizedBox(height: 16),
                  ResultsCard(
                    versions: state.versions,
                    zipUrl: state.zipUrl,
                    processingTime: state.processingTime,
                    onReset: () => _onReset(context),
                  ),
                ],
              ],
            ),
          );

          return ResponsiveLayout(
            mobile: content,
            tablet: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: content,
              ),
            ),
            desktop: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }
}
