import 'package:drift/drift.dart';
import 'orders_table.dart';
import 'services_table.dart';

class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get orderId =>
      integer().references(Orders, #id)();

  IntColumn get serviceId =>
      integer().references(Services, #id)();

  RealColumn get price => real()();
}
