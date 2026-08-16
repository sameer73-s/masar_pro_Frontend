import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../config/app_colors.dart';
import '../../../../../../config/strings.dart';
import '../../../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../bloc/smart_parser_bloc.dart';
import '../../bloc/smart_parser_event.dart';
import '../../bloc/smart_parser_state.dart';
import 'smart_upload_card.dart';

class SmartParserForm extends StatefulWidget {
  final String? initialText;
  final dynamic initialFiles;

  const SmartParserForm({super.key, this.initialText, this.initialFiles});

  @override
  State<SmartParserForm> createState() => _SmartParserFormState();
}

class _SmartParserFormState extends State<SmartParserForm> {
  late final TextEditingController _textController;
  late List<PlatformFile> _selectedFiles;

  String? _orderId;
  final List<String> _uploadedUrls = [];
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  int _currentUploadingIndex = -1;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
    
    // Using dynamic for initialFiles to avoid strict type casting issues if passed incorrectly
    if (widget.initialFiles != null && widget.initialFiles is List<PlatformFile>) {
      _selectedFiles = List<PlatformFile>.from(widget.initialFiles as List);
    } else {
      _selectedFiles = [];
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  void _startUploadFlow() {
    if (_selectedFiles.isEmpty) return;
    _orderId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _isUploading = true;
      _currentUploadingIndex = 0;
      _uploadedUrls.clear();
      _uploadProgress = 0.0;
    });
    _uploadNextFile();
  }

  void _uploadNextFile() {
    if (_currentUploadingIndex < _selectedFiles.length) {
      final file = _selectedFiles[_currentUploadingIndex];
      if (file.path != null) {
        context.read<SmartParserBloc>().add(
          UploadAttachmentRequested(orderId: _orderId!, file: File(file.path!)),
        );
      } else {
        _currentUploadingIndex++;
        _uploadNextFile();
      }
    } else {
      setState(() {
        _isUploading = false;
        _currentUploadingIndex = -1;
      });
      final text = _textController.text.trim();
      context.read<SmartParserBloc>().add(
        AnalyzeInputRequested(
          text: text,
          files: const [],
          preUploadedUrls: _uploadedUrls,
        ),
      );
    }
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedFiles.isEmpty) {
      AppErrorDialog.show(context, message: Strings.pleaseEnterInput.tr());
      return;
    }

    if (_selectedFiles.isNotEmpty) {
      _startUploadFlow();
    } else {
      context.read<SmartParserBloc>().add(
        AnalyzeInputRequested(text: text, files: const []),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmartParserBloc, SmartParserState>(
      builder: (context, state) {
        if (state is SmartParserLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator.adaptive(),
                const SizedBox(height: 16),
                Text(
                  'جاري تحليل النص...',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ],
            ),
          );
        }

        if (_isUploading || state is UploadInProgress || (state is UploadSuccess && _isUploading)) {
          double effectiveProgress = _uploadProgress;
          if (state is UploadInProgress) {
            final fileWeight = 1.0 / _selectedFiles.length;
            final completedWeight = _currentUploadingIndex * fileWeight;
            effectiveProgress = completedWeight + (state.progress * fileWeight);
          } else if (state is UploadSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _uploadedUrls.add(state.secureUrl);
                  _currentUploadingIndex++;
                  _uploadNextFile();
                });
              }
            });
          }

          final percentage = (effectiveProgress * 100).toStringAsFixed(0);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 64,
                    color: AppColors.deepNavy,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'جاري الرفع... $percentage%',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: effectiveProgress,
                      minHeight: 10,
                      backgroundColor: const Color(0x3364748B), // slateGray with opacity
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ملف ${_currentUploadingIndex + 1} من ${_selectedFiles.length}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.slateGray,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SmartUploadCard(
              textController: _textController,
              selectedFiles: _selectedFiles,
              onPickFiles: _pickFiles,
              onSubmit: _submit,
            ),
          ),
        );
      },
    );
  }
}
