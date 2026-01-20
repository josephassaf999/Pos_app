import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import 'daily_report.dart';
import 'monthly_report.dart';

class ReportsScreen extends StatefulWidget {
  final AppDatabase db;

  const ReportsScreen({super.key, required this.db});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime selectedDate = DateTime.now();
  bool isMonthly = false;

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Widget reportCard(String title, String value, {Color? color}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReportContent({
    required String title,
    required double total,
    required int count,
    required double cash,
    required double whish,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          reportCard(
            'Total Sales',
            '${total.toStringAsFixed(0)} \$',
          ),
          const SizedBox(height: 12),

          reportCard(
            'Orders',
            count.toString(),
            color: Colors.blue,
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: reportCard(
                  'Cash',
                  '${cash.toStringAsFixed(0)} \$',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: reportCard(
                  'Whish',
                  '${whish.toStringAsFixed(0)} \$',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          Expanded(
            child: Column(
              children: [
                /// DAILY / MONTHLY PILL TOGGLE
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// DAILY BUTTON
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isMonthly = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !isMonthly ? Colors.teal : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Daily',
                              style: TextStyle(
                                color: !isMonthly ? Colors.white : Colors.teal,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// MONTHLY BUTTON
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isMonthly = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isMonthly ? Colors.teal : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Monthly',
                              style: TextStyle(
                                color: isMonthly ? Colors.white : Colors.teal,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// REPORT CONTENT WITH FADE ANIMATION
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: isMonthly
                        ? StreamBuilder<MonthlyReport>(
                      key: ValueKey('monthly-${selectedDate.month}-${selectedDate.year}'),
                      stream: widget.db.watchMonthlyReport(selectedDate)
                      as Stream<MonthlyReport>,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final report = snapshot.data!;

                        return buildReportContent(
                          title: '${report.month.month}/${report.month.year}',
                          total: report.total,
                          count: report.ordersCount,
                          cash: report.cashTotal,
                          whish: report.whishTotal,
                        );
                      },
                    )
                        : StreamBuilder<DailyReport>(
                      key: ValueKey('daily-${selectedDate.day}-${selectedDate.month}-${selectedDate.year}'),
                      stream: widget.db.watchDailyReport(selectedDate)
                      as Stream<DailyReport>,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final report = snapshot.data!;

                        return buildReportContent(
                          title: '${report.date.day}/${report.date.month}/${report.date.year}',
                          total: report.total,
                          count: report.salesCount,
                          cash: report.cashTotal,
                          whish: report.whishTotal,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }
}
