import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos/features/reports/daily_report.dart';
import 'package:pos/features/reports/monthly_report.dart';
import 'package:share_plus/share_plus.dart';

import 'package:pos/core/database/app_database.dart';
import 'package:pos/core/export/csv_exporter.dart';

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

  // ---------- UI helpers ----------

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

  // ---------- CSV SAVE (NO PERMISSIONS) ----------

  Future<void> exportCsv(String csvContent, String filename) async {
    try {
      final bytes = utf8.encode(csvContent);

      if (kIsWeb) {
        // Web handled elsewhere if needed
        return;
      }

      if (Platform.isAndroid) {
        final dir = await getExternalStorageDirectory();
        if (dir == null) throw Exception('Storage unavailable');

        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV saved:\n${file.path}')),
        );
      }

      if (Platform.isIOS) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$filename');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'text/csv')],
          text: 'Sales report',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export CSV: $e')),
      );
    }
  }

  // ---------- Report Content ----------

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

          reportCard('Total Sales', '${total.toStringAsFixed(0)} \$'),
          const SizedBox(height: 12),
          reportCard('Orders', count.toString(), color: Colors.blue),
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

          const SizedBox(height: 24),

          ElevatedButton.icon(
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text(
              'Export CSV',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            onPressed: () async {
              final exporter = CsvExporter(widget.db);

              final csv = isMonthly
                  ? await exporter.exportMonthly(selectedDate)
                  : await exporter.exportDaily(selectedDate);

              final filename = isMonthly
                  ? 'monthly_${selectedDate.month}_${selectedDate.year}.csv'
                  : 'daily_${selectedDate.day}_${selectedDate.month}_${selectedDate.year}.csv';

              await exportCsv(csv, filename);
            },
          ),
        ],
      ),
    );
  }

  // ---------- BUILD ----------

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

          // Toggle
          Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isMonthly = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
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
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isMonthly = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
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
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isMonthly
                  ?StreamBuilder<MonthlyReport>(
                key: ValueKey('monthly'),
                stream: widget.db.watchMonthlyReport(selectedDate),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
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
                key: ValueKey('daily'),
                stream: widget.db.watchDailyReport(selectedDate),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
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
              )

            ),
          ),
        ],
      ),
    );
  }
}
