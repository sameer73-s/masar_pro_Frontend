import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_colors.dart';
import '../../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../../core/presentation/widgets/primary_button.dart';
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
      setState(() => _error = 'enterValidNonNegativePrice'.tr());
      return;
    }

    context.read<AgencyBloc>().add(QuoteTaskRequested(widget.taskId, parsed));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      title: Text(
        'quoteTask'.tr(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'enterQuotedPriceHint'.tr(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _controller,
            hintText: 'price',
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
        PrimaryButton(
          text: 'cancel'.tr(),
          onPressed: () => Navigator.of(context).pop(),
          width: 96,
          height: 42,
          backgroundColor: AppColors.surfacePurple,
          textColor: AppColors.textSecondary,
          borderRadius: 10,
        ),
        PrimaryButton(
          text: 'submitQuote'.tr(),
          onPressed: _submit,
          width: 132,
          height: 42,
          borderRadius: 10,
        ),
      ],
    );
  }
}
