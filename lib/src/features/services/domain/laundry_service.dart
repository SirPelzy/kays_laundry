// lib/src/features/services/domain/laundry_service.dart

class LaundryService {
  final String id;
  final String name;
  final String description;
  final double pricePerUnit;
  final String unit; // e.g., "kg", "item"
  // Removed IconData icon field

  const LaundryService({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerUnit,
    required this.unit,
    // Removed icon from constructor
  });

  // Factory constructor to create a LaundryService from JSON
  factory LaundryService.fromJson(Map<String, dynamic> json) {
    return LaundryService(
      id: json['id'] as String? ?? '', // Handle potential null ID
      name: json['name'] as String? ?? 'Unnamed Service',
      description: json['description'] as String? ?? '',
      // Ensure pricePerUnit is parsed correctly (it might be int or double in JSON)
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'unit',
    );
  }
}
