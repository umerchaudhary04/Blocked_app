// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/native_bridge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isProtectionActive = false;
  double goreSensitivity = 0.8;
  double nsfwSensitivity = 0.85;

  void toggleProtection(bool value) {
    setState(() => isProtectionActive = value);
    if (value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Protection UI Active (AI Disabled)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('System-Wide Protection',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(isProtectionActive ? 'Active' : 'Paused'),
              value: isProtectionActive,
              activeTrackColor: Colors.blueAccent,
              onChanged: toggleProtection,
            ),
            const Divider(height: 40),
            const Text('Blocks This Week',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                        color: Colors.red, value: 40, title: 'NSFW'),
                    PieChartSectionData(
                        color: Colors.orange, value: 25, title: 'Gore'),
                    PieChartSectionData(
                        color: Colors.grey, value: 15, title: 'Ads'),
                  ],
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const Divider(height: 40),
            const Text('Sensitivity Configuration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildSlider('Nudity & Sexual Content', nsfwSensitivity,
                (val) => setState(() => nsfwSensitivity = val)),
            _buildSlider('Graphic Imagery', goreSensitivity,
                (val) => setState(() => goreSensitivity = val)),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
      String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('$label (Confidence: ${(value * 100).toInt()}%)'),
        Slider(
          value: value,
          min: 0.5,
          max: 0.99,
          divisions: 50,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
