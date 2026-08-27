import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/app_colors.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../../core/presentation/widgets/app_success_dialog.dart';
import '../../../../core/presentation/widgets/custom_app_bar.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../injection/injection_container.dart' as di;
import '../bloc/quality_bloc.dart';
import '../bloc/quality_event.dart';
import '../bloc/quality_state.dart';

class HumanizeScreen extends StatelessWidget {
  const HumanizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<QualityBloc>(),
      child: const _HumanizeScreenBody(),
    );
  }
}

class _HumanizeScreenBody extends StatefulWidget {
  const _HumanizeScreenBody();

  @override
  State<_HumanizeScreenBody> createState() => _HumanizeScreenBodyState();
}

class _HumanizeScreenBodyState extends State<_HumanizeScreenBody> {
  final _textController = TextEditingController();

  int _selectedTab = 0; // 0: Text, 1: File
  PlatformFile? _selectedFile;
  String? _extractedFileName;
  bool _isExtractingFile = false;

  bool _isLoading = false;
  int _loadingMessageIndex = 0;
  Timer? _loadingTimer;
  static const _loadingMessageKeys = [
    'humanizeLoadingMsg1',
    'humanizeLoadingMsg2',
    'humanizeLoadingMsg3',
    'humanizeLoadingMsg4',
  ];

  bool _hasResult = false;
  bool _needsHumanization = true;
  double _beforeScore = 0.0;
  double? _afterScore;
  String? _humanizedText;
  String? _downloadUrl;
  String? _reportUrl;

  @override
  void dispose() {
    _textController.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _startLoadingTimer() {
    setState(() {
      _loadingMessageIndex = 0;
    });
    _loadingTimer?.cancel();
    _loadingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _loadingMessageIndex =
            (_loadingMessageIndex + 1) % _loadingMessageKeys.length;
      });
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'docx', 'pdf'],
    );
    if (result == null || result.files.isEmpty) return;

    setState(() {
      _selectedFile = result.files.first;
      _isExtractingFile = true;
      _extractedFileName = _selectedFile!.name;
    });

    if (!mounted) return;
    context.read<QualityBloc>().add(ExtractTextEvent(file: _selectedFile!));
  }

  void _runCheckThenHumanize() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      AppErrorDialog.show(
        context,
        message: 'pleaseEnterInput'.tr(),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    _startLoadingTimer();
    context.read<QualityBloc>().add(CheckThenHumanizeEvent(text: text));
  }

  void _onQualityState(QualityState state) {
    if (state is QualityExtractingText) {
      setState(() => _isExtractingFile = true);
      return;
    }

    if (state is QualityTextExtracted) {
      setState(() {
        _textController.text = state.text;
        _isExtractingFile = false;
      });
      AppSuccessDialog.show(
        context,
        message: 'textExtractedSuccess'.tr(),
      );
      return;
    }

    if (state is QualityHumanizing) {
      setState(() => _isLoading = true);
      return;
    }

    if (state is QualityCheckThenHumanizeSuccess) {
      final data = state.result;
      setState(() {
        _isLoading = false;
        _hasResult = true;
        _beforeScore = data.beforeScore;
        _afterScore = data.afterScore;
        _humanizedText = data.humanizedText;
        _needsHumanization = data.needsHumanization;
        _downloadUrl = data.downloadUrl;
        _reportUrl = data.reportUrl;
      });
      _loadingTimer?.cancel();
      return;
    }

    if (state is QualityFailure) {
      setState(() {
        _isLoading = false;
        _isExtractingFile = false;
        if (_selectedFile != null && _textController.text.isEmpty) {
          _selectedFile = null;
          _extractedFileName = null;
        }
      });
      _loadingTimer?.cancel();
      _showErrorBottomSheet(state.message);
    }
  }

  void _showErrorBottomSheet(String message) {
    AppErrorDialog.show(context, message: message);
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null) return;
    final absoluteUrl = '${ApiConfig.normalizedBaseUrl}$url';
    final uri = Uri.parse(absoluteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      AppErrorDialog.show(context, message: 'downloadFailed'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QualityBloc, QualityState>(
      listener: (context, state) => _onQualityState(state),
      child: Directionality(
        textDirection: Directionality.of(context),
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.background,
              appBar: CustomAppBar(title: 'humanizeScreenTitle'),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_hasResult) ...[
                      _buildInputTabs(),
                      const SizedBox(height: 20),
                      _buildInputField(),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: 'checkAndHumanizeButton'.tr(),
                        onPressed: _runCheckThenHumanize,
                        icon: Icons.security,
                        width: double.infinity,
                        height: 52,
                      ),
                    ] else ...[
                      _buildResultsView(),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () {
                          context.read<QualityBloc>().add(ResetQualityEvent());
                          setState(() {
                            _hasResult = false;
                            _textController.clear();
                            _selectedFile = null;
                            _extractedFileName = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.deepNavy),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'newAuditButton'.tr(),
                          style: TextStyle(
                            color: AppColors.deepNavy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.85),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.accentGold,
                          strokeWidth: 5,
                        ),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            _loadingMessageKeys[_loadingMessageIndex].tr(),
                            key: ValueKey<int>(_loadingMessageIndex),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: Text('writeTextTab'.tr()),
              selected: _selectedTab == 0,
              onSelected: (val) {
                if (val) setState(() => _selectedTab = 0);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceChip(
              label: Text('uploadFileTab'.tr()),
              selected: _selectedTab == 1,
              onSelected: (val) {
                if (val) setState(() => _selectedTab = 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    if (_selectedTab == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: TextField(
          controller: _textController,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: 'humanizeTextHint'.tr(),
            border: InputBorder.none,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          if (_isExtractingFile) ...[
            CircularProgressIndicator(color: AppColors.accentGold),
            const SizedBox(height: 16),
            Text(
              'extractingFileText'.tr(),
              style: TextStyle(color: AppColors.slateGray),
            ),
          ] else ...[
            Icon(Icons.upload_file_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'qualitySupportedFileTypes'.tr(),
              style: TextStyle(color: AppColors.slateGray, fontSize: 13),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'chooseFileFromDevice'.tr(),
              onPressed: _pickFile,
              width: double.infinity,
              height: 48,
            ),
            if (_extractedFileName != null) ...[
              const SizedBox(height: 16),
              Text(
                'fileUploadedNamed'.tr(args: [_extractedFileName!]),
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    if (!_needsHumanization) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            const Icon(Icons.verified_user_rounded, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'plagiarismPercentOk'.tr(args: ['$_beforeScore']),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              'textAcceptedNoRewrite'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slateGray),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'downloadOriginalDocx'.tr(),
              onPressed: () => _launchUrl(_downloadUrl),
              icon: Icons.download,
              width: double.infinity,
              height: 50,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Text(
                'plagiarismQualityComparison'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('beforeHumanize'.tr(), style: TextStyle(color: AppColors.slateGray, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        '$_beforeScore%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_back_rounded, color: AppColors.slateGray, size: 28),
                  Column(
                    children: [
                      Text('afterHumanize'.tr(), style: TextStyle(color: AppColors.slateGray, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        '${_afterScore?.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'humanizedTextPreview'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepNavy),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: SingleChildScrollView(
                  child: Text(
                    _humanizedText ?? "",
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
              Expanded(
                child: PrimaryButton(
                  text: 'downloadHumanizedDocx'.tr(),
                  onPressed: () => _launchUrl(_downloadUrl),
                  icon: Icons.description,
                  height: 48,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launchUrl(_reportUrl),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                label: Text(
                  'auditReportPdf'.tr(),
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
