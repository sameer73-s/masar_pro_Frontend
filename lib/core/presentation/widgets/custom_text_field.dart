import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? validationMessage;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool? enableInteractiveSelection;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextStyle? style;
  final EdgeInsetsGeometry? contentPadding;
  final double? minHeight;
  final bool? filled;
  final Color? fillColor;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.validationMessage,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.readOnly = false,
    this.enableInteractiveSelection,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.validator,
    this.style,
    this.contentPadding,
    this.minHeight,
    this.filled,
    this.fillColor,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      hintText: hintText?.tr(),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixIconConstraints: prefixIconConstraints,
      suffixIconConstraints: suffixIconConstraints,
      contentPadding: contentPadding,
      isDense: minHeight != null || contentPadding != null,
      filled: filled,
      fillColor: fillColor,
    );

    final field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      enableInteractiveSelection: enableInteractiveSelection,
      maxLines: maxLines,
      onChanged: onChanged,
      onTap: onTap,
      style: style,
      inputFormatters:
          inputFormatters ?? [LengthLimitingTextInputFormatter(500)],
      validator:
          validator ??
          (value) {
            if (validationMessage != null && (value == null || value.isEmpty)) {
              return validationMessage;
            }
            return null;
          },
      decoration: decoration,
    );

    if (minHeight == null) return field;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight!),
      child: field,
    );
  }
}
