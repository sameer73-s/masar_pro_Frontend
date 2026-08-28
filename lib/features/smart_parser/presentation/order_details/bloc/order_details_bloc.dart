import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/app_failure.dart';
import '../../../../../core/shared/content_generation/domain/exceptions/content_generation_exceptions.dart';

import '../../../domain/usecases/save_order_usecase.dart';
import '../../../../../core/shared/content_generation/domain/usecases/generate_content_usecase.dart';
import 'order_details_event.dart';
import 'order_details_state.dart';

class OrderDetailsBloc extends Bloc<OrderDetailsEvent, OrderDetailsState> {
  final SaveOrderUseCase saveOrderUseCase;
  final GenerateContentUseCase generateContentUseCase;

  OrderDetailsBloc({
    required this.saveOrderUseCase,
    required this.generateContentUseCase,
  }) : super(OrderDetailsInitial()) {
    on<SaveOrderRequested>(_onSaveOrderRequested);
    on<GenerateContentRequested>(_onGenerateContentRequested);
  }

  Future<void> _onSaveOrderRequested(
    SaveOrderRequested event,
    Emitter<OrderDetailsState> emit,
  ) async {
    emit(OrderDetailsLoading());
    final result = await saveOrderUseCase(event.order);
    result.fold(
      (failure) => emit(OrderDetailsFailure(failure.message)),
      (_) => emit(OrderDetailsSaved()),
    );
  }

  Future<void> _onGenerateContentRequested(
    GenerateContentRequested event,
    Emitter<OrderDetailsState> emit,
  ) async {
    emit(OrderDetailsGeneratingContent());
    try {
      final result = await generateContentUseCase(
        GenerateContentParams(
          orderId: event.order.id,
          formValues: event.formValues,
          orderData: {
            'subject': event.order.subject,
            'task_type': event.order.taskType,
            'deadline': event.order.deadline.toIso8601String(),
            'status': event.order.status,
            'task_name_ar': event.order.taskNameAr,
          },
        ),
      );
      emit(OrderDetailsContentGenerated(result));
    } on PlagiarismRejectedException catch (e) {
      emit(OrderDetailsFailure(e.message));
    } on ServerException catch (e) {
      emit(OrderDetailsFailure(e.message));
    } on AppFailure catch (failure) {
      emit(OrderDetailsFailure(failure.message));
    } catch (e) {
      emit(OrderDetailsFailure(e.toString()));
    }
  }
}
