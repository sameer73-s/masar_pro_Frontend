import 'package:equatable/equatable.dart';
import '../../domain/entities/excel_version.dart';

abstract class ExcelVersionerState extends Equatable {
  const ExcelVersionerState();

  @override
  List<Object?> get props => [];
}

class ExcelVersionerIdle extends ExcelVersionerState {
  const ExcelVersionerIdle();
}

class ExcelVersionerUploading extends ExcelVersionerState {
  const ExcelVersionerUploading();
}

class ExcelVersionerProcessing extends ExcelVersionerState {
  final int currentVersion;
  final int totalVersions;

  const ExcelVersionerProcessing({
    required this.currentVersion,
    required this.totalVersions,
  });

  @override
  List<Object?> get props => [currentVersion, totalVersions];
}

class ExcelVersionerSuccess extends ExcelVersionerState {
  final List<ExcelVersion> versions;
  final String zipUrl;
  final double processingTime;

  const ExcelVersionerSuccess({
    required this.versions,
    required this.zipUrl,
    required this.processingTime,
  });

  @override
  List<Object?> get props => [versions, zipUrl, processingTime];
}

class ExcelVersionerFailure extends ExcelVersionerState {
  final String message;

  const ExcelVersionerFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
