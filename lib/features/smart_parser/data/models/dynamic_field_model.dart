import '../../domain/entities/dynamic_field_entity.dart';

class DynamicFieldModel extends DynamicFieldEntity {
  const DynamicFieldModel({
    required super.fieldId,
    required super.label,
    required super.inputType,
    super.options,
    required super.isMandatory,
    super.value,
  });

  factory DynamicFieldModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['input_type']?.toString() ?? json['field_type']?.toString() ?? 'text';
    final inputType = _parseInputType(typeStr);

    final rawOptions = json['options'];
    final options = rawOptions is List
        ? rawOptions.map((e) => e.toString()).toList()
        : <String>[];

    return DynamicFieldModel(
      fieldId: json['field_id']?.toString() ?? json['field_name']?.toString() ?? '',
      label: json['label']?.toString() ?? json['label_ar']?.toString() ?? '',
      inputType: inputType,
      options: options,
      isMandatory: json['is_mandatory'] == true,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field_id': fieldId,
      'label': label,
      'input_type': _inputTypeToString(inputType),
      'options': options,
      'is_mandatory': isMandatory,
      'value': value,
    };
  }

  static DynamicInputType _parseInputType(String value) {
    switch (value) {
      case 'long_text':
        return DynamicInputType.longText;
      case 'number':
        return DynamicInputType.number;
      case 'dropdown':
      case 'select':
        return DynamicInputType.dropdown;
      case 'checkbox':
        return DynamicInputType.checkbox;
      case 'text':
      default:
        return DynamicInputType.text;
    }
  }

  static String _inputTypeToString(DynamicInputType type) {
    switch (type) {
      case DynamicInputType.longText:
        return 'long_text';
      case DynamicInputType.number:
        return 'number';
      case DynamicInputType.dropdown:
        return 'dropdown';
      case DynamicInputType.checkbox:
        return 'checkbox';
      case DynamicInputType.text:
        return 'text';
    }
  }
}
