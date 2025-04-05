import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({Key? key}) : super(key: key);

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  // Example rate per gram
  final double _ratePerGram = 92.85;
  // Controller to read weight in grams from the text field
  final TextEditingController _weightController = TextEditingController();

  double _calculatedAmount = 0.0;

  // This method updates _calculatedAmount whenever the user changes the weight
  void _calculateAmount(String value) {
    final weight = double.tryParse(value) ?? 0.0;
    setState(() {
      _calculatedAmount = weight * _ratePerGram;
    });
  }

  // Optionally, use url_launcher to initiate a call
  Future<void> _callToSell() async {
    // Example phone number
    final Uri telUri = Uri(scheme: 'tel', path: '0413983999');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      // Handle error, e.g., show a snackbar or print a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch dialer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // If your design uses a white app bar with black text:
      appBar: AppBar(
        title: const Text('Sell', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF9F9F9), // A light background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card with rate, text field, etc.
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sell Your 24k Gold',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Calculate and Sell Today',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    // Rate per gram
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rate Per Gram :',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '\$${_ratePerGram.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // TextField for weight in grams
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Weight in Grams',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _calculateAmount,
                    ),
                    const SizedBox(height: 16),
                    // Amount user will get
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Get :',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '\$${_calculatedAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Call To Sell button at the bottom
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _callToSell,
                child: const Text(
                  'Call To Sell',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
