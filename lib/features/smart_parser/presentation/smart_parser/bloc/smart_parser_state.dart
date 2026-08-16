import 'package:equatable/equatable.dart';
import '../../../domain/entities/order_entity.dart';

abstract class SmartParserState extends Equatable {
  const SmartParserState();

  @override
  List<Object?> get props => [];
}

class SmartParserInitial extends SmartParserState {}

class SmartParserLoading extends SmartParserState {}

class SmartParserSuccess extends SmartParserState {
  final OrderEntity order;

  /// True when the AI detected missing information in the student's request.
  final bool hasMissingInfo;

  const SmartParserSuccess(this.order, {this.hasMissingInfo = false});

  @override
  List<Object?> get props => [order, hasMissingInfo];
}

class SmartParserFailure extends SmartParserState {
  final String message;

  const SmartParserFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class UploadInProgress extends SmartParserState {
  final double progress;

  const UploadInProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class UploadSuccess extends SmartParserState {
  final String secureUrl;

  const UploadSuccess(this.secureUrl);

  @override
  List<Object?> get props => [secureUrl];
}

class UploadFailure extends SmartParserState {
  final String message;

  const UploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
