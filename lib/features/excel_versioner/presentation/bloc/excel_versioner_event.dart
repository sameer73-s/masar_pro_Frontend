import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

abstract class ExcelVersionerEvent extends Equatable {
  const ExcelVersionerEvent();

  @override
  List<Object?> get props => [];
}

class GenerateVersionsRequested extends ExcelVersionerEvent {
  final PlatformFile file;
  final String prompt;
  final int versionCount;
  final bool changeStyle;
  final bool changeNumbers;

  const GenerateVersionsRequested({
    required this.file,
    required this.prompt,
    required this.versionCount,
    required this.changeStyle,
    required this.changeNumbers,
  });

  @override
  List<Object?> get props => [
        file,
        prompt,
        versionCount,
        changeStyle,
        changeNumbers,
      ];
}

class ResetExcelVersioner extends ExcelVersionerEvent {
  const ResetExcelVersioner();
}
