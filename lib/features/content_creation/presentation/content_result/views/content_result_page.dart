import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/content_entity.dart';
import '../../../../../injection/injection_container.dart' as di;
import '../bloc/content_result_bloc.dart';
import 'widgets/content_result_body.dart';

class ContentResultPage extends StatelessWidget {
  final String taskType;
  final String title;
  final Map<String, dynamic> payload;
  final Map<String, dynamic>? resultData;
  final ContentEntity? content;
  final String? rejectionReason;

  const ContentResultPage({
    super.key,
    required this.taskType,
    required this.title,
    required this.payload,
    this.resultData,
    this.content,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<ContentResultBloc>(),
      child: ContentResultBody(
        taskType: taskType,
        title: title,
        payload: payload,
        resultData: resultData ?? payload,
        content: content,
        rejectionReason: rejectionReason,
      ),
    );
  }
}
