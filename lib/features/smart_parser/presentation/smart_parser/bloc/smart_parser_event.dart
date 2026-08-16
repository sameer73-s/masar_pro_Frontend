import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

abstract class SmartParserEvent extends Equatable {
  const SmartParserEvent();

  @override
  List<Object> get props => [];
}

class AnalyzeInputRequested extends SmartParserEvent {
  final String text;
  final List<PlatformFile> files;
  final List<String>? preUploadedUrls;

  const AnalyzeInputRequested({
    required this.text,
    required this.files,
    this.preUploadedUrls,
  });

  @override
  List<Object> get props => [
        text,
        files,
        preUploadedUrls ?? [],
      ];
}

class UploadAttachmentRequested extends SmartParserEvent {
  final String orderId;
  final File file;

  const UploadAttachmentRequested({
    required this.orderId,
    required this.file,
  });

  @override
  List<Object> get props => [orderId, file];
}

class UploadProgressUpdatedInternal extends SmartParserEvent {
  final double progress;
  const UploadProgressUpdatedInternal(this.progress);
  @override
  List<Object> get props => [progress];
}
