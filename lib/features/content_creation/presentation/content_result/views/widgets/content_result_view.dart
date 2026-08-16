import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dio/dio.dart';
import '../../../../../../config/app_colors.dart';
import '../../../../../../core/network/api_config.dart';
import '../../../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../../../../core/presentation/widgets/app_success_dialog.dart';
import '../../../../../../core/presentation/widgets/primary_button.dart';
import '../../bloc/content_result_bloc.dart';
import '../../../../domain/entities/content_entity.dart';
import '../../../shared/widgets/smart_loading_overlay.dart';

class ContentResultView extends StatefulWidget {
  final String taskType;
  final String title;
  final Map<String, dynamic> payload;
  final Map<String, dynamic> resultData;
  final ContentEntity? content;
  final String? rejectionReason;

  const ContentResultView({
    super.key,
    required this.taskType,
    required this.title,
    required this.payload,
    required this.resultData,
    this.content,
    this.rejectionReason,
  });

  @override
  State<ContentResultView> createState() => _ContentResultViewState();
}

class _ContentResultViewState extends State<ContentResultView> {
  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _shareCardKey = GlobalKey();
  late String _currentContent;
  late double _currentPlagScore;
  double? _beforePlagScore;
  String? _downloadUrl;
  String? _reportUrl;
  String? _contentPdfUrl;

  bool _isLoading = false;
  int _loadingMessageIndex = 0;
  Timer? _loadingTimer;
  final List<String> _loadingMessages = [
    "جاري فحص النص المحسن... 🔍",
    "نحسّن الأسلوب ونبعد عن الذكاء الاصطناعي... ✨",
    "نفحص أصالة المحتوى... 🛡️",
    "نجهّز ملفك الجديد للتحميل... 📄"
  ];

  Future<void> _downloadAndOpenFile(String? relativeUrl) async {
    if (relativeUrl == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dio = Dio();
      final appDocDir = await getApplicationDocumentsDirectory();
      
      final uri = Uri.parse(relativeUrl);
      final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'downloaded_file';
      final savePath = '${appDocDir.path}/$fileName';

      final absoluteUrl = '${ApiConfig.normalizedBaseUrl}$relativeUrl';
      await dio.download(absoluteUrl, savePath);

      setState(() {
        _isLoading = false;
      });

      await AppSuccessDialog.show(
        context,
        message: 'تم تحميل الملف بنجاح: $fileName',
        okButtonText: 'فتح',
        onOk: () {
          OpenFilex.open(savePath);
        },
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AppErrorDialog.show(context, message: 'فشل تحميل الملف: $e');
    }
  }

  Future<void> _captureAndSaveCard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final boundary = _shareCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception("عنصر الرسم غير متوفر");
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("فشل تحويل الصورة إلى بيانات ثنائية");
      }
      final pngBytes = byteData.buffer.asUint8List();

      final appDocDir = await getApplicationDocumentsDirectory();
      final fileName = 'masar_pro_plagiarism_${DateTime.now().millisecondsSinceEpoch}.png';
      final savePath = '${appDocDir.path}/$fileName';
      final file = File(savePath);
      await file.writeAsBytes(pngBytes);

      setState(() {
        _isLoading = false;
      });

