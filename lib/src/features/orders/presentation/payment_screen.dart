// lib/src/features/orders/presentation/payment_screen.dart
import 'package:flutter/material.dart';
import 'order_tracking_screen.dart'; // Import the tracking screen
import '../domain/order.dart'; // Import Order to get placeholder ID

// Enum to manage payment states
enum PaymentStatus { idle, loading, success, failed }

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  // TODO: Pass other necessary order details if needed for backend processing

  const PaymentScreen({
    super.key,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentStatus _status = PaymentStatus.idle;
  String _errorMessage = ''; // To store error messages

  // TODO: Add controllers for Card Input Fields
  // final _cardNumberController = TextEditingController();
  // final _expiryController = TextEditingController();
  // final _cvvController = TextEditingController();

  // State for selected payment method
  String _selectedMethod = 'Card'; // Default to Card

  // --- Payment Processing Logic ---
  Future<void> _processPayment() async {
    setState(() {
      _status = PaymentStatus.loading;
      _errorMessage = ''; // Clear previous errors
    });

    // --- TODO: Implement Paystack Payment Logic ---
    print('Initiating payment for ₦${widget.totalAmount.toStringAsFixed(0)} via $_selectedMethod');
    // 1. Collect payment details based on _selectedMethod (e.g., from controllers)
    // 2. Call your backend API to initiate Paystack transaction, passing amount and details
    // 3. Your backend interacts with Paystack and returns success/failure or a checkout URL
    // 4. Handle the response:
    //    - If using Paystack SDK directly in Flutter (less secure for keys), handle callbacks.
    //    - If backend provides checkout URL, launch it using a webview or url_launcher.
    //    - If backend handles everything, wait for its success/failure response.
    // 5. Verify payment status via backend webhook if necessary.

    // Simulate network call and outcome (Replace with actual logic)
    await Future.delayed(const Duration(seconds: 3));

    // Example Outcomes:
    bool paymentSuccessful = true; // Change this to false to test error state
    if (paymentSuccessful) {
      setState(() {
        _status = PaymentStatus.success;
      });
      // TODO: Navigate to Order Success/Tracking Screen or back to Order List
    } else {
      setState(() {
        _status = PaymentStatus.failed;
        _errorMessage = 'Payment failed. Please check your details or try another method.';
      });
    }
    // --- End Payment Logic ---
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.white, // Or Colors.grey[100] for light gray header
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Only allow back navigation if not loading or successful
          onPressed: (_status == PaymentStatus.loading || _status == PaymentStatus.success)
              ? null // Disable back button during loading/success
              : () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        // Build the body based on the current payment status
        child: _buildBodyBasedOnStatus(),
      ),
    );
  }

  // --- Helper: Build Body Based on Status ---
  Widget _buildBodyBasedOnStatus() {
    switch (_status) {
      case PaymentStatus.loading:
        // Show loading indicator
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Processing Payment...'),
            ],
          ),
        );
      case PaymentStatus.success:
        // Show success message and navigation button
        return _buildSuccessState();
      case PaymentStatus.failed:
        // Show the payment form again, but with an error message
        return _buildPaymentForm(showError: true);
      case PaymentStatus.idle:
      default:
        // Show the initial payment form
        return _buildPaymentForm();
    }
  }

  // --- Helper: Build Payment Form ---
  Widget _buildPaymentForm({bool showError = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Display the total amount
        Text(
          'Total Amount:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '₦${widget.totalAmount.toStringAsFixed(0)}', // Format amount (e.g., ₦2500)
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Payment method selection using ChoiceChips
        Text('Select Payment Method:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute chips evenly
           children: [
             ChoiceChip(
               label: const Text('Card'),
               selected: _selectedMethod == 'Card',
               // Update state only if the chip is selected (not deselected)
               onSelected: (selected) { if(selected) setState(() => _selectedMethod = 'Card'); },
               selectedColor: Colors.blue[100], // Visual feedback for selection
               backgroundColor: Colors.grey[200], // Background for unselected chips
             ),
             ChoiceChip(
               label: const Text('Bank Transfer'),
               selected: _selectedMethod == 'Bank',
               onSelected: (selected) { if(selected) setState(() => _selectedMethod = 'Bank'); },
               selectedColor: Colors.blue[100],
                backgroundColor: Colors.grey[200],
             ),
             ChoiceChip(
               label: const Text('USSD'),
               selected: _selectedMethod == 'USSD',
               onSelected: (selected) { if(selected) setState(() => _selectedMethod = 'USSD'); },
               selectedColor: Colors.blue[100],
                backgroundColor: Colors.grey[200],
             ),
           ],
        ),
        const SizedBox(height: 24),

        // Conditionally display payment details section using a helper method
        _buildPaymentDetailsSection(),
        const SizedBox(height: 24),

        // Display error message if payment failed
        if (showError && _errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),

        // Pay Now / Retry Button
        ElevatedButton(
          // Trigger the payment process on press
          onPressed: _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Primary button color
            foregroundColor: Colors.white, // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
            ),
            minimumSize: const Size(double.infinity, 48), // Full width, 48px height
          ),
          // Change button text based on whether it's an initial attempt or a retry
          child: Text(showError ? 'Retry Payment' : 'Pay Now', style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  // --- Helper: Build Conditional Payment Details UI ---
  Widget _buildPaymentDetailsSection() {
    // Return the appropriate UI based on the selected payment method
    if (_selectedMethod == 'Card') {
      return _buildCardInputForm(); // Show card input fields
    } else if (_selectedMethod == 'Bank') {
      // Show instructions for bank transfer
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('Bank Transfer details/instructions would appear here.')),
      );
    } else if (_selectedMethod == 'USSD') {
      // Show instructions for USSD payment
       return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('USSD code/instructions would appear here.')),
      );
    }
    // Default case: Return an empty widget if no method is selected (shouldn't happen)
    return const SizedBox.shrink();
  }

  // --- Helper: Build Card Input Form (Placeholder) ---
  Widget _buildCardInputForm() {
     // This is a placeholder. Replace with actual Paystack card fields or SDK widgets.
     return Column(
       crossAxisAlignment: CrossAxisAlignment.stretch,
       children: [
         Text('Enter Card Details:', style: Theme.of(context).textTheme.titleSmall),
         const SizedBox(height: 12),
         // TODO: Replace these TextFields with validated FormFields
         // TODO: Integrate Paystack's SDK or use their prebuilt UI elements if available
         const TextField(
           decoration: InputDecoration(
             labelText: 'Card Number',
             border: OutlineInputBorder(),
             prefixIcon: Icon(Icons.credit_card)
           ),
           keyboardType: TextInputType.number,
         ),
         const SizedBox(height: 12),
         Row(
           children: const [
             Expanded(
               child: TextField(
                 decoration: InputDecoration(
                   labelText: 'MM/YY',
                   border: OutlineInputBorder()
                 ),
                 keyboardType: TextInputType.datetime,
               ),
             ),
             SizedBox(width: 12),
             Expanded(
               child: TextField(
                 decoration: InputDecoration(
                   labelText: 'CVV',
                   border: OutlineInputBorder()
                 ),
                 keyboardType: TextInputType.number,
                 obscureText: true, // Hide CVV input
               ),
             ),
           ],
         ),
       ],
     );
  }


  // --- Helper: Build Success State UI ---
  Widget _buildSuccessState() {
    // Display success icon, message, and navigation button
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 80),
          const SizedBox(height: 24),
          Text(
            'Payment Successful!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Your order has been confirmed.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            // --- ADDED DEBUGGING PRINT STATEMENTS HERE ---
            onPressed: () {
              print("--- Payment Success: Navigating to Tracking ---"); // <-- ADDED PRINT
              final orderIdToTrack = Order.placeholderOrder.id; // Use placeholder ID

              // Pop all screens until the main scaffold (Home/Orders/Profile)
              print("Popping until first route..."); // <-- ADDED PRINT
              Navigator.of(context).popUntil((route) => route.isFirst);
              print("Popped routes. Current route should be MainScaffold."); // <-- ADDED PRINT

              // Then push the Order Tracking screen
              print("Pushing OrderTrackingScreen for ID: $orderIdToTrack"); // <-- ADDED PRINT
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderTrackingScreen(
                    orderId: orderIdToTrack,
                  ),
                ),
              ).then((_) {
                 print("Returned from OrderTrackingScreen (if popped)."); // <-- ADDED PRINT
              });
              print("--- Navigation attempt complete ---"); // <-- ADDED PRINT
            },
            // --- END DEBUGGING PRINT STATEMENTS ---
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Primary button color
              foregroundColor: Colors.white, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
            ),
            child: const Text('View Order Status'),
          ),
        ],
      ),
    );
  }
}
