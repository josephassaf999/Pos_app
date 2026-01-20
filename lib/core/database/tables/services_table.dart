import 'package:drift/drift.dart';

class Services extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
}
