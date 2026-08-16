import 'package:equatable/equatable.dart';
import '../../../domain/entities/order_entity.dart';

abstract class OrderDetailsEvent extends Equatable {
  const OrderDetailsEvent();

  @override
  List<Object> get props => [];
}

class SaveOrderRequested extends OrderDetailsEvent {
  final OrderEntity order;

  const SaveOrderRequested(this.order);

  @override
  List<Object> get props => [order];
}

class GenerateContentRequested extends OrderDetailsEvent {
  final OrderEntity order;
  final Map<String, dynamic> formValues;

  const GenerateContentRequested({
    required this.order,
    required this.formValues,
  });

  @override
  List<Object> get props => [order, formValues];
}
