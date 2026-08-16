import 'package:equatable/equatable.dart';
import '../../../domain/entities/order_entity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardOrdersUpdated extends DashboardState {
  final List<OrderEntity> orders;

  const DashboardOrdersUpdated(this.orders);

  @override
  List<Object?> get props => [orders];
}

class DashboardFailure extends DashboardState {
  final String message;

  const DashboardFailure(this.message);

  @override
  List<Object?> get props => [message];
}
