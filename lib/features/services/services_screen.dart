import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import 'service_form_dialog.dart';

class ServicesScreen extends StatelessWidget {
  final AppDatabase db;

  const ServicesScreen({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => ServiceFormDialog(db: db),
          );
        },
        label: const Text('Add Product', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder(
        stream: db.watchActiveServices(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data!;

          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.miscellaneous_services, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No products yet\nTap "Add Product"',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Chip(
                              label: Text(
                                '${service.price.toStringAsFixed(0)} \$',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              backgroundColor: Colors.teal,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ServiceFormDialog(
                                  db: db,
                                  service: service,
                                ),
                              );
                            },
                          ),
                          Switch(
                            value: service.isActive,
                            activeColor: Colors.teal,
                            onChanged: (value) {
                              db.updateService(
                                service.copyWith(isActive: value),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
