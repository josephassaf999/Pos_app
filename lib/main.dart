import 'package:flutter/material.dart';
import 'core/database/app_database.dart';
import 'features/home/home_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barber POS',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: HomeScreen(db: db),
    );
  }
}
