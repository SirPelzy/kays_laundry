// lib/src/features/orders/domain/order_status_update.dart
class OrderStatusUpdate {
  final String status; // e.g., "Pending", "Picked Up", "In Progress", "Delivered"
  final DateTime timestamp;
  final String? description; // Optional description

  const OrderStatusUpdate({
    required this.status,
    required this.timestamp,
    this.description,
  });
}