      await AppSuccessDialog.show(
        context,
        message: 'تم حفظ الصورة بنجاح: $fileName',
        okButtonText: 'عرض',
        onOk: () {
          OpenFilex.open(savePath);
        },
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AppErrorDialog.show(context, message: 'فشل حفظ بطاقة النسبة كصورة: $e');
    }
  }

  Widget _buildShareableCard() {
    final limit = _getTaskPlagLimit();
    final plagColor = _getPlagColor(_currentPlagScore);
    
    return Container(
      width: 420,
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A), // Deep Navy
            Color(0xFF1E293B), // Slate Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accentGold.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.accentGold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Masar Pro',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              Text(
                'وثيقة أصالة المحتوى',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          const Spacer(),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: _currentPlagScore / 100.0,
                      color: plagColor,
                      backgroundColor: plagColor.withOpacity(0.15),
                      strokeWidth: 8,
                    ),
                  ),
                  Text(
                    '${_currentPlagScore.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: plagColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'نسبة الاقتباس والانتحال الإجمالية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: plagColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: plagColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _currentPlagScore < limit
                            ? '✅ محتوى أصيل معتمد'
                            : '⚠️ يتجاوز الحد الأكاديمي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: plagColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الحد المسموح للمهمة: ${limit.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white38,
                  fontSize: 10,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                'تحقق ذكي بواسطة منصة مسار',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white38,
                  fontSize: 10,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _extractInitialData();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _extractInitialData() {
    if (widget.rejectionReason != null) {
      _currentContent = "";
      _currentPlagScore = 0.0;
      return;
    }

    String? contentText;
    if (widget.content != null) {
      contentText = widget.content!.generatedText;
    }

    final genResult = widget.resultData['generation_result'] ?? {};
    final humResult = widget.resultData['humanization_result'] ?? {};
    final audResult = widget.resultData['audit_result'] ?? {};
    final audBeforeResult = widget.resultData['audit_before_result'] ?? {};

    _currentContent = contentText ?? humResult['humanized_text'] ?? genResult['content'] ?? "";
    _currentPlagScore = (audResult['plagiarism_percentage'] as num?)?.toDouble() ?? 0.0;
    _beforePlagScore = (audBeforeResult['plagiarism_percentage'] as num?)?.toDouble();
    _downloadUrl = widget.resultData['download_url'];
    _reportUrl = widget.resultData['report_url'];
    _contentPdfUrl = widget.resultData['content_pdf_url'];
  }

  void _startLoadingMessages() {
    setState(() {
      _loadingMessageIndex = 0;
    });
    _loadingTimer?.cancel();
    _loadingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _loadingMessageIndex = (_loadingMessageIndex + 1) % _loadingMessages.length;
      });
    });
  }

  double _getTaskPlagLimit() {
    final isTechnical = ['research', 'literature_review', 'case_study', 'report'].contains(widget.taskType);
    return isTechnical ? 20.0 : 15.0;
  }

  Color _getPlagColor(double score) {
    final limit = _getTaskPlagLimit();
    if (score < limit) return const Color(0xFF16A34A); // Green
    if (score <= limit + 5.0) return const Color(0xFFD97706); // Orange
    return const Color(0xFFDC2626); // Red
  }

  bool _shouldShowImproveButton() {
    final limit = _getTaskPlagLimit();
    // Show only if score is between limit and limit + 5%
    return _currentPlagScore >= limit && _currentPlagScore <= limit + 5.0;
  }

  void _improveMore() {
    final isArabic = widget.payload['optional_fields']?['language'] != 'إنجليزي';
    context.read<ContentResultBloc>().add(
      ImproveContentRequested(
        text: _currentContent,
        isArabic: isArabic,
        useGemini: true,
      ),
    );
  }

  void _showErrorBottomSheet(String message) {
    AppErrorDialog.show(context, message: message);
  }

  Future<void> _launchUrl(String? relativeUrl) async {
    if (relativeUrl == null) return;
    final absoluteUrl = '${ApiConfig.normalizedBaseUrl}$relativeUrl';
    final uri = Uri.parse(absoluteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppErrorDialog.show(context, message: 'تعذر تحميل الملف من الخادم.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final plagColor = _getPlagColor(_currentPlagScore);
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<ContentResultBloc, ContentResultState>(
        listener: (context, state) {
          if (state is ContentImprovementLoading) {
            setState(() {
              _isLoading = true;
            });
            _startLoadingMessages();
          } else if (state is ContentImprovementSuccess) {
            setState(() {
              _isLoading = false;
            });
            _loadingTimer?.cancel();

            final data = state.result;
            setState(() {
              _beforePlagScore = (data['before_score'] as num?)?.toDouble() ?? _currentPlagScore;
              _currentPlagScore = (data['after_score'] as num?)?.toDouble() ?? _currentPlagScore;
              _currentContent = data['humanized_text'] ?? _currentContent;
              _downloadUrl = data['download_url'];
              _reportUrl = data['report_url'];
              _contentPdfUrl = data['content_pdf_url'];
            });

            AppSuccessDialog.show(
              context,
              message: 'تمت عملية الأنسنة والتحسين الإضافي بنجاح',
            );
          } else if (state is ContentResultFailure) {
            setState(() {
              _isLoading = false;
            });
            _loadingTimer?.cancel();
            _showErrorBottomSheet(state.message);
          }
        },
        child: Stack(
          children: [
            Positioned(
              left: -9999,
              top: -9999,
              child: RepaintBoundary(
                key: _shareCardKey,
                child: _buildShareableCard(),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.rejectionReason != null
                      ? [
                          _buildRejectionWidget(),
                        ]
                      : [
                          _buildPlagiarismCircleCard(plagColor),
                          const SizedBox(height: 20),
                          if (_beforePlagScore != null) _buildComparisonCard(),
                          const SizedBox(height: 20),
                          _buildContentCard(),
                          const SizedBox(height: 24),
                          _buildDownloadButtons(),
                          const SizedBox(height: 16),
                    if (_shouldShowImproveButton()) _buildImproveButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

            SmartLoadingOverlay(
              isLoading: _isLoading,
              message: _loadingMessages[_loadingMessageIndex],
              steps: const [
                "تحليل النص",
                "تحسين الصياغة",
                "فحص الجودة",
                "جاهز"
              ],
              currentStepIndex: _loadingMessageIndex,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlagiarismCircleCard(Color color) {
    final limit = _getTaskPlagLimit();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: _currentPlagScore / 100.0,
                  color: color,
                  backgroundColor: color.withOpacity(0.15),
                  strokeWidth: 7,
                ),
              ),
              Text(
                '${_currentPlagScore.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مؤشر الانتحال وأصالة النص',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.deepNavy),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentPlagScore < limit 
                      ? '✅ نسبة ممتازة ومقبولة أكاديمياً (الحد: $limit%)' 
                      : '⚠️ نسبة مرتفعة قليلاً، ننصح بطلب أنسنة إضافية',
                  style: TextStyle(fontSize: 12, color: color),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: AppColors.deepNavy),
            tooltip: 'تحميل كصورة للمشاركة',
            onPressed: _captureAndSaveCard,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نسب التحسن بعد الأنسنة:',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepNavy, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('قبل الأنسنة', style: TextStyle(color: AppColors.slateGray, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${_beforePlagScore!.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent)),
                ],
              ),
              Icon(Icons.arrow_back_rounded, color: AppColors.slateGray),
              Column(
                children: [
                  Text('بعد الأنسنة', style: TextStyle(color: AppColors.slateGray, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${_currentPlagScore.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المحتوى الأكاديمي المُولَّد',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.deepNavy),
              ),
              IconButton(
                icon: Icon(Icons.copy, color: AppColors.slateGray),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _currentContent));
                  AppSuccessDialog.show(
                    context,
                    message: 'تم نسخ النص إلى الحافظة',
                  );
                },
              )
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Text(
                _currentContent,
                style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.deepNavy),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDownloadButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'تحميل Word',
                onPressed: () => _downloadAndOpenFile(_downloadUrl),
                icon: Icons.description_outlined,
                height: 48,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                text: 'تحميل PDF',
                onPressed: () => _downloadAndOpenFile(_contentPdfUrl),
                icon: Icons.picture_as_pdf,
                height: 48,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _downloadAndOpenFile(_reportUrl),
            icon: Icon(Icons.analytics_outlined, color: Colors.redAccent),
            label: Text('تحميل تقرير الجودة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImproveButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      child: PrimaryButton(
        text: 'تحسين وأنسنة أكثر ✨',
        onPressed: _improveMore,
        icon: Icons.auto_fix_high,
        width: double.infinity,
        height: 52,
      ),
    );
  }

  Widget _buildRejectionWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.verified_user_outlined,
          color: Colors.redAccent,
          size: 80,
        ),
        const SizedBox(height: 24),
        Text(
          'فشل فحص الجودة الأكاديمية والمحتوى',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'السبب المكتشف من السيرفر:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.rejectionReason ?? 'النص المولد لم يجتز فحص الجودة، يرجى المحاولة بصياغة مختلفة للعنوان أو الملاحظات المرفقة.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'يرجى المحاولة بصياغة مختلفة للعنوان، أو تغيير أسلوب التوليد/الملاحظات المضافة لتخطي معايير الرفض الذاتي.',
          style: TextStyle(fontSize: 14, color: AppColors.slateGray),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          text: 'الرجوع وتعديل الطلب',
          onPressed: () => Navigator.pop(context),
          width: double.infinity,
          height: 54,
        ),
      ],
    );
  }
}
