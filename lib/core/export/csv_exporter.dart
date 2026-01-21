import 'package:csv/csv.dart';
import 'package:pos/core/database/app_database.dart';
import 'package:pos/features/reports/daily_report.dart';
import 'package:pos/features/reports/monthly_report.dart';

class CsvExporter {
  final AppDatabase db;

  CsvExporter(this.db);

  /// -------- DAILY CSV --------
  Future<String> exportDaily(DateTime date) async {
    final DailyReport report =
    await db.watchDailyReport(date).first;

    final rows = <List<dynamic>>[
      ['Date', 'Total Sales', 'Orders', 'Cash', 'Whish'],
      [
        '${report.date.day}/${report.date.month}/${report.date.year}',
        report.total,
        report.salesCount,
        report.cashTotal,
        report.whishTotal,
      ],
    ];

    return const ListToCsvConverter().convert(rows);
  }

  /// -------- MONTHLY CSV --------
  Future<String> exportMonthly(DateTime date) async {
    final MonthlyReport report =
    await db.watchMonthlyReport(date).first;

    final rows = <List<dynamic>>[
      ['Month', 'Total Sales', 'Orders', 'Cash', 'Whish'],
      [
        '${report.month.month}/${report.month.year}',
        report.total,
        report.ordersCount,
        report.cashTotal,
        report.whishTotal,
      ],
    ];

    return const ListToCsvConverter().convert(rows);
  }
}
