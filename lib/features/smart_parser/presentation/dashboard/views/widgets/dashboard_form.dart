import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../../../config/app_colors.dart';
import '../../../../../../config/constants.dart';
import '../../../../../../config/secure_storage_service.dart';
import '../../../../../../core/presentation/widgets/app_bar_greeting.dart';
import '../../../../../../core/utils/responsive_layout.dart';
import '../../../../../../injection/injection_container.dart' as di;
import 'academic_workspace_section.dart';
import 'active_tasks_section.dart';
import 'quick_tools_section.dart';

class DashboardForm extends StatefulWidget {
  const DashboardForm({super.key});

  @override
  State<DashboardForm> createState() => _DashboardFormState();
}

class _DashboardFormState extends State<DashboardForm> {
  String _userName = 'User';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _resolveLoggedInUser();
  }

  Future<void> _resolveLoggedInUser() async {
    final firebaseUser = di.locator<FirebaseAuth>().currentUser;

    String? name = firebaseUser?.displayName?.trim();
    String? avatar = firebaseUser?.photoURL;

    if (name == null || name.isEmpty) {
      final storedUser = await SecureStorageService().getUser();
      final storedName = storedUser?.name.trim();
      if (storedName != null && storedName.isNotEmpty) {
        name = storedName;
      }
      final storedImage = storedUser?.image.trim();
      if ((avatar == null || avatar.isEmpty) &&
          storedImage != null &&
          storedImage.isNotEmpty) {
        avatar = storedImage;
      }
    }

    if (name == null || name.isEmpty) {
      final email = firebaseUser?.email?.trim();
      if (email != null && email.isNotEmpty) {
        name = email.split('@').first;
      }
    }

    if (!mounted) return;
    setState(() {
      _userName = (name != null && name.isNotEmpty) ? name : 'User';
      _avatarUrl = (avatar != null && avatar.isNotEmpty) ? avatar : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          kSpacing22,
          kSpacing24,
          kSpacing22,
          kSpacing24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBarGreeting(
              userName: _userName,
              avatarUrl: _avatarUrl,
              hasNotifications: true,
            ),
            const SizedBox(height: kSpacing24),
            const AcademicWorkspaceSection(),
            const SizedBox(height: kSpacing24),
            const ActiveTasksSection(),
            const SizedBox(height: kSpacing24),
            const QuickToolsSection(),
          ],
        ),
      ),
    );

    return ResponsiveLayout(
      mobile: content,
      tablet: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: content,
        ),
      ),
      desktop: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: content,
        ),
      ),
    );
  }
}
