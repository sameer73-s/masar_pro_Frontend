import 'package:flutter/material.dart';
import 'package:masar_pro/core/presentation/widgets/custom_app_bar.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
}

final Map<String, WidgetBuilder> routes = {
  AppRoutes.splash: (_) => const _DummyPage(title: 'Splash'),
  AppRoutes.login: (_) => const _DummyPage(title: 'Login'),
  AppRoutes.home: (_) => const _DummyPage(title: 'Home'),
};

String initialRoute() => AppRoutes.splash;

class _DummyPage extends StatelessWidget {
  const _DummyPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
