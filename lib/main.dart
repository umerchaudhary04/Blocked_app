import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool initialIsProtected = prefs.getBool('isProtected') ?? false;

  runApp(MyApp(initialIsProtected: initialIsProtected));
}

class MyApp extends StatelessWidget {
  final bool initialIsProtected;
  const MyApp({super.key, required this.initialIsProtected});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blocked',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: Dashboard(initialIsProtected: initialIsProtected),
    );
  }
}

class Dashboard extends StatefulWidget {
  final bool initialIsProtected;
  const Dashboard({super.key, required this.initialIsProtected});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static const platform = MethodChannel('com.blocked.app/native');

  late bool isProtected;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isProtected = widget.initialIsProtected;
    // Phase 2: Check actual status on app open
    _checkCurrentStatus();
  }

  // Phase 2: Check real status
  Future<void> _checkCurrentStatus() async {
    bool cachedStatus = widget.initialIsProtected;

    try {
      // Sync with real status
      final String status = await platform.invokeMethod('getStatus');
      final bool realStatus = status == "CONNECTED";

      if (cachedStatus != realStatus) {
        // Only update state if the user hasn't toggled it manually while we were fetching
        if (isProtected == cachedStatus) {
          setState(() {
            isProtected = realStatus;
          });
        }

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isProtected', realStatus);
        } catch (e) {
          debugPrint("Failed to cache status: $e");
        }
      }
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
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isProtected', false);
        }
      } else {
        final String result = await platform.invokeMethod('startProtection');

        // Phase 2: Proper result handling and UI update
        if (result == "CONNECTED") {
          setState(() {
            isProtected = true;
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isProtected', true);
        } else if (result == "PERMISSION_DENIED") {
          _showError("Permission denied. VPN cannot start.");
        }
      }
    } on PlatformException catch (e) {
      debugPrint("System Error: ${e.message}");
      _showError("An unexpected error occurred. Please try again.");
    }

    setState(() {
      isLoading = false;
    });
  }

  // Phase 2: User-friendly error display
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
            // Phase 2: Add Branding within app
            // Image.asset('assets/images/logo.png', height: 150), // Uncomment and use actual asset path
            const Icon(
              Icons.security,
              size: 80,
              color: Colors.blueGrey,
              semanticLabel: 'Blocked Logo',
            ), // Temporary placeholder, replace with Image.asset
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isProtected ? Icons.shield : Icons.shield_outlined,
                key: ValueKey<bool>(isProtected),
                size: 120,
                color: isProtected ? Colors.green : Colors.grey,
                semanticLabel: isProtected
                    ? "Protection shield active"
                    : "Protection shield inactive",
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                isProtected ? "Protection Active" : "Unprotected",
                key: ValueKey<bool>(isProtected),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isProtected ? Colors.green : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isLoading ? null : _toggleProtection,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
                backgroundColor:
                    isProtected ? Colors.red : Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: isLoading
                  ? Semantics(
                      label: 'Loading protection status',
                      child: const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isProtected ? "STOP" : "START",
                        key: ValueKey<bool>(isProtected),
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
