import 'package:hive_flutter/hive_flutter.dart';
import '../models/order_model.dart';

abstract class ParserLocalDataSource {
  Future<void> saveOrder(OrderModel order);
}

class ParserLocalDataSourceImpl implements ParserLocalDataSource {
  static const String boxName = 'orders_box';

  @override
  Future<void> saveOrder(OrderModel order) async {
    final box = await Hive.openBox<OrderModel>(boxName);
    await box.put(order.id, order);
  }
}
