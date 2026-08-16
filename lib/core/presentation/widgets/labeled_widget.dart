import 'package:flutter/material.dart';

class LabeledWidget extends StatelessWidget {
  const LabeledWidget({
    super.key,
    required this.label,
    required this.widget,
    this.labelPadding = const EdgeInsets.all(8.0),
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final Text label;
  final Widget widget;
  final EdgeInsetsGeometry labelPadding;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Padding(
          padding: labelPadding,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: label,
          ),
        ),
        widget,
      ],
    );
  }
}
