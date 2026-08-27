import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../config/app_colors.dart';
import '../../../../../config/strings.dart';
import '../../../../../core/presentation/widgets/custom_app_bar.dart';
import '../bloc/smart_parser_bloc.dart';
import '../../../../../injection/injection_container.dart' as di;
import 'widgets/smart_parser_body.dart';

class SmartParserScreen extends StatelessWidget {
  final String? initialText;
  final List<PlatformFile>? initialFiles;

  const SmartParserScreen({super.key, this.initialText, this.initialFiles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: Strings.smartParser),
      body: BlocProvider(
        create: (_) => di.locator<SmartParserBloc>(),
        child: SafeArea(
          top: false,
          child: SmartParserBody(
            initialText: initialText,
            initialFiles: initialFiles,
          ),
        ),
      ),
    );
  }
}
