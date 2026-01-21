import 'package:flutter/material.dart';
import 'package:pos/core/database/app_database.dart';
import 'package:pos/features/reports/reports_screen.dart';
import 'package:pos/features/sales/sales_screen.dart';
import 'package:pos/features/services/services_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppDatabase db;

  const HomeScreen({super.key, required this.db});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      SalesScreen(db: widget.db),
      ServicesScreen(db: widget.db),
      ReportsScreen(db: widget.db),
    ];

    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        backgroundColor: Colors.white,
        selectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Sale',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.content_cut),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
