// lib/src/features/orders/domain/order.dart
import 'order_status_update.dart';

class Order {
  final String id;
  final String serviceName;
  final double quantity;
  final String unit;
  final String location; // Could be hostel name or Ife address
  final double totalCost;
  final DateTime orderDate;
  final List<OrderStatusUpdate> statusHistory;

  // Helper to get the current status
  String get currentStatus => statusHistory.isNotEmpty ? statusHistory.last.status : 'Unknown';
  DateTime? get currentStatusTimestamp => statusHistory.isNotEmpty ? statusHistory.last.timestamp : null;


  const Order({
    required this.id,
    required this.serviceName,
    required this.quantity,
    required this.unit,
    required this.location,
    required this.totalCost,
    required this.orderDate,
    required this.statusHistory,
  });

  // --- Placeholder Data Factory ---
  // TODO: Replace with actual data fetching logic
  static Order get placeholderOrder => Order(
        id: 'KLO12345',
        serviceName: 'Wash & Fold',
        quantity: 3.5,
        unit: 'kg',
        location: 'Awolowo Hall, Room B12',
        totalCost: 1750,
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        statusHistory: [
          OrderStatusUpdate(status: 'Pending', timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2))),
          OrderStatusUpdate(status: 'Picked Up', timestamp: DateTime.now().subtract(const Duration(hours: 18))),
          OrderStatusUpdate(status: 'In Progress', timestamp: DateTime.now().subtract(const Duration(hours: 5)), description: 'Washing cycle started.'),
          // Add 'Delivered' status to test completed state
          // OrderStatusUpdate(status: 'Delivered', timestamp: DateTime.now().subtract(const Duration(minutes: 30))),
        ],
      );
  // --- End Placeholder Data ---
}