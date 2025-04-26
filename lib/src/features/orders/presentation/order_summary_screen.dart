import 'payment_screen.dart'; // Import the payment screen
// lib/src/features/orders/presentation/order_summary_screen.dart
import 'package:flutter/material.dart';
import '../../services/domain/laundry_service.dart';

class OrderSummaryScreen extends StatelessWidget {
  final LaundryService service;
  final double quantity; // Pass quantity as a number
  final String instructions;
  final String location;
  final String? ifeAddress; // Nullable if a hostel was selected
  final String timeSlot;

  const OrderSummaryScreen({
    super.key,
    required this.service,
    required this.quantity,
    required this.instructions,
    required this.location,
    this.ifeAddress,
    required this.timeSlot,
  });

  // --- Helper Function for Cost Calculation ---
  Map<String, double> _calculateCosts() {
    final double serviceCost = service.pricePerUnit * quantity;

    // Placeholder Delivery Fee Logic
    // Free for hostels (assuming standard names), 500 for "Other"
    final bool isHostel = location != 'Other (Ife Environs)';
    final double deliveryFee = isHostel ? 0.0 : 500.0;

    final double totalCost = serviceCost + deliveryFee;

    return {
      'serviceCost': serviceCost,
      'deliveryFee': deliveryFee,
      'totalCost': totalCost,
    };
  }
  // --- End Helper Function ---

  @override
  Widget build(BuildContext context) {
    final costs = _calculateCosts();
    final serviceCost = costs['serviceCost']!;
    final deliveryFee = costs['deliveryFee']!;
    final totalCost = costs['totalCost']!;

    // Determine the display location string
    final String displayLocation = (location == 'Other (Ife Environs)' && ifeAddress != null && ifeAddress!.isNotEmpty)
        ? ifeAddress!
        : location;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Pop back to the Create Order screen
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100], // Light gray section for the card
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow('Service:', service.name),
                  _buildSummaryRow('Quantity:', '${quantity.toStringAsFixed(quantity % 1 == 0 ? 0 : 1)} ${service.unit}'), // Format qty nicely
                  if (instructions.isNotEmpty)
                    _buildSummaryRow('Instructions:', instructions, isMultiline: true),
                  const Divider(height: 20, thickness: 1),
                  _buildSummaryRow('Pickup/Delivery Location:', displayLocation, isMultiline: true),
                  _buildSummaryRow('Time Slot:', timeSlot),
                  const Divider(height: 20, thickness: 1),
                  _buildCostRow('Service Cost:', serviceCost),
                  _buildCostRow('Delivery Fee:', deliveryFee),
                  const SizedBox(height: 8),
                  _buildCostRow('Total Cost:', totalCost, isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Edit Order Link
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate back to Create Order screen
                  Navigator.of(context).pop();
                },
                child: const Text('Edit Order'),
              ),
            ),
            const SizedBox(height: 16),

            // Proceed to Payment Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      totalAmount: totalCost, // Pass the calculated total cost
                    ),
                  ),
                );
                // TODO: Implement navigation to Payment Screen (Prompt #6)
                // Pass the total cost and potentially order details
                print('Proceeding to Payment with Total: ₦${totalCost.toStringAsFixed(0)}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment Screen Not Implemented Yet')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Proceed to Payment', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
      // Note: No bottom navigation bar here, as it's part of a specific flow pushed on top
    );
  }

  // Helper widget for standard summary rows
  Widget _buildSummaryRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
            textAlign: TextAlign.start,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 15), // Base size 16px mentioned, adjust as needed
              textAlign: TextAlign.end, // Align value to the right
            ),
          ),
        ],
      ),
    );
  }

   // Helper widget for cost rows
  Widget _buildCostRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                color: Colors.grey[700],
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                fontSize: isTotal ? 16 : 14 , // Make total slightly larger
            ),
          ),
          Text(
             // Using Nigeria Naira symbol
            '₦${value.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 17 : 15, // Make total slightly larger
            ),
          ),
        ],
      ),
    );
  }
}