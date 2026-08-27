import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../config/app_colors.dart';
import '../../../../../../config/strings.dart';
import '../../../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../../../../core/presentation/widgets/primary_button.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../../../domain/entities/dynamic_field_entity.dart';
import '../../bloc/order_details_bloc.dart';
import '../../bloc/order_details_event.dart';
import '../../bloc/order_details_state.dart';

class OrderDetailsForm extends StatefulWidget {
  final OrderEntity order;

  const OrderDetailsForm({super.key, required this.order});

  @override
  State<OrderDetailsForm> createState() => _OrderDetailsFormState();
}

class _OrderDetailsFormState extends State<OrderDetailsForm> {
  late TextEditingController _subjectController;
  late TextEditingController _taskTypeController;
  late TextEditingController _deadlineController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formValues = {};

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.order.subject);
    _taskTypeController = TextEditingController(text: widget.order.taskType);
    _deadlineController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.order.deadline),
    );

    if (widget.order.dynamicMissingFields != null) {
      for (final field in widget.order.dynamicMissingFields!) {
        if (field.inputType == DynamicInputType.checkbox) {
          _formValues[field.fieldId] = <String>[];
        } else {
          _formValues[field.fieldId] = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _taskTypeController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  void _onSaveAndGenerate() {
    if (widget.order.isReady) {
      final updatedOrder = OrderEntity(
        id: widget.order.id,
        subject: _subjectController.text,
        taskType: _taskTypeController.text,
        deadline: DateTime.tryParse(_deadlineController.text) ?? widget.order.deadline,
        status: widget.order.status,
        attachments: widget.order.attachments,
        taskNameAr: widget.order.taskNameAr,
        isReady: widget.order.isReady,
        missingInfo: widget.order.missingInfo,
        dynamicMissingFields: widget.order.dynamicMissingFields,
        generatedContentUrl: widget.order.generatedContentUrl,
        createdAt: widget.order.createdAt,
        updatedAt: widget.order.updatedAt,
        userId: widget.order.userId,
      );
      context.read<OrderDetailsBloc>().add(SaveOrderRequested(updatedOrder));
    } else {
      if (_formKey.currentState?.validate() ?? false) {
        _formKey.currentState?.save();
        context.read<OrderDetailsBloc>().add(
          GenerateContentRequested(
            order: widget.order,
            formValues: _formValues,
          ),
        );
      } else {
        AppErrorDialog.show(
          context,
          message: 'pleaseCompleteRequiredFields'.tr(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
      builder: (context, state) {
        if (state is OrderDetailsGeneratingContent) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.accentGold),
                SizedBox(height: 16),
                Text(
                  '???? ????? ???????...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildField(Strings.subject.tr(), _subjectController),
                const SizedBox(height: 16),
                _buildField(Strings.taskType.tr(), _taskTypeController),
                const SizedBox(height: 16),
                _buildField(
                  Strings.deadline.tr(),
                  _deadlineController,
                  isDate: true,
                ),
                const SizedBox(height: 32),
                if (!widget.order.isReady &&
                    widget.order.dynamicMissingFields != null &&
                    widget.order.dynamicMissingFields!.isNotEmpty)
                  _buildDynamicFields(),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: widget.order.isReady
                      ? Strings.confirmAndSave.tr()
                      : '????? ?????? ???????',
                  onPressed: _onSaveAndGenerate,
                  width: double.infinity,
                  height: 50,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    if (widget.order.taskNameAr != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.deepNavy.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.deepNavy.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '?????? ????????:',
              style: TextStyle(color: AppColors.slateGray, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              widget.order.taskNameAr!,
              style: TextStyle(
                color: AppColors.deepNavy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDynamicFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.accentGold),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '???? ????? ???????? ??????? ?????? ???????:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          ...widget.order.dynamicMissingFields!.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _buildDynamicInputWidget(field),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDynamicInputWidget(DynamicFieldEntity field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                field.label,
                style: TextStyle(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            if (field.isMandatory)
              const Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _buildInputField(field),
      ],
    );
  }

  Widget _buildInputField(DynamicFieldEntity field) {
    String? Function(dynamic)? validator = field.isMandatory
        ? (value) {
            if (value == null || (value is String && value.trim().isEmpty)) {
              return '??? ????? ?????';
            }
            if (value is List && value.isEmpty) {
              return '??? ????? ?????';
            }
            return null;
          }
        : null;

    InputDecoration decor = InputDecoration(
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.deepNavy),
      ),
      errorStyle: const TextStyle(color: Colors.red),
    );

    switch (field.inputType) {
      case DynamicInputType.text:
      case DynamicInputType.number:
      case DynamicInputType.longText:
        return TextFormField(
          decoration: decor,
          maxLines: field.inputType == DynamicInputType.longText ? 4 : 1,
          keyboardType: field.inputType == DynamicInputType.number
              ? TextInputType.number
              : TextInputType.text,
          onSaved: (val) => _formValues[field.fieldId] = val,
          validator: validator,
        );

      case DynamicInputType.dropdown:
        return DropdownButtonFormField<String>(
          decoration: decor,
          items: field.options
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: (val) {
            setState(() {
              _formValues[field.fieldId] = val;
            });
          },
          onSaved: (val) => _formValues[field.fieldId] = val,
          validator: validator,
        );

      case DynamicInputType.checkbox:
        return FormField<List<String>>(
          initialValue: _formValues[field.fieldId] ?? [],
          validator: field.isMandatory
              ? (val) => (val == null || val.isEmpty) ? '??? ????? ?????' : null
              : null,
          onSaved: (val) => _formValues[field.fieldId] = val,
          builder: (FormFieldState<List<String>> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: field.options.map((opt) {
                    final isSelected = state.value?.contains(opt) ?? false;
                    return FilterChip(
                      label: Text(opt),
                      selected: isSelected,
                      selectedColor: AppColors.accentGold.withOpacity(0.3),
                      checkmarkColor: AppColors.deepNavy,
                      onSelected: (selected) {
                        final list = List<String>.from(state.value ?? []);
                        if (selected) {
                          list.add(opt);
                        } else {
                          list.remove(opt);
                        }
                        state.didChange(list);
                        _formValues[field.fieldId] = list;
                      },
                    );
                  }).toList(),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 12.0),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        );
    }
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isDate = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: isDate
                ? Icon(Icons.calendar_today, color: AppColors.deepNavy)
                : null,
          ),
          onTap: isDate
              ? () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    controller.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                }
              : null,
          readOnly: isDate,
        ),
      ],
    );
  }
}