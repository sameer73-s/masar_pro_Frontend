import 'package:flutter/material.dart';
import '../../../../../../config/app_colors.dart';
import 'task_selection_form.dart';

class TaskSelectionBody extends StatelessWidget {
  const TaskSelectionBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر نوع المهمة المطلوبة',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سنقوم بتوليد المحتوى وفحصه من الانتحال وأنسنته ليكون طبيعياً 100%.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.slateGray,
            ),
          ),
          const SizedBox(height: 24),
          const TaskSelectionForm(),
        ],
      ),
    );
  }
}
