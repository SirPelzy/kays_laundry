// lib/src/features/orders/presentation/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../domain/order.dart';
import '../domain/order_status_update.dart';
import 'order_tracking_screen.dart'; // To navigate to details

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // --- Placeholder Data ---
  // TODO: Replace with actual fetched order history list
  final List<Order> _pastOrders = [
    Order( // Example Delivered Order
      id: 'KLO98765',
      serviceName: 'Wash & Iron',
      quantity: 5,
      unit: 'items', // Example unit
      location: 'Fajuyi Hall, Room C4',
      totalCost: 4000,
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      statusHistory: [
        OrderStatusUpdate(status: 'Pending', timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 2))),
        OrderStatusUpdate(status: 'Picked Up', timestamp: DateTime.now().subtract(const Duration(days: 5))),
        OrderStatusUpdate(status: 'In Progress', timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 12))),
        OrderStatusUpdate(status: 'Delivered', timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 2))),
      ],
    ),
     Order( // Another Delivered Order
      id: 'KLO54321',
      serviceName: 'Dry Cleaning',
      quantity: 2,
      unit: 'item',
      location: 'Moremi Hall, Block A',
      totalCost: 3000,
      orderDate: DateTime.now().subtract(const Duration(days: 10)),
      statusHistory: [
         OrderStatusUpdate(status: 'Pending', timestamp: DateTime.now().subtract(const Duration(days: 10, hours: 1))),
         OrderStatusUpdate(status: 'Picked Up', timestamp: DateTime.now().subtract(const Duration(days: 9, hours: 20))),
         OrderStatusUpdate(status: 'In Progress', timestamp: DateTime.now().subtract(const Duration(days: 9, hours: 5))),
         OrderStatusUpdate(status: 'Delivered', timestamp: DateTime.now().subtract(const Duration(days: 8, hours: 15))),
      ],
    ),
     Order.placeholderOrder, // Include the one we used for tracking (might not be 'Delivered')
     Order( // Example Cancelled Order (if applicable)
      id: 'KLO11223',
      serviceName: 'Wash & Fold',
      quantity: 2.0,
      unit: 'kg',
      location: 'Akintola Hall',
      totalCost: 1000,
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      statusHistory: [
        OrderStatusUpdate(status: 'Pending', timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 4))),
        OrderStatusUpdate(status: 'Cancelled', timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1))),
      ],
    ),
  ];

  // TODO: Add state for filtering/sorting
  // String _currentFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // TODO: Apply filtering logic to _pastOrders based on _currentFilter
    final List<Order> displayedOrders = _pastOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.white, // Or Colors.grey[100]
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Orders',
            onPressed: () {
              // TODO: Implement filter/sort options (e.g., show a bottom sheet or dialog)
              print('Filter button pressed');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter/Sort Not Implemented Yet')),
              );
            },
          ),
        ],
      ),
      body: displayedOrders.isEmpty
          ? const Center(child: Text('You have no past orders.')) // Show message if list is empty
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              itemCount: displayedOrders.length,
              itemBuilder: (context, index) {
                final order = displayedOrders[index];
                return _buildOrderHistoryCard(order);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12), // Spacing between cards
            ),
      // No bottom nav bar if pushed on top of profile
    );
  }

  // Helper widget to build each order history card
  Widget _buildOrderHistoryCard(Order order) {
    final String formattedDate = DateFormat('MMM d, yyyy').format(order.orderDate);
    final String formattedCost = '₦${order.totalCost.toStringAsFixed(0)}';
    final String currentStatus = order.currentStatus;
    // Determine status color (example logic)
    Color statusColor = Colors.orange; // Default for Pending/In Progress
    if (currentStatus == 'Delivered') {
       statusColor = Colors.green.shade600;
    } else if (currentStatus == 'Cancelled' || currentStatus == 'Failed') {
       statusColor = Colors.red.shade600;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Service Name and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Allow service name to wrap if long
                  child: Text(
                    order.serviceName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Middle row: Cost and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  formattedCost,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                Container( // Status Chip/Badge
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15), // Light background tint
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    currentStatus,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bottom row: View Details Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to the Order Tracking screen for this specific order
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingScreen(orderId: order.id),
                    ),
                  );
                },
                child: const Text('View Details'),
                // Style the button if needed (e.g., smaller text)
                // style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ),
            // Ensure card has minimum height (implicitly via padding, or use ConstrainedBox)
            // ConstrainedBox(constraints: BoxConstraints(minHeight: 80)), // As per prompt
          ],
        ),
      ),
    );
  }
}
