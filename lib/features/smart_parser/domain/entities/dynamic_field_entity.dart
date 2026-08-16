import 'package:equatable/equatable.dart';

/// Supported input types coming from the server.
enum DynamicInputType { text, longText, number, dropdown, checkbox }

class DynamicFieldEntity extends Equatable {
  final String fieldId;
  final String label;
  final DynamicInputType inputType;
  final List<String> options;
  final bool isMandatory;
  final dynamic value;

  const DynamicFieldEntity({
    required this.fieldId,
    required this.label,
    required this.inputType,
    this.options = const [],
    required this.isMandatory,
    this.value,
  });

  @override
  List<Object?> get props => [fieldId, label, inputType, options, isMandatory, value];
}
