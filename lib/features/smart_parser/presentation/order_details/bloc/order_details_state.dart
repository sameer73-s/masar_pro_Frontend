import 'package:equatable/equatable.dart';

abstract class OrderDetailsState extends Equatable {
  const OrderDetailsState();

  @override
  List<Object?> get props => [];
}

class OrderDetailsInitial extends OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}

class OrderDetailsSaved extends OrderDetailsState {}

class OrderDetailsFailure extends OrderDetailsState {
  final String message;

  const OrderDetailsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderDetailsGeneratingContent extends OrderDetailsState {}

class OrderDetailsContentGenerated extends OrderDetailsState {
  final Map<String, dynamic> result;

  const OrderDetailsContentGenerated(this.result);

  @override
  List<Object?> get props => [result];
}
