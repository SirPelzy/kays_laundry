// lib/src/features/services/domain/laundry_service.dart
import 'package:flutter/material.dart'; // Import for IconData

class LaundryService {
  final String id;
  final String name;
  final String description;
  final double pricePerUnit;
  final String unit; // e.g., "kg", "item"
  final IconData icon; // To display an icon on the card

  const LaundryService({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerUnit,
    required this.unit,
    required this.icon,
  });
}