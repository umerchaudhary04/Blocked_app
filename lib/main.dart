import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BlockedApp());
}

class BlockedApp extends StatelessWidget {
  const BlockedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blocked',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark, // A dark theme fits security apps well
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
