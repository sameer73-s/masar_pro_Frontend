import 'dart:async';
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

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<QualityBloc>(),
      child: const _AuditScreenBody(),
    );
  }
}

class _AuditScreenBody extends StatefulWidget {
  const _AuditScreenBody();

  @override
  State<_AuditScreenBody> createState() => _AuditScreenBodyState();
}

class _AuditScreenBodyState extends State<_AuditScreenBody> {
  final _textController = TextEditingController();

  int _selectedTab = 0; // 0: Text, 1: File
  PlatformFile? _selectedFile;
  String? _extractedFileName;
  bool _isExtractingFile = false;

  bool _isLoading = false;
  bool _isHumanizing = false;
  int _loadingMessageIndex = 0;
  Timer? _loadingTimer;
  final List<String> _loadingMessages = [
    "جاري فحص أصالة النص وتحليل الاقتباسات... 🔍",
    "نقوم بجمع ومطابقة المراجع العلمية... 📚",
    "نجهّز تقرير الفحص للتحميل... 📄"
  ];

  bool _hasChecked = false;
  double? _plagScore;
  String? _downloadUrl;
  String? _reportUrl;

  bool _hasHumanizedResult = false;
  double? _beforePlagScore;
  double? _afterPlagScore;
  String? _humanizedText;

  @override
  void dispose() {
    _textController.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _startLoadingTimer(List<String> messages) {
    setState(() {
      _loadingMessageIndex = 0;
    });
    _loadingTimer?.cancel();
    _loadingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _loadingMessageIndex = (_loadingMessageIndex + 1) % messages.length;
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

  void _runAudit() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      AppErrorDialog.show(
        context,
        message: 'يرجى إدخال نص أو رفع ملف أولاً',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    _startLoadingTimer(_loadingMessages);
    context.read<QualityBloc>().add(AuditOnlyEvent(text: text));
  }

  void _runHumanizeFlow() {
    setState(() {
      _isHumanizing = true;
    });
    _startLoadingTimer([
      "جاري الأنسنة وصياغة الأسلوب... ✨",
      "نقوم بفحص النص المحسن مجدداً... 🛡️",
      "نجهّز ملفات التحميل النهائية... 📄"
    ]);
    context.read<QualityBloc>().add(
          CheckThenHumanizeEvent(text: _textController.text.trim()),
        );
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
        message: 'تم استخراج النص من الملف بنجاح',
      );
      return;
    }

    if (state is QualityAuditing && !_isHumanizing) {
      setState(() => _isLoading = true);
      return;
    }

    if (state is QualityHumanizing) {
      setState(() => _isHumanizing = true);
      return;
    }

    if (state is QualityAuditSuccess) {
      setState(() {
        _isLoading = false;
        _hasChecked = true;
        _plagScore = state.auditResult.plagiarismPercentage.toDouble();
        _downloadUrl = state.auditResult.downloadUrl;
        _reportUrl = state.auditResult.reportUrl;
      });
      _loadingTimer?.cancel();
      return;
    }

    if (state is QualityCheckThenHumanizeSuccess) {
      final data = state.result;
      setState(() {
        _isHumanizing = false;
        _hasHumanizedResult = true;
        _beforePlagScore = data.beforeScore;
        _afterPlagScore = data.afterScore;
        _humanizedText = data.humanizedText;
        _downloadUrl = data.downloadUrl;
        _reportUrl = data.reportUrl;
      });
      _loadingTimer?.cancel();
      return;
    }

    if (state is QualityFailure) {
      setState(() {
        _isLoading = false;
        _isHumanizing = false;
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
      AppErrorDialog.show(context, message: 'تعذر تحميل الملف.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QualityBloc, QualityState>(
      listener: (context, state) => _onQualityState(state),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.background,
              appBar: const CustomAppBar(title: 'فحص انتحال واقتباس النصوص'),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_hasChecked) ...[
                      _buildInputTabs(),
                      const SizedBox(height: 20),
                      _buildInputField(),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: 'افحص أصالة النص الآن',
                        onPressed: _runAudit,
                        icon: Icons.verified_outlined,
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
                            _hasChecked = false;
                            _hasHumanizedResult = false;
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
                          'إجراء فحص جديد',
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
            if (_isLoading || _isHumanizing)
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
                            _isLoading
                                ? _loadingMessages[_loadingMessageIndex]
                                : "جاري الأنسنة وصياغة الأسلوب... ✨",
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
              label: const Text('كتابة النص'),
              selected: _selectedTab == 0,
              onSelected: (val) {
                if (val) setState(() => _selectedTab = 0);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceChip(
              label: const Text('رفع ملف'),
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
          decoration: const InputDecoration(
            hintText: 'أدخل النص المطلوب فحص انتحاله واقتباسه هنا...',
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
              'جاري تحليل ملفك واستخراج النصوص...',
              style: TextStyle(color: AppColors.slateGray),
            ),
          ] else ...[
            Icon(Icons.upload_file_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'الملفات المدعومة: .txt / .docx / .pdf',
              style: TextStyle(color: AppColors.slateGray, fontSize: 13),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'اختر ملفاً من جهازك',
              onPressed: _pickFile,
              width: double.infinity,
              height: 48,
            ),
            if (_extractedFileName != null) ...[
              const SizedBox(height: 16),
              Text(
                'تم تحميل: $_extractedFileName ✅',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    if (_hasHumanizedResult) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text(
                  'نتائج الأنسنة وتحسين الجودة',
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
                        Text('نسبة الانتحال قبل', style: TextStyle(color: AppColors.slateGray, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(
                          '$_beforePlagScore%',
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
                        Text('نسبة الانتحال بعد', style: TextStyle(color: AppColors.slateGray, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(
                          '${_afterPlagScore?.toStringAsFixed(1)}%',
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
                  'النص المحسن بالكامل:',
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
                  text: 'تحميل الملف (.docx)',
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
                  label: const Text(
                    'تقرير الفحص (.pdf)',
                    style: TextStyle(
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

    final double score = _plagScore ?? 0.0;
    late Color badgeColor;
    late String badgeText;
    late String message;

    if (score < 20.0) {
      badgeColor = const Color(0xFF16A34A);
      badgeText = 'آمن ✅';
      message = 'نسبة الانتحال ممتازة ومقبولة أكاديمياً.';
    } else if (score <= 50.0) {
      badgeColor = const Color(0xFFD97706);
      badgeText = 'متوسط ⚠️';
      message = 'نسبة الانتحال مرتفعة، ننصح بشدة بتفعيل خيار أنسنة النص وصياغته بأسلوب بشري.';
    } else {
      badgeColor = const Color(0xFFDC2626);
      badgeText = 'مرتفع جداً 🔴';
      message = 'نسبة الانتحال عالية جداً! خيار الأنسنة سيحسن النتيجة بشكل كبير، ولكن قد تحتاج إلى مراجعة وتعديل يدوي لاحقاً.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '$badgeText ($score%)',
              style: TextStyle(color: badgeColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.slateGray, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'أنسنة وتعديل النص ✨',
            onPressed: _runHumanizeFlow,
            icon: Icons.auto_fix_high,
            width: double.infinity,
            height: 50,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _launchUrl(_reportUrl),
            icon: Icon(Icons.download, color: AppColors.deepNavy),
            label: Text(
              'تحميل تقرير الفحص (.pdf)',
              style: TextStyle(color: AppColors.deepNavy, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.deepNavy),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
