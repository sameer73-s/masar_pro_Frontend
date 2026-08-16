import 'package:flutter/material.dart';
import 'package:masar_pro/core/presentation/widgets/primary_button.dart';

/// Full-width purple CTA to start a new research project.
class AddProjectButton extends StatelessWidget {
  const AddProjectButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: 'New Research',
      onPressed: onPressed,
      icon: Icons.add,
      width: double.infinity,
      height: 52,
    );
  }
}
