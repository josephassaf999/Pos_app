import 'package:drift/drift.dart';

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get total => real()();
  TextColumn get paymentMethod => text()(); // cash / whish
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
