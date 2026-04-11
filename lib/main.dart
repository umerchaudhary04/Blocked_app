import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blocked',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static const platform = MethodChannel('com.blocked.app/native');

  bool isProtected = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentStatus();
  }

  // AppStore Polish: Check real status when app opens
  Future<void> _checkCurrentStatus() async {
    try {
      final String status = await platform.invokeMethod('getStatus');
      setState(() {
        isProtected = status == "CONNECTED";
      });
    } catch (e) {
      debugPrint("Failed to get status: $e");
    }
  }

  Future<void> _toggleProtection() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (isProtected) {
        final String result = await platform.invokeMethod('stopProtection');
        if (result == "DISCONNECTED") {
          setState(() {
            isProtected = false;
          });
        }
      } else {
        final String result = await platform.invokeMethod('startProtection');

        // AppStore Polish: Handle the results!
        if (result == "CONNECTED") {
          setState(() {
            isProtected = true;
          });
        } else if (result == "PERMISSION_DENIED") {
          _showError("Permission denied. VPN cannot start.");
        }
      }
    } on PlatformException catch (e) {
      _showError("System Error: ${e.message}");
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isProtected ? Icons.shield : Icons.shield_outlined,
              size: 120,
              color: isProtected ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              isProtected ? "Protection Active" : "Unprotected",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isProtected ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _toggleProtection,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor:
                          isProtected ? Colors.red : Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isProtected ? "STOP" : "START",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
