import 'package:flutter/material.dart';
import '../widgets/ai_risk_detection_widget.dart';

/// AI Risk Detection Module
/// Uses TensorFlow Lite to detect unusual activity and notify admin.
class AIRiskDetectionModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Risk Detection')),
      body: AIRiskDetectionWidget(),
    );
  }
}
