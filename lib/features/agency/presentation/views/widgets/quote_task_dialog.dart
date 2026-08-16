import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_colors.dart';
import '../../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../../core/presentation/widgets/small_pill_button.dart';
import '../../bloc/agency_bloc/agency_bloc.dart';

class QuoteTaskDialog extends StatefulWidget {
  const QuoteTaskDialog({super.key, required this.taskId});

  final String taskId;

  static Future<void> show(BuildContext context, {required String taskId}) {
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AgencyBloc>(),
        child: QuoteTaskDialog(taskId: taskId),
      ),
    );
  }

  @override
  State<QuoteTaskDialog> createState() => _QuoteTaskDialogState();
}

class _QuoteTaskDialogState extends State<QuoteTaskDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null || parsed < 0) {
      setState(() => _error = 'Enter a valid non-negative price');
      return;
    }

    context.read<AgencyBloc>().add(
          QuoteTaskRequested(widget.taskId, parsed),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      title: const Text(
        'Quote Task',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter the quoted price for this task.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _controller,
            hintText: 'Price',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        SmallPillButton(
          label: 'Submit Quote',
          onPressed: _submit,
        ),
      ],
    );
  }
}
