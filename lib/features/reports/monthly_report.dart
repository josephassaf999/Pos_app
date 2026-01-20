class MonthlyReport {
  final DateTime month;
  final double total;
  final int ordersCount;
  final double cashTotal;
  final double whishTotal;

  MonthlyReport({
    required this.month,
    required this.total,
    required this.ordersCount,
    required this.cashTotal,
    required this.whishTotal,
  });
}
