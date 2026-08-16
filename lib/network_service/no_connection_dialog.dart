import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../config/strings.dart';
import '../core/presentation/widgets/primary_button.dart';

class NoConnectionDialog extends StatelessWidget {
  final VoidCallback onRetry;
  const NoConnectionDialog({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              Strings.noInternetConnection.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              Strings.pleaseCheckConnection.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: Strings.retry.tr(),
              onPressed: onRetry,
              width: double.infinity,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}
