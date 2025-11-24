import 'package:flutter/material.dart';

/// Reusable widget for AI risk detection UI.
class AIRiskDetectionWidget extends StatefulWidget {
  @override
  State<AIRiskDetectionWidget> createState() => _AIRiskDetectionWidgetState();
}

class _AIRiskDetectionWidgetState extends State<AIRiskDetectionWidget> {
  String? _riskResult;

  void _detectRisk() {
    setState(() {
      // Simulate AI risk detection
      _riskResult = 'No unusual activity detected.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.purple.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security, size: 48, color: Colors.purple.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'AI Risk Detection',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.analytics),
                      label: const Text('Run Risk Detection'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.purple.shade400,
                      ),
                      onPressed: _detectRisk,
                    ),
                  ),
                  if (_riskResult != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _riskResult!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
