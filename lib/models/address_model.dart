/// Represents a pickup or drop-off location used in cargo search/tracking.
class AddressModel {
  final String label;
  final String subtitle;
  final double latitude;
  final double longitude;

  const AddressModel({
    required this.label,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });

  static const List<AddressModel> recentSearches = [
    AddressModel(
      label: 'Tashkent Logistics Hub',
      subtitle: 'Yunusabad District, Tashkent',
      latitude: 41.3486,
      longitude: 69.2925,
    ),
    AddressModel(
      label: 'Chorsu Bazaar Warehouse',
      subtitle: 'Old City, Tashkent',
      latitude: 41.3264,
      longitude: 69.2360,
    ),
    AddressModel(
      label: 'Tashkent International Airport',
      subtitle: 'Cargo Terminal 2',
      latitude: 41.2579,
      longitude: 69.2812,
    ),
  ];
}
