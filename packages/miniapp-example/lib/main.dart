import 'package:flutter/material.dart';

/// Mini-App Example: Simple Payment Demo
///
/// This demonstrates how a mini-app would use PaymentAPI.
/// In a real mini-app, PaymentAPI would be accessed through
/// eval bridge provided by flutter_eval.
Widget buildEntry() {
  return const PaymentDemoHome();
}

class PaymentDemoHome extends StatefulWidget {
  const PaymentDemoHome({super.key});

  @override
  PaymentDemoHomeState createState() => PaymentDemoHomeState();
}

class PaymentDemoHomeState extends State<PaymentDemoHome> {
  String _status = 'Ready';

  void _updateStatus(String status) {
    setState(() {
      _status = status;
    });
  }

  void _createOrder() {
    _updateStatus('Order created! Order ID: ORD-001');
  }

  void _processPaymentWithOverlay() {
    _updateStatus('Payment completed successfully!');
  }

  void _processDirectPayment() {
    _updateStatus('Direct payment successful!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment API Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment, size: 80, color: Colors.blue),
              const SizedBox(height: 32),
              const Text(
                'Payment API Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Example mini-app demonstrating PaymentAPI usage',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_status, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _createOrder(),
                  child: const Text('Create Order'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _processPaymentWithOverlay(),
                  child: const Text('Pay with Overlay'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _processDirectPayment(),
                  child: const Text('Direct Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
