import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pos/features/reports/daily_report.dart';
import 'package:pos/features/reports/monthly_report.dart';

import 'tables/services_table.dart';
import 'tables/orders_table.dart';
import 'tables/order_items_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Services,
    Orders,
    OrderItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // SERVICES CRUD
  Future<List<Service>> getAllServices() =>
      select(services).get();

  Stream<List<Service>> watchActiveServices() =>
      (select(services)..where((t) => t.isActive.equals(true))).watch();

  Future<int> insertService(ServicesCompanion service) =>
      into(services).insert(service);

  Future updateService(Service service) =>
      update(services).replace(service);

  Future deleteService(int id) =>
      (delete(services)..where((t) => t.id.equals(id))).go();


  Future<void> createOrder({
    required List<Service> servicesList,
    required String paymentMethod,
  }) async {
    await transaction(() async {
      final total =
      servicesList.fold<double>(0, (sum, s) => sum + s.price);

      final orderId = await into(orders).insert(
        OrdersCompanion.insert(
          total: total,
          paymentMethod: paymentMethod,
        ),
      );

      for (final service in servicesList) {
        await into(orderItems).insert(
          OrderItemsCompanion.insert(
            orderId: orderId,
            serviceId: service.id,
            price: service.price,
          ),
        );
      }
    });
  }

  Future<double> getTodayTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    final result = await (select(orders)
      ..where((o) => o.createdAt.isBiggerOrEqualValue(start)))
        .get();

    return result.fold<double>(
      0.0,
          (sum, o) => sum + o.total,
    );
  }

  Future<double> getMonthlyTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);

    final result = await (select(orders)
      ..where((o) => o.createdAt.isBiggerOrEqualValue(start)))
        .get();

    return result.fold<double>(
      0.0,
          (sum, o) => sum + o.total,
    );
  }

  Future<Map<String, double>> getPaymentBreakdownToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    final result = await (select(orders)
      ..where((o) => o.createdAt.isBiggerOrEqualValue(start)))
        .get();

    double cash = 0.0;
    double whish = 0.0;

    for (final o in result) {
      if (o.paymentMethod == 'cash') cash += o.total;
      if (o.paymentMethod == 'whish') whish += o.total;
    }

    return {
      'cash': cash,
      'whish': whish,
    };
  }
  Future<File> getDbFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/barber_pos.sqlite');
  }

  Future<void> restoreDatabase(File backupFile) async {
    final dbFile = await getDbFile();
    await dbFile.writeAsBytes(await backupFile.readAsBytes());
  }

  Stream<DailyReport> watchDailyReport(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final query = select(orders)
      ..where((o) => o.createdAt.isBetweenValues(start, end));

    return query.watch().map((orderList) {
      double total = 0;
      double cash = 0;
      double whish = 0;

      for (final order in orderList) {
        total += order.total;

        if (order.paymentMethod == 'cash') {
          cash += order.total;
        } else if (order.paymentMethod == 'whish') {
          whish += order.total;
        }
      }

      return DailyReport(
        date: start,
        total: total,
        salesCount: orderList.length,
        cashTotal: cash,
        whishTotal: whish,
      );
    });
  }

  Stream<MonthlyReport> watchMonthlyReport(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);

    final query = select(orders)
      ..where((o) => o.createdAt.isBetweenValues(start, end));

    return query.watch().map((ordersList) {
      double total = 0;
      double cash = 0;
      double whish = 0;

      for (final o in ordersList) {
        total += o.total;
        if (o.paymentMethod == 'cash') {
          cash += o.total;
        } else {
          whish += o.total;
        }
      }

      return MonthlyReport(
        month: start,
        total: total,
        ordersCount: ordersList.length,
        cashTotal: cash,
        whishTotal: whish,
      );
    });
  }

  Future<List<Order>> getOrdersForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return (select(orders)
      ..where((o) => o.createdAt.isBetweenValues(start, end)))
        .get();
  }

  Future<List<Order>> getOrdersForMonth(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);

    return (select(orders)
      ..where((o) => o.createdAt.isBetweenValues(start, end)))
        .get();
  }


}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'barber_pos.sqlite'));
    return NativeDatabase(file);
  });
}
