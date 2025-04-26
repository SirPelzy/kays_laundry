// lib/src/features/orders/presentation/order_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../domain/order.dart';
import '../domain/order_status_update.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId; // We'll use this later to fetch the order

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // --- State ---
  Order? _order; // Make nullable initially
  bool _isLoading = true;
  String? _error;

  // Define the expected sequence of statuses for the timeline
  final List<String> _statusSequence = ['Pending', 'Picked Up', 'In Progress', 'Delivered'];

  @override
  void initState() {
    super.initState();
    print("--- OrderTrackingScreen initState --- Order ID: ${widget.orderId}"); // <-- ADDED PRINT
    _fetchOrderDetails();
  }

  // --- Data Fetching ---
  Future<void> _fetchOrderDetails({bool simulateDelay = true}) async {
    print("--- OrderTrackingScreen: Starting _fetchOrderDetails ---"); // <-- ADDED PRINT
    // Ensure state is updated before async gap if needed immediately
    if (mounted) {
       setState(() {
         _isLoading = true;
         _error = null;
       });
    }


    // Simulate network delay
    if (simulateDelay) {
      await Future.delayed(const Duration(seconds: 1));
    }

    // --- TODO: Replace with actual API call to fetch order by widget.orderId ---
    try {
      print("Fetching placeholder order..."); // <-- ADDED PRINT
      // Using placeholder data for now
      final fetchedOrder = Order.placeholderOrder;
      print("Placeholder order fetched: ID ${fetchedOrder.id}"); // <-- ADDED PRINT

      // Simulate finding the order based on ID (not really necessary with placeholder)
      if (fetchedOrder.id == widget.orderId) {
         print("Order ID matches. Updating state."); // <-- ADDED PRINT
         if (mounted) { // Check if widget is still in the tree
             setState(() {
               _order = fetchedOrder;
               _isLoading = false;
             });
         }
      } else {
         print("Order ID mismatch: Expected ${widget.orderId}, Got ${fetchedOrder.id}"); // <-- ADDED PRINT
         throw Exception('Order not found (ID mismatch in placeholder logic)');
      }

    } catch (e) {
      print("Error fetching order details: $e"); // <-- ADDED PRINT
      if (mounted) { // Check if widget is still in the tree
          setState(() {
            _isLoading = false;
            _error = 'Failed to load order details: ${e.toString()}';
          });
      }
    }
     print("--- OrderTrackingScreen: Finished _fetchOrderDetails ---"); // <-- ADDED PRINT
    // --- End API call ---
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
     print("--- OrderTrackingScreen build method --- isLoading: $_isLoading, error: $_error, order: ${_order?.id}"); // <-- ADDED PRINT
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderId}'), // Show Order ID in title
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
            onPressed: _isLoading ? null : () => _fetchOrderDetails(simulateDelay: true),
          ),
        ],
      ),
      // --- TEMPORARILY SIMPLIFIED BODY ---
      body: _buildSimplifiedBody(),
    );
  }

  // --- Helper: Build Simplified Body for Debugging ---
  Widget _buildSimplifiedBody() {
     print("Building simplified body..."); // <-- ADDED PRINT
     if (_isLoading) {
       print("Simplified Body: Showing Loading"); // <-- ADDED PRINT
       return const Center(child: CircularProgressIndicator());
     }
     if (_error != null) {
       print("Simplified Body: Showing Error: $_error"); // <-- ADDED PRINT
       return Center(
         child: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Text(_error!, style: const TextStyle(color: Colors.red)),
         ),
       );
     }
     if (_order != null) {
        print("Simplified Body: Showing 'Tracking Screen Reached' for Order ID: ${_order!.id}"); // <-- ADDED PRINT
        // If data loaded successfully, just show a confirmation text
        return Center(
          child: Text(
            'Tracking Screen Reached!\nOrder ID: ${_order!.id}\nCurrent Status: ${_order!.currentStatus}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          )
        );
     }
     // Fallback if something unexpected happens
     print("Simplified Body: Showing Fallback 'Something went wrong'"); // <-- ADDED PRINT
     return const Center(child: Text('Something went wrong. Order data is null.'));
  }


  // --- Original Body (Commented out for now) ---
  /*
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
     if (_order == null) {
       // Should ideally not happen if loading is false and error is null
       return const Center(child: Text('Order data not available.'));
     }

    // If data loaded successfully
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Order Status',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildTimeline(), // The vertical timeline widget
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          Text(
            'Order Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Service:', _order!.serviceName),
          _buildDetailRow('Quantity:', '${_order!.quantity.toStringAsFixed(_order!.quantity % 1 == 0 ? 0 : 1)} ${_order!.unit}'),
          _buildDetailRow('Location:', _order!.location),
          _buildDetailRow('Total Cost:', '₦${_order!.totalCost.toStringAsFixed(0)}'),
          _buildDetailRow('Ordered On:', DateFormat('MMM d, yyyy - hh:mm a').format(_order!.orderDate)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.support_agent_outlined),
            label: const Text('Contact Support'),
            onPressed: () {
              // TODO: Implement Contact Support action (e.g., launch email, phone, chat)
              print('Contact Support button pressed');
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Contact Support Not Implemented Yet')),
               );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
          ),
        ],
      ),
    );
  }
  */

  // --- Timeline Helpers (Keep them for later, but they are not called by simplified body) ---
  Widget _buildTimeline() {
     print("Building timeline..."); // <-- ADDED PRINT
     if (_order == null) return const SizedBox.shrink(); // Guard against null order

    Map<String, OrderStatusUpdate?> statusMap = {
      for (var status in _statusSequence) status: null
    };
    for (var update in _order!.statusHistory) {
      if (statusMap.containsKey(update.status)) {
        statusMap[update.status] = update;
      }
    }

    int currentStatusIndex = _statusSequence.indexOf(_order!.currentStatus);
     print("Timeline - Current Status: ${_order!.currentStatus}, Index: $currentStatusIndex"); // <-- ADDED PRINT

    return Column(
      children: List.generate(_statusSequence.length, (index) {
        final statusName = _statusSequence[index];
        final statusUpdate = statusMap[statusName];
        final bool isCompleted = index <= currentStatusIndex && statusUpdate != null;
        final bool isCurrent = index == currentStatusIndex;
        final bool isLast = index == _statusSequence.length - 1;

         print("Timeline Tile [$index] - Status: $statusName, Completed: $isCompleted, Current: $isCurrent"); // <-- ADDED PRINT

        return _buildTimelineTile(
          statusName: statusName,
          timestamp: statusUpdate?.timestamp,
          description: statusUpdate?.description,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isFirst: index == 0,
          isLast: isLast,
        );
      }),
    );
  }

  Widget _buildTimelineTile({
    required String statusName,
    DateTime? timestamp,
    String? description,
    required bool isCompleted,
    required bool isCurrent,
    required bool isFirst,
    required bool isLast,
  }) {
    final Color activeColor = Colors.blue.shade600;
    final Color inactiveColor = Colors.grey.shade400;
    final Color tileColor = isCompleted ? activeColor : inactiveColor;

    return IntrinsicHeight( // Ensures Row takes height of its children
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch line connector
        children: [
          // --- Left side: Icon and Line Connector ---
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top line connector (unless it's the first item)
              if (!isFirst)
                Expanded(
                  child: Container(width: 2, color: tileColor),
                ),
              // Status Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: tileColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent ? Colors.blue.shade800 : tileColor, // Highlight current
                    width: isCurrent ? 2.5 : 0,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.circle_outlined, // Checkmark if completed
                  color: Colors.white,
                  size: 18,
                ),
              ),
              // Bottom line connector (unless it's the last item)
              if (!isLast)
                 Expanded(
                  child: Container(width: 2, color: tileColor),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // --- Right side: Status Text and Timestamp ---
          Expanded(
            child: Padding(
              // Add padding at the bottom, except for the last item
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0, top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Center text vertically
                children: [
                  Text(
                    statusName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted ? Colors.black87 : Colors.grey[600],
                        ),
                  ),
                  if (timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, hh:mm a').format(timestamp), // Format timestamp
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                   if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Detail Row Helper (Keep for later) ---
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Fixed width for labels
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
