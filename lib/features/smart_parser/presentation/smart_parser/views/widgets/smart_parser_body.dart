import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../bloc/smart_parser_bloc.dart';
import '../../bloc/smart_parser_state.dart';
import '../../../order_details/views/order_details_page.dart';
import 'smart_parser_form.dart';

class SmartParserBody extends StatelessWidget {
  final String? initialText;
  final dynamic initialFiles; // Replaced PlatformFile with dynamic to avoid passing types if not needed here

  const SmartParserBody({super.key, this.initialText, this.initialFiles});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SmartParserBloc, SmartParserState>(
      listenWhen: (previous, current) {
        return current is SmartParserSuccess || current is SmartParserFailure || current is UploadFailure;
      },
      listener: (context, state) {
        if (state is SmartParserSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(order: state.order),
            ),
          );
        } else if (state is SmartParserFailure) {
          AppErrorDialog.show(context, message: state.message);
        } else if (state is UploadFailure) {
          AppErrorDialog.show(
            context,
            message: 'فشل في الرفع: ${state.message}',
          );
        }
      },
      child: SmartParserForm(
        initialText: initialText,
        initialFiles: initialFiles,
      ),
    );
  }
}
