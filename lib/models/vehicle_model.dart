import 'package:flutter/material.dart';

/// Category of freight vehicle offered on the Aligo booking sheet.
enum VehicleCategory { lightTruck, mediumFreight, heavyVan }

/// Represents a selectable cargo vehicle option in the booking flow.
class VehicleModel {
  final VehicleCategory category;
  final String name;
  final String description;
  final String capacity;
  final String etaLabel;
  final double basePrice;
  final IconData icon;

  const VehicleModel({
    required this.category,
    required this.name,
    required this.description,
    required this.capacity,
    required this.etaLabel,
    required this.basePrice,
    required this.icon,
  });

  String get formattedPrice => '\$${basePrice.toStringAsFixed(2)}';

  static const List<VehicleModel> catalog = [
    VehicleModel(
      category: VehicleCategory.lightTruck,
      name: 'Light Truck',
      description: 'Ideal for parcels, boxes & small furniture',
      capacity: 'Up to 1.5 tons',
      etaLabel: '4 min away',
      basePrice: 18.50,
      icon: Icons.local_shipping_outlined,
    ),
    VehicleModel(
      category: VehicleCategory.mediumFreight,
      name: 'Medium Freight',
      description: 'Best for pallets & multi-stop deliveries',
      capacity: 'Up to 5 tons',
      etaLabel: '9 min away',
      basePrice: 42.00,
      icon: Icons.fire_truck_outlined,
    ),
    VehicleModel(
      category: VehicleCategory.heavyVan,
      name: 'Heavy Van',
      description: 'For bulk cargo & industrial equipment',
      capacity: 'Up to 12 tons',
      etaLabel: '15 min away',
      basePrice: 89.90,
      icon: Icons.rv_hookup_outlined,
    ),
  ];
}
