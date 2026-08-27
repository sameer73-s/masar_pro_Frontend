import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/enums/citation_style.dart';
import '../../domain/enums/research_language.dart';
import '../../../../core/presentation/widgets/custom_app_bar.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../bloc/research_bloc.dart';
import '../bloc/research_event.dart';
import '../widgets/animated_progress_ring.dart';
import '../widgets/research_form_card.dart';

/// شاشة نموذج إعداد البحث
class ResearchFormScreen extends StatefulWidget {
  const ResearchFormScreen({super.key});

  @override
  State<ResearchFormScreen> createState() => _ResearchFormScreenState();
}

class _ResearchFormScreenState extends State<ResearchFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  late final TextEditingController _subjectController;
  final _universityController = TextEditingController();
  final _supervisorController = TextEditingController();
  final _studentController = TextEditingController();
  final _semesterController = TextEditingController();

  // State
  int _targetPages = 30;
  ResearchLanguage _language = ResearchLanguage.arabic;
  CitationStyle _citationStyle = CitationStyle.apa;

  @override
  void initState() {
    super.initState();
    _subjectController =
        TextEditingController(text: 'researchDefaultSubject'.tr());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _universityController.dispose();
    _supervisorController.dispose();
    _studentController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  String get _estimatedMinutes {
    if (_targetPages < 25) return '5–10';
    if (_targetPages < 40) return '10–18';
    return '18–30';
  }

  int get _estimatedSources => (_targetPages / 2).round();
  int get _estimatedWords => _targetPages * 280;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ResearchBloc>().add(
          StartResearchEvent(
            title: _titleController.text.trim(),
            targetPages: _targetPages,
            language: _language,
            citationStyle: _citationStyle,
            subjectArea: _subjectController.text.trim(),
            universityName: _universityController.text.trim(),
            supervisorName: _supervisorController.text.trim(),
            studentName: _studentController.text.trim(),
            academicSemester: _semesterController.text.trim(),
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: kBgLight,
        appBar: CustomAppBar(title: 'researchFormTitle'),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقة المعلومات الأساسية
                ResearchFormCard(
                  title: 'researchInfoSection'.tr(),
                  icon: Icons.menu_book_outlined,
                  child: _BasicFormFields(
                    titleController: _titleController,
                    subjectController: _subjectController,
                    targetPages: _targetPages,
                    language: _language,
                    citationStyle: _citationStyle,
                    onPagesChanged: (v) =>
                        setState(() => _targetPages = v.round()),
                    onLanguageChanged: (lang) =>
                        setState(() => _language = lang),
                    onCitationChanged: (cs) =>
                        setState(() => _citationStyle = cs),
                  ),
                ),
                const SizedBox(height: 16),

                // بطاقة الخيارات المتقدمة (قابلة للطي)
                ResearchFormCard(
                  title: 'researchExtraSection'.tr(),
                  icon: Icons.tune_outlined,
                  collapsible: true,
                  child: _AdvancedFormFields(
                    universityController: _universityController,
                    supervisorController: _supervisorController,
                    studentController: _studentController,
                    semesterController: _semesterController,
                  ),
                ),
                const SizedBox(height: 16),

                // بطاقة الوقت المقدر
                _EstimatedTimeCard(
                  pages: _targetPages,
                  estimatedMinutes: _estimatedMinutes,
                  estimatedSources: _estimatedSources,
                  estimatedWords: _estimatedWords,
                ),
                const SizedBox(height: 24),

                // زر البدء
                _StartButton(onPressed: _submit),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── حقول النموذج الأساسية ─────────────────────────────────────────────────

class _BasicFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController subjectController;
  final int targetPages;
  final ResearchLanguage language;
  final CitationStyle citationStyle;
  final ValueChanged<double> onPagesChanged;
  final ValueChanged<ResearchLanguage> onLanguageChanged;
  final ValueChanged<CitationStyle> onCitationChanged;

  const _BasicFormFields({
    required this.titleController,
    required this.subjectController,
    required this.targetPages,
    required this.language,
    required this.citationStyle,
    required this.onPagesChanged,
    required this.onLanguageChanged,
    required this.onCitationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. عنوان البحث
        TextFormField(
          controller: titleController,
          maxLines: 3,
          maxLength: 300,
          textDirection: Directionality.of(context),
          style: const TextStyle(
            fontSize: 16,
            color: kTextPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDecoration(
            hint: 'researchTitleHint'.tr(),
            label: 'researchTitleLabel'.tr(),
          ),
          validator: (v) {
            if (v == null || v.trim().length < 10) {
              return 'researchTitleMinLength'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // 2. التخصص
        TextFormField(
          controller: subjectController,
          textDirection: Directionality.of(context),
          decoration: _inputDecoration(
            hint: 'researchSubjectHint'.tr(),
            label: 'researchSubjectLabel'.tr(),
          ),
        ),
        const SizedBox(height: 20),

        // 3. عدد الصفحات
        Row(
          children: [
            Text(
              'researchPagesLabel'.tr(),
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: kTextPrimary),
            ),
            const SizedBox(width: 8),
            Text(
              'researchPagesCount'.tr(args: [targetPages.toString()]),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: kGoldAccent,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        Slider(
          value: targetPages.toDouble(),
          min: 15,
          max: 50,
          divisions: 7,
          activeColor: kGoldAccent,
          inactiveColor: kBorderColor,
          onChanged: onPagesChanged,
        ),
        Text(
          'researchApproxWords'.tr(args: [(targetPages * 280).toString()]),
          style: const TextStyle(
            fontSize: 12,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 20),

        // 4. لغة البحث
        Text(
          'researchLanguageLabel'.tr(),
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: kTextPrimary),
        ),
        const SizedBox(height: 8),
        _LanguageSelector(
          selected: language,
          onChanged: onLanguageChanged,
        ),
        const SizedBox(height: 20),

        // 5. أسلوب التوثيق
        Text(
          'researchCitationLabel'.tr(),
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: kTextPrimary),
        ),
        const SizedBox(height: 8),
        _CitationSelector(
          selected: citationStyle,
          onChanged: onCitationChanged,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      {required String hint, required String label}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: true,
      labelStyle:
          const TextStyle(color: kTextSecondary, fontSize: 13),
      hintStyle:
          const TextStyle(color: kTextSecondary, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: kGoldAccent, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(14),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final ResearchLanguage selected;
  final ValueChanged<ResearchLanguage> onChanged;

  const _LanguageSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ResearchLanguage.values.map((lang) {
        final isSelected = lang == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(lang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  left: lang == ResearchLanguage.arabic ? 0 : 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? kGoldAccent.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(kChipRadius),
                border: Border.all(
                  color: isSelected ? kGoldAccent : kBorderColor,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  '${lang.flag} ${lang.label}',
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected ? kGoldAccent : kTextSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CitationSelector extends StatelessWidget {
  final CitationStyle selected;
  final ValueChanged<CitationStyle> onChanged;

  const _CitationSelector(
      {required this.selected, required this.onChanged});

  String _tooltip(CitationStyle cs) => switch (cs) {
        CitationStyle.apa => 'researchCitationApaTooltip'.tr(),
        CitationStyle.mla => 'researchCitationMlaTooltip'.tr(),
        CitationStyle.chicago => 'researchCitationChicagoTooltip'.tr(),
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: CitationStyle.values.map((cs) {
        final isSelected = cs == selected;
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Tooltip(
            message: _tooltip(cs),
            child: ChoiceChip(
              label: Text(cs.label),
              selected: isSelected,
              onSelected: (_) => onChanged(cs),
              selectedColor: kGoldAccent.withOpacity(0.15),
              side: BorderSide(
                color: isSelected ? kGoldAccent : kBorderColor,
              ),
              labelStyle: TextStyle(
                color: isSelected ? kGoldAccent : kTextSecondary,
                fontWeight: isSelected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kChipRadius),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── حقول الخيارات المتقدمة ──────────────────────────────────────────────

class _AdvancedFormFields extends StatelessWidget {
  final TextEditingController universityController;
  final TextEditingController supervisorController;
  final TextEditingController studentController;
  final TextEditingController semesterController;

  const _AdvancedFormFields({
    required this.universityController,
    required this.supervisorController,
    required this.studentController,
    required this.semesterController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AdvancedField(
          controller: universityController,
          label: 'researchUniversityLabel'.tr(),
          hint: 'researchUniversityHint'.tr(),
          icon: Icons.school_outlined,
        ),
        const SizedBox(height: 12),
        _AdvancedField(
          controller: supervisorController,
          label: 'researchSupervisorLabel'.tr(),
          hint: 'researchSupervisorHint'.tr(),
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _AdvancedField(
          controller: studentController,
          label: 'researchStudentLabel'.tr(),
          hint: 'researchStudentHint'.tr(),
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 12),
        _AdvancedField(
          controller: semesterController,
          label: 'researchSemesterLabel'.tr(),
          hint: 'researchSemesterHint'.tr(),
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 4),
        Text(
          'researchCoverOnlyNote'.tr(),
          textDirection: Directionality.of(context),
          style: const TextStyle(
            fontSize: 11,
            color: kTextSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _AdvancedField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  const _AdvancedField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textDirection: Directionality.of(context),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: kTextSecondary, size: 20),
        labelStyle:
            const TextStyle(color: kTextSecondary, fontSize: 13),
        hintStyle:
            const TextStyle(color: kTextSecondary, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: kGoldAccent, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}

// ─── بطاقة الوقت المقدر ─────────────────────────────────────────────────

class _EstimatedTimeCard extends StatelessWidget {
  final int pages;
  final String estimatedMinutes;
  final int estimatedSources;
  final int estimatedWords;

  const _EstimatedTimeCard({
    required this.pages,
    required this.estimatedMinutes,
    required this.estimatedSources,
    required this.estimatedWords,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kResearchBg,
        borderRadius: BorderRadius.circular(kCardRadius),
        border: Border.all(
            color: kGoldAccent.withOpacity(0.4), width: 1.5),
      ),
      padding: cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stats row
          Row(
            children: [
              _EstimateStat(
                  value: pages.toString(),
                  label: 'researchStatPages'.tr()),
              const SizedBox(width: 10),
              _EstimateStat(
                  value: '~$estimatedMinutes',
                  label: 'researchStatMinutes'.tr()),
              const SizedBox(width: 10),
              _EstimateStat(
                  value: '~$estimatedSources',
                  label: 'researchStatSources'.tr()),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'researchEstimateIncludes'.tr(),
            textDirection: Directionality.of(context),
            style: const TextStyle(
              fontSize: 11,
              color: kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstimateStat extends StatelessWidget {
  final String value;
  final String label;

  const _EstimateStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: kGoldAccent.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kGoldAccent,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── زر البدء ─────────────────────────────────────────────────────────────

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _StartButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: 'researchStartNow'.tr(),
      onPressed: onPressed,
      icon: Icons.auto_awesome,
      width: double.infinity,
      height: 56,
    );
  }
}
