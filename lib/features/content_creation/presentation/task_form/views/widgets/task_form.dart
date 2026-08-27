import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../config/app_colors.dart';
import '../../../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../../../../core/presentation/widgets/primary_button.dart';
import '../../../../../../core/presentation/widgets/small_pill_button.dart';
import '../../../../domain/entities/content_entity.dart';
import '../../bloc/task_form_bloc.dart';
import '../../../task_selection/views/widgets/task_selection_form.dart';
import '../../../shared/widgets/smart_loading_overlay.dart';

class TaskForm extends StatefulWidget {
  final TaskItem task;

  const TaskForm({super.key, required this.task});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final Map<String, dynamic> _optionalValues = {};
  
  bool _isTitleNotEmpty = false;
  bool _isLoading = false;
  
  // Loading messages rotation
  int _loadingMessageIndex = 0;
  Timer? _loadingTimer;

  List<String> get _loadingMessages => [
        'loadingAnalyzingYourText'.tr(),
        'loadingGatheringSources'.tr(),
        'loadingImprovingStyle'.tr(),
        'loadingCheckingOriginality'.tr(),
        'loadingPreparingFile'.tr(),
      ];

  // Specific inputs state
  String _language = 'عربي';
  String _citationStyle = 'APA';
  String _reportType = 'تقني';
  String _focusType = 'أفكار رئيسية';
  bool _preserveFormatting = true;
  String _tone = 'رسمي';
  double _paraphraseLevel = 0.5; // 0.0: Light, 0.5: Medium, 1.0: Full
  
  // Tabs state for file/text inputs
  int _selectedInputTab = 0; // 0: Text, 1: File
  String _textInputContent = "";
  PlatformFile? _selectedFile;
  bool _isFileExtracting = false;
  String? _extractedFileName;

  // Reference Files States (for Task 3 uploading)
  final List<PlatformFile> _referenceFiles = [];
  final List<String> _referenceUrls = [];
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  int _currentUploadingIndex = -1;
  late final String _contentId;

  // CV chips
  final List<String> _skillsList = [];
  final _skillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contentId = FirebaseFirestore.instance.collection('contents').doc().id;
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _skillController.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _onTitleChanged() {
    setState(() {
      _isTitleNotEmpty = _titleController.text.trim().isNotEmpty;
    });
  }

