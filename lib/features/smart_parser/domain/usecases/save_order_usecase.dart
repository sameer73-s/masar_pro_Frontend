import '../../../../core/errors/either.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../agency/domain/repositories/agency_repository.dart';
import '../entities/order_entity.dart';
import '../repositories/parser_repository.dart';

class SaveOrderUseCase implements UseCase<Either<AppFailure, void>, OrderEntity> {
  final ParserRepository repository;
  final AgencyRepository agencyRepository;

  SaveOrderUseCase(this.repository, this.agencyRepository);

  @override
  Future<Either<AppFailure, void>> call(OrderEntity params) async {
    final saveResult = await repository.saveOrder(params);
    if (saveResult.isLeft) {
      return Either.left(saveResult.left!);
    }

    // Bridge Smart Parser → Agency Active Tasks (Firestore `tasks`).
    final taskResult = await agencyRepository.createTaskFromUrls(
      clientId: 'admin',
      fileUrls: params.attachments,
      status: 'ANALYZED',
      orderId: params.id,
      subject: params.subject,
      taskType: params.taskType,
    );

    if (taskResult.isLeft) {
      return Either.left(
        AppFailure.server(
          message:
              'تم حفظ الطلب لكن فشل إنشاء مهمة الوكالة: ${taskResult.left!.message}',
        ),
      );
    }

    return Either.right(null);
  }
}
