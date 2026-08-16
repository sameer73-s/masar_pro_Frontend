import 'package:flutter/material.dart';
import '../../../../../../config/app_colors.dart';
import '../../../../../../core/presentation/widgets/custom_app_bar.dart';
import '../../../../domain/entities/content_entity.dart';
import 'content_result_view.dart';

class ContentResultBody extends StatelessWidget {
  final String taskType;
  final String title;
  final Map<String, dynamic> payload;
  final Map<String, dynamic> resultData;
  final ContentEntity? content;
  final String? rejectionReason;

  const ContentResultBody({
    super.key,
    required this.taskType,
    required this.title,
    required this.payload,
    required this.resultData,
    this.content,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'نتيجة صناعة المحتوى'),
      body: ContentResultView(
        taskType: taskType,
        title: title,
        payload: payload,
        resultData: resultData,
        content: content,
        rejectionReason: rejectionReason,
      ),
    );
  }
}
