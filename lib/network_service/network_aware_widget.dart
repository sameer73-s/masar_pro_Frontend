import 'dart:async';
import 'package:flutter/material.dart';
import 'network_service.dart';
import 'no_connection_dialog.dart';

class NetworkAwareWidget extends StatefulWidget {
  final Widget child;
  const NetworkAwareWidget({super.key, required this.child});

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  late final StreamSubscription<bool> _subscription;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    _subscription = NetworkService.instance.connectionStatus.listen(
      _onConnectionChanged,
    );
  }

  void _onConnectionChanged(bool isConnected) {
    if (!isConnected && !_dialogShowing) {
      _showNoConnectionDialog();
    } else if (isConnected && _dialogShowing) {
      _dismissDialog();
    }
  }

  void _showNoConnectionDialog() {
    _dialogShowing = true;
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => NoConnectionDialog(
        onRetry: () {
          if (NetworkService.instance.isConnected) _dismissDialog();
        },
      ),
    ).then((_) => _dialogShowing = false);
  }

  void _dismissDialog() {
    if (mounted && _dialogShowing) {
      Navigator.of(context).pop();
      _dialogShowing = false;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
