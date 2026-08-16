part of 'content_result_bloc.dart';

abstract class ContentResultEvent extends Equatable {
  const ContentResultEvent();
  @override
  List<Object?> get props => [];
}

class ImproveContentRequested extends ContentResultEvent {
  final String text;
  final bool isArabic;
  final bool useGemini;

  const ImproveContentRequested({
    required this.text,
    required this.isArabic,
    required this.useGemini,
  });

  @override
  List<Object?> get props => [text, isArabic, useGemini];
}