  void _startLoadingMessages() {
    setState(() {
      _loadingMessageIndex = 0;
    });
    _loadingTimer?.cancel();
    _loadingTimer = Timer.periodic( Duration(seconds: 4), (timer) {
      setState(() {
        _loadingMessageIndex = (_loadingMessageIndex + 1) % _loadingMessages.length;
      });
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'docx', 'pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _isFileExtracting = true;
          _extractedFileName = _selectedFile!.name;
        });

        // Trigger extraction via Bloc
        context.read<TaskFormBloc>().add(ExtractTextRequested(_selectedFile!));
      }
    } catch (e) {
      setState(() {
        _isFileExtracting = false;
        _selectedFile = null;
        _extractedFileName = null;
      });
      _showErrorBottomSheet('filePickFailed'.tr());
    }
  }

  Future<void> _pickReferenceFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _referenceFiles.addAll(result.files);
        });
      }
    } catch (e) {
      _showErrorBottomSheet('referenceFilesPickFailed'.tr());
    }
  }

  void _removeReferenceFile(int index) {
    setState(() {
      _referenceFiles.removeAt(index);
    });
  }

  void _startUploadFlow() {
    setState(() {
      _isUploading = true;
      _currentUploadingIndex = 0;
      _referenceUrls.clear();
      _uploadProgress = 0.0;
    });
    _uploadNextReferenceFile();
  }

  void _uploadNextReferenceFile() {
    if (_currentUploadingIndex < _referenceFiles.length) {
      final file = _referenceFiles[_currentUploadingIndex];
      if (file.path != null) {
        context.read<TaskFormBloc>().add(
              UploadReferenceFileRequested(
                contentId: _contentId,
                file: File(file.path!),
              ),
            );
      } else {
        _currentUploadingIndex++;
        _uploadNextReferenceFile();
      }
    } else {
      setState(() {
        _isUploading = false;
        _currentUploadingIndex = -1;
      });
      _submitGenerationRequest();
    }
  }

  void _submitGenerationRequest() {
    final promptText = _optionalValues['prompt'] ?? 
        (_textInputContent.trim().isNotEmpty ? _textInputContent.trim() : _titleController.text.trim());

    final promptDetails = PromptDetailsEntity(
      prompt: promptText,
      tone: _tone,
      keywords: _skillsList.isNotEmpty ? _skillsList : [],
      additionalContext: _optionalValues.containsKey('notes') ? _optionalValues['notes']?.toString() : null,
    );

    final Map<String, dynamic> optionalFields = {
      'language': _language,
      'citation_style': _citationStyle,
      ..._optionalValues
    };

    if (widget.task.key == 'presentation') {
      optionalFields['tone'] = _tone;
    } else if (widget.task.key == 'report') {
      optionalFields['report_type'] = _reportType;
    } else if (widget.task.key == 'summary') {
      optionalFields['focus'] = _focusType;
    } else if (widget.task.key == 'translation') {
      optionalFields['preserve_formatting'] = _preserveFormatting;
      optionalFields['text'] = _textInputContent;
    } else if (widget.task.key == 'paraphrase') {
      String levelStr = "متوسطة";
      if (_paraphraseLevel == 0.0) levelStr = "خفيفة";
      if (_paraphraseLevel == 1.0) levelStr = "كاملة";
      optionalFields['level'] = levelStr;
      optionalFields['text'] = _textInputContent;
    } else if (widget.task.key == 'cv') {
      optionalFields['skills'] = _skillsList;
    }

    context.read<TaskFormBloc>().add(
          GenerateContentRequested(
            contentId: _contentId,
            taskType: widget.task.key,
            title: _titleController.text.trim(),
            promptDetails: promptDetails,
            referenceFiles: _referenceUrls,
          ),
        );
  }

  void _showErrorBottomSheet(String message) {
    AppErrorDialog.show(
      context,
      message: message,
      okButtonText: 'retry'.tr(),
      onOk: _generateContent,
      secondaryButtonText: 'close'.tr(),
      onSecondaryAction: () {},
    );
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'عربي':
        return 'langArabic'.tr();
      case 'إنجليزي':
        return 'langEnglish'.tr();
      case 'كلاهما':
        return 'langBoth'.tr();
      default:
        return code;
    }
  }

  String _reportTypeLabel(String code) {
    switch (code) {
      case 'تقني':
        return 'reportTypeTechnical'.tr();
      case 'إداري':
        return 'reportTypeAdministrative'.tr();
      case 'علمي':
        return 'reportTypeScientific'.tr();
      case 'ميداني':
        return 'reportTypeField'.tr();
      default:
        return code;
    }
  }

  String _focusLabel(String code) {
    switch (code) {
      case 'أفكار رئيسية':
        return 'focusMainIdeas'.tr();
      case 'نقد وتقييم':
        return 'focusCritique'.tr();
      case 'تحليل مقارن':
        return 'focusComparative'.tr();
      default:
        return code;
    }
  }

  String _citationLabel(String code) {
    if (code == 'هارفارد') return 'citationHarvard'.tr();
    return code;
  }

  String _paraphraseLevelLabel() {
    if (_paraphraseLevel == 0.0) return 'paraphraseLight'.tr();
    if (_paraphraseLevel == 1.0) return 'paraphraseFull'.tr();
    return 'paraphraseMedium'.tr();
  }

  void _generateContent() {
    if (_referenceFiles.isNotEmpty) {
      _startUploadFlow();
    } else {
      _submitGenerationRequest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
          children: [
        SingleChildScrollView(
                padding:  EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainTitleField(),
                       SizedBox(height: 24),
                      ..._buildDynamicFields(),
                       SizedBox(height: 24),
                      _buildReferenceFilesSection(),
                       SizedBox(height: 40),
                      PrimaryButton(
                        text: 'startSmartGeneration'.tr(),
                        onPressed: _isTitleNotEmpty ? _generateContent : null,
                        width: double.infinity,
                        height: 54,
                      ),
                    ],
                  ),
                ),
              ),

            // Loading screen overlay
            SmartLoadingOverlay(
              isLoading: _isLoading,
              message: _loadingMessages[_loadingMessageIndex],
              steps: [
                'stepAnalyzeRequest'.tr(),
                'stepGatherSources'.tr(),
                'stepGenerateDraft'.tr(),
                'stepQualityCheck'.tr(),
                'stepReady'.tr(),
              ],
              currentStepIndex: _loadingMessageIndex,
            ),
            if (_isUploading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.85),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _uploadProgress > 0 ? _uploadProgress : null,
                          color: AppColors.accentGold,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          strokeWidth: 6,
                        ),
                         SizedBox(height: 24),
                        Text(
                          'uploadingReferenceFiles'.tr(args: [
                            '${_currentUploadingIndex + 1}',
                            '${_referenceFiles.length}',
                          ]),
                          textAlign: TextAlign.center,
                          style:  TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
  }

  Widget _buildShimmerIndicator() {
    return SizedBox(
      width: 80,
      height: 80,
      child: CircularProgressIndicator(
        color: AppColors.accentGold,
        backgroundColor: Colors.white.withOpacity(0.2),
        strokeWidth: 6,
      ),
    );
  }

  Widget _buildReferenceFilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'referenceFilesOptional'.tr(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
        ),
         SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          padding:  EdgeInsets.all(16),
          child: Column(
            children: [
              if (_referenceFiles.isEmpty)
                Text(
                  'noReferenceFilesYet'.tr(),
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics:  NeverScrollableScrollPhysics(),
                  itemCount: _referenceFiles.length,
                  itemBuilder: (context, index) {
                    final file = _referenceFiles[index];
                    return Container(
                      margin:  EdgeInsets.only(bottom: 8),
                      padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.insert_drive_file, color: AppColors.slateGray, size: 20),
                           SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              file.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: AppColors.deepNavy),
                            ),
                          ),
                          IconButton(
                            icon:  Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _removeReferenceFile(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
               SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickReferenceFiles,
                icon:  Icon(Icons.add, size: 18),
                label:  Text('addReferenceDocument'.tr()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.deepNavy,
                  side: BorderSide(color: AppColors.deepNavy),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainTitleField() {
    String label = 'mainTitleLabel'.tr();
    if (widget.task.key == 'homework') label = 'subjectTitleLabel'.tr();
    if (widget.task.key == 'cv') label = 'fullNameLabel'.tr();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:  TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
        ),
         SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'titleHintExample'.tr(),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.deepNavy, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDynamicFields() {
    List<Widget> fields = [];

    switch (widget.task.key) {
      case 'research':
        fields.addAll([
          _buildTextField('pages', 'optionalExpectedPages'.tr()),
          _buildLanguageField(),
          _buildCitationStyleField(),
          _buildTextField('university', 'optionalUniversityName'.tr()),
          _buildTextField('course', 'optionalCourseName'.tr()),
          _buildLongTextField('notes', 'optionalAdditionalNotes'.tr()),
        ]);
        break;
      case 'presentation':
        fields.addAll([
          _buildTextField('slides_count', 'optionalSlidesCount'.tr()),
          _buildTextField('target_audience', 'optionalTargetAudience'.tr()),
          _buildToneToggleField(),
          _buildLanguageField(),
          _buildLongTextField('notes', 'optionalAdditionalNotes'.tr()),
        ]);
        break;
      case 'case_study':
        fields.addAll([
          _buildTextField('company_name', 'optionalCompanyName'.tr()),
          _buildTextField('sector', 'optionalIndustrySector'.tr()),
          _buildTextField('main_problem', 'optionalMainProblem'.tr()),
          _buildLanguageField(),
          _buildCitationStyleField(),
          _buildLongTextField('notes', 'optionalAdditionalNotes'.tr()),
        ]);
        break;
      case 'report':
        fields.addAll([
          _buildReportTypeField(),
          _buildTextField('pages', 'optionalPagesCount'.tr()),
          _buildTextField('recipient', 'optionalRecipient'.tr()),
          _buildLanguageField(),
          _buildLongTextField('notes', 'optionalAdditionalNotes'.tr()),
        ]);
        break;
      case 'essay':
        fields.addAll([
          _buildTextField('word_count', 'optionalWordCount'.tr()),
          _buildTextField('thesis', 'optionalThesis'.tr()),
          _buildLanguageField(),
          _buildCitationStyleField(),
          _buildLongTextField('notes', 'optionalAdditionalNotes'.tr()),
        ]);
        break;
      case 'summary':
        fields.addAll([
          _buildTextField('author', 'optionalAuthorName'.tr()),
          _buildTextField('pages', 'optionalSummaryPages'.tr()),
          _buildFocusDropdownField(),
          _buildLanguageField(),
          _buildLongTextField('notes', 'optionalAdditionalNotes'.tr()),
        ]);
        break;
      case 'project':
        fields.addAll([
          _buildTextField('major', 'optionalProjectMajor'.tr()),
          _buildTextField('problem_solved', 'optionalProblemSolved'.tr()),
          _buildTextField('target_audience', 'optionalProjectAudience'.tr()),
          _buildLanguageField(),
          _buildLongTextField('notes', 'optionalAdditionalNotes'.tr()),
        ]);
        break;
      case 'literature_review':
        fields.addAll([
          _buildTextField('sources_count', 'optionalSourcesCount'.tr()),
          _buildTextField('time_period', 'optionalTimePeriod'.tr()),
          _buildLanguageField(),
          _buildCitationStyleField(),
          _buildLongTextField('notes', 'optionalAdditionalNotes'.tr()),
        ]);
        break;
      case 'homework':
        fields.addAll([
          _buildTextField('academic_level', 'optionalAcademicLevel'.tr()),
          _buildLanguageField(),
          _buildLongTextField('questions', 'optionalQuestions'.tr(), maxLines: 8),
          _buildLongTextField('notes', 'optionalAdditionalNotes'.tr()),
        ]);
        break;
      case 'translation':
        fields.addAll([
          _buildLanguageDropdown('source_lang', 'fromLanguage'.tr(), ['عربي', 'إنجليزي']),
          _buildLanguageDropdown('target_lang', 'toLanguage'.tr(), ['إنجليزي', 'عربي']),
           SizedBox(height: 16),
          _buildTabsInputFields(),
           SizedBox(height: 16),
          _buildFormattingToggleField(),
        ]);
        break;
      case 'paraphrase':
        fields.addAll([
          _buildLanguageField(),
           SizedBox(height: 16),
          _buildTabsInputFields(),
           SizedBox(height: 16),
          _buildParaphraseSliderField(),
        ]);
        break;
      case 'cv':
        fields.addAll([
          _buildTextField('major', 'optionalScientificMajor'.tr()),
          _buildTextField('university', 'optionalCurrentUniversity'.tr()),
          _buildTextField('degree', 'optionalDegree'.tr()),
           SizedBox(height: 16),
          _buildSkillsChipsField(),
           SizedBox(height: 16),
          _buildLongTextField('experience', 'optionalExperience'.tr(), maxLines: 6),
          _buildLanguageField(),
        ]);
        break;
    }

    return fields;
  }

  Widget _buildTextField(String key, String label) {
    return Padding(
      padding:  EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.deepNavy, fontWeight: FontWeight.w500)),
           SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            onChanged: (val) {
              _optionalValues[key] = val;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLongTextField(String key, String label, {int maxLines = 4}) {
    return Padding(
      padding:  EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.deepNavy, fontWeight: FontWeight.w500)),
           SizedBox(height: 8),
          TextFormField(
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            onChanged: (val) {
              _optionalValues[key] = val;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageField() {
    return Padding(
      padding:  EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('optionalWritingLanguage'.tr(), style: TextStyle(fontSize: 14, color: AppColors.deepNavy, fontWeight: FontWeight.w500)),
           SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _language,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            ),
            items: ['عربي', 'إنجليزي', 'كلاهما'].map((lang) {
              return DropdownMenuItem(value: lang, child: Text(_languageLabel(lang)));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _language = val ?? 'عربي';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCitationStyleField() {
    return Padding(
      padding:  EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('optionalCitationStyle'.tr(), style: TextStyle(fontSize: 14, color: AppColors.deepNavy, fontWeight: FontWeight.w500)),
           SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _citationStyle,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            ),
            items: ['APA', 'MLA', 'Chicago', 'هارفارد'].map((style) {
              return DropdownMenuItem(value: style, child: Text(_citationLabel(style)));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _citationStyle = val ?? 'APA';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeField() {
    return Padding(
      padding:  EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('optionalReportType'.tr(), style: TextStyle(fontSize: 14, color: AppColors.deepNavy, fontWeight: FontWeight.w500)),
           SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _reportType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            ),
            items: ['تقني', 'إداري', 'علمي', 'ميداني'].map((type) {
              return DropdownMenuItem(value: type, child: Text(_reportTypeLabel(type)));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _reportType = val ?? 'تقني';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFocusDropdownField() {
    return Padding(
      padding:  EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('optionalSummaryFocus'.tr(), style: TextStyle(fontSize: 14, color: AppColors.deepNavy, fontWeight: FontWeight.w500)),
           SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _focusType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            ),
            items: ['أفكار رئيسية', 'نقد وتقييم', 'تحليل مقارن'].map((focus) {
              return DropdownMenuItem(value: focus, child: Text(_focusLabel(focus)));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _focusType = val ?? 'أفكار رئيسية';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(String key, String label, List<String> list) {
    return Padding(
      padding:  EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.deepNavy, fontWeight: FontWeight.w500)),
           SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: list.first,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            ),
            items: list.map((item) {
              return DropdownMenuItem(value: item, child: Text(_languageLabel(item)));
            }).toList(),
            onChanged: (val) {
              _optionalValues[key] = val;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToneToggleField() {
    return Padding(
      padding:  EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('optionalPresentationTone'.tr(), style: TextStyle(fontSize: 14, color: AppColors.deepNavy, fontWeight: FontWeight.w500)),
          Row(
            children: [
              ChoiceChip(
                label:  Text('toneFormal'.tr()),
                selected: _tone == 'رسمي',
                onSelected: (selected) {
                  if (selected) setState(() => _tone = 'رسمي');
                },
              ),
               SizedBox(width: 8),
              ChoiceChip(
                label:  Text('toneInformal'.tr()),
                selected: _tone == 'غير رسمي',
                onSelected: (selected) {
                  if (selected) setState(() => _tone = 'غير رسمي');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormattingToggleField() {
    return Padding(
      padding:  EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('optionalPreserveFormatting'.tr(), style: TextStyle(fontSize: 14, color: AppColors.deepNavy, fontWeight: FontWeight.w500)),
          Switch(
            value: _preserveFormatting,
            activeColor: AppColors.accentGold,
            onChanged: (val) {
              setState(() {
                _preserveFormatting = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParaphraseSliderField() {
    return Padding(
      padding:  EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('optionalParaphraseDegree'.tr(), style: TextStyle(fontSize: 14, color: AppColors.deepNavy, fontWeight: FontWeight.w500)),
              Text(
                _paraphraseLevelLabel(),
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentGold),
              ),
            ],
          ),
          Slider(
            value: _paraphraseLevel,
            divisions: 2,
            activeColor: AppColors.accentGold,
            inactiveColor: Colors.grey[300],
            onChanged: (val) {
              setState(() {
                _paraphraseLevel = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabsInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('primaryTextInput'.tr(), style: TextStyle(fontSize: 14, color: AppColors.deepNavy, fontWeight: FontWeight.w600)),
         SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label:  Text('writeText'.tr()),
                selected: _selectedInputTab == 0,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedInputTab = 0);
                },
              ),
            ),
             SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label:  Text('uploadDocument'.tr()),
                selected: _selectedInputTab == 1,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedInputTab = 1);
                },
              ),
            ),
          ],
        ),
         SizedBox(height: 16),
        if (_selectedInputTab == 0)
          TextFormField(
            maxLines: 8,
            initialValue: _textInputContent,
            decoration: InputDecoration(
              hintText: 'pasteTextHint'.tr(),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            ),
            onChanged: (val) {
              _textInputContent = val;
            },
          )
        else
          Container(
            width: double.infinity,
            padding:  EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                if (_isFileExtracting) ...[
                  CircularProgressIndicator(color: AppColors.accentGold),
                   SizedBox(height: 16),
                  Text('extractingTextFromFile'.tr(), style: TextStyle(color: AppColors.slateGray)),
                ] else ...[
                  Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey[400]),
                   SizedBox(height: 16),
                  Text('supportedFileTypes'.tr(), style: TextStyle(color: AppColors.slateGray, fontSize: 13)),
                   SizedBox(height: 12),
                  PrimaryButton(
                    text: 'chooseFile'.tr(),
                    onPressed: _pickFile,
                    icon: Icons.folder_open,
                    height: 44,
                  ),
                  if (_extractedFileName != null) ...[
                     SizedBox(height: 12),
                    Text(
                      'attachedFile'.tr(args: [_extractedFileName!]),
                      style:  TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ]
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSkillsChipsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('optionalSkills'.tr(), style: TextStyle(fontSize: 14, color: AppColors.deepNavy, fontWeight: FontWeight.w500)),
         SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillController,
                decoration: InputDecoration(
                  hintText: 'skillHint'.tr(),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                ),
              ),
            ),
             SizedBox(width: 8),
            SmallPillButton(
              label: 'add'.tr(),
              onPressed: () {
                final text = _skillController.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _skillsList.add(text);
                    _skillController.clear();
                  });
                }
              },
            ),
          ],
        ),
        if (_skillsList.isNotEmpty) ...[
           SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skillsList.map((skill) {
              return Chip(
                label: Text(skill),
                onDeleted: () {
                  setState(() {
                    _skillsList.remove(skill);
                  });
                },
              );
            }).toList(),
          ),
        ]
      ],
    );
  }
}

