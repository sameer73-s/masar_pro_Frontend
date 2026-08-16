import 'package:equatable/equatable.dart';

class LocalizedText extends Equatable {
  final String local;
  final String foreign;

  const LocalizedText({required this.local, required this.foreign});

  @override
  List<Object?> get props => [local, foreign];
}
