import 'package:flutter/material.dart';

/// Mini-App Example: Simple Payment Demo
///
/// This demonstrates how a mini-app would use PaymentAPI.
/// In a real mini-app, PaymentAPI would be accessed through
/// eval bridge provided by flutter_eval.
Widget buildEntry() {
  Widget result;
  try {
    result = const PaymentDemoHome();
  } catch (e) {
    result = Center(child: Text('Error: $e'));
  }
  return result;
}

class PaymentDemoHome extends StatefulWidget {
  const PaymentDemoHome({super.key});

  @override
  PaymentDemoHomeState createState() => PaymentDemoHomeState();
}

class PaymentDemoHomeState extends State<PaymentDemoHome> {
  String _status = 'Ready';
  bool _isLoading = false;

  void _updateStatus(String status) {
    setState(() {
      _status = status;
    });
  }

  Future<void> _createOrder() async {
    setState(() => _isLoading = true);
    try {
      _updateStatus('Creating order...');
      await Future.delayed(const Duration(seconds: 1));
      _updateStatus('Order created! Order ID: ORD-001\nAmount: 100 USD');
    } catch (e) {
      _updateStatus('Failed to create order: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processPaymentWithOverlay() async {
    setState(() => _isLoading = true);
    try {
      _updateStatus('Processing payment with overlay...');
      await Future.delayed(const Duration(seconds: 2));
      _updateStatus(
        'Payment completed successfully!\nTransaction ID: TXN-12345',
      );
    } catch (e) {
      _updateStatus('Payment failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processDirectPayment() async {
    setState(() => _isLoading = true);
    try {
      _updateStatus('Processing direct payment...');
      await Future.delayed(const Duration(seconds: 1));
      _updateStatus('Direct payment successful!\nTransaction ID: TXN-67890');
    } catch (e) {
      _updateStatus('Payment failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _createOrder(),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Text('Wait'),
                        )
                      : const Text('Create Order'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _processPaymentWithOverlay(),
                  child: const Text('Pay with Overlay'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _processDirectPayment(),
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
