/// Which side of the marketplace an Aligo user operates on.
enum UserRole {
  driver,
  shipper;

  String get apiValue => name;

  static UserRole? fromApiValue(String? value) {
    for (final role in UserRole.values) {
      if (role.apiValue == value) return role;
    }
    return null;
  }
}

/// Represents an authenticated Aligo customer or driver.
class UserModel {
  final String id;
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? avatarUrl;
  final bool isVerified;
  final UserRole? role;
  final String? address;
  final int? age;
  final double? lat;
  final double? lng;

  const UserModel({
    required this.id,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.avatarUrl,
    this.isVerified = false,
    this.role,
    this.address,
    this.age,
    this.lat,
    this.lng,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    bool? isVerified,
    UserRole? role,
    String? address,
    int? age,
    double? lat,
    double? lng,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      address: address ?? this.address,
      age: age ?? this.age,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      role: UserRole.fromApiValue(json['role'] as String?),
      address: json['address'] as String?,
      age: json['age'] as int?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'role': role?.apiValue,
      'address': address,
      'age': age,
      'lat': lat,
      'lng': lng,
    };
  }
}
