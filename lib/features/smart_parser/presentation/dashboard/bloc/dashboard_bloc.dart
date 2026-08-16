import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_saved_orders_usecase.dart';
import '../../../domain/entities/order_entity.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetSavedOrdersUseCase getSavedOrdersUseCase;

  DashboardBloc({
    required this.getSavedOrdersUseCase,
  }) : super(DashboardInitial()) {
    on<WatchSavedOrders>(_onWatchSavedOrders);
  }

  Future<void> _onWatchSavedOrders(
    WatchSavedOrders event,
    Emitter<DashboardState> emit,
  ) async {
    debugPrint('[DEBUG] DashboardBloc: _onWatchSavedOrders event received');
    await emit.forEach<List<OrderEntity>>(
      getSavedOrdersUseCase(),
      onData: (orders) {
        debugPrint('[DEBUG] DashboardBloc: stream emitted ${orders.length} orders');
        return DashboardOrdersUpdated(orders);
      },
      onError: (error, stackTrace) {
        debugPrint('[DEBUG] DashboardBloc: stream error: $error');
        return DashboardFailure(error.toString());
      },
    );
  }
}
