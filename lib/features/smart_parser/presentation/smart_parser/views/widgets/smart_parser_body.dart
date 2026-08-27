import 'package:easy_localization/easy_localization.dart';
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
        if (state is SmartParserFailure) {
          AppErrorDialog.show(context, message: state.message);
          return;
        }
        if (state is UploadFailure) {
          AppErrorDialog.show(
            context,
            message: 'uploadFailed'.tr(args: [state.message]),
          );
          return;
        }
        if (state is SmartParserSuccess) {
          if (state.order.status == 'error' ||
              state.order.subject == 'AI Processing Failed') {
            AppErrorDialog.show(
              context,
              message: (state.order.missingInfo != null &&
                      state.order.missingInfo!.trim().isNotEmpty)
                  ? state.order.missingInfo!
                  : 'aiProcessingFailed'.tr(),
            );
            return;
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(order: state.order),
            ),
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
