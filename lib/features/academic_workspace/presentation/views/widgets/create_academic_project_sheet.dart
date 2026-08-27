import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_colors.dart';
import '../../../../../config/app_theme.dart';
import '../../../../../core/presentation/widgets/custom_dropdown_field.dart';
import '../../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../../core/presentation/widgets/primary_button.dart';
import '../../bloc/academic_workspace_bloc/academic_workspace_bloc.dart';

class CreateAcademicProjectSheet extends StatefulWidget {
  const CreateAcademicProjectSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppShapes.cardRadius),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AcademicWorkspaceBloc>(),
        child: const CreateAcademicProjectSheet(),
      ),
    );
  }

  @override
  State<CreateAcademicProjectSheet> createState() =>
      _CreateAcademicProjectSheetState();
}

class _CreateAcademicProjectSheetState
    extends State<CreateAcademicProjectSheet> {
  final _titleController = TextEditingController();
  String? _academicLevel = 'Bachelor';
  String? _language = 'arabic';
  String? _error;

  static const _levels = [
    ('Bachelor', 'levelBachelor'),
    ('Master', 'levelMaster'),
    ('PhD', 'levelPhD'),
  ];
  static const _languages = [
    ('arabic', 'langArabic'),
    ('english', 'langEnglish'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'pleaseEnterProjectTitle'.tr());
      return;
    }
    if (_academicLevel == null || _language == null) {
      setState(() => _error = 'pleaseSelectLevelAndLanguage'.tr());
      return;
    }

    context.read<AcademicWorkspaceBloc>().add(
          CreateAcademicProjectRequested(
            title: title,
            academicLevel: _academicLevel!,
            language: _language!,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      key: ValueKey(locale.languageCode),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grayLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'newAcademicProject'.tr(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'newAcademicProjectSubtitle'.tr(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'projectTitle'.tr(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          CustomTextField(
            controller: _titleController,
            hintText: 'projectTitleHint'.tr(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 14),
          Text(
            'academicLevel'.tr(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          CustomDropdownField<String>(
            hintText: 'selectLevel'.tr(),
            value: _academicLevel,
            disableAutoSelect: true,
            items: _levels
                .map(
                  (level) => DropdownMenuItem(
                    value: level.$1,
                    child: Text(level.$2.tr()),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _academicLevel = value),
          ),
          const SizedBox(height: 14),
          Text(
            'language'.tr(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          CustomDropdownField<String>(
            hintText: 'selectLanguage'.tr(),
            value: _language,
            disableAutoSelect: true,
            items: _languages
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.$1,
                    child: Text(entry.$2.tr()),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _language = value),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'createProject'.tr(),
            onPressed: _submit,
            width: double.infinity,
            height: 48,
          ),
        ],
      ),
    );
  }
}
