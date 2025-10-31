class Vendor {
  final int vendorId;
  final int ownerUserId;
  final String ownerFullName;
  final String businessName;
  final String legalName;
  final String gstNumber;
  final String description;
  final int primaryCategoryId;
  final String primaryCategoryName;
  final double ratingAvg;
  final bool verified;
  final DateTime createdAt;
  final int cityId;
  final String cityName;
  final bool isActive;
  final String? imageUrl;

  Vendor({
    required this.vendorId,
    required this.ownerUserId,
    required this.ownerFullName,
    required this.businessName,
    required this.legalName,
    required this.gstNumber,
    required this.description,
    required this.primaryCategoryId,
    required this.primaryCategoryName,
    required this.ratingAvg,
    required this.verified,
    required this.createdAt,
    required this.cityId,
    required this.cityName,
    required this.isActive,
    required this.imageUrl
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      vendorId: _asInt(json['vendorId']),
      ownerUserId: _asInt(json['ownerUserId']),
      ownerFullName: json['ownerFullName'] ?? '',
      businessName: json['businessName'] ?? '',
      legalName: json['legalName'] ?? '',
      gstNumber: json['gstNumber'] ?? '',
      description: json['description'] ?? '',
      primaryCategoryId: _asInt(json['primaryCategoryId']),
      primaryCategoryName: json['primaryCategoryName'] ?? '',
      ratingAvg: _asDouble(json['ratingAvg']),
      verified: json['verified'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      cityId: _asInt(json['cityId']),
      cityName: json['cityName'] ?? '',
      isActive: json['isActive'] ?? false,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'vendorId': vendorId,
    'ownerUserId': ownerUserId,
    'ownerFullName': ownerFullName,
    'businessName': businessName,
    'legalName': legalName,
    'gstNumber': gstNumber,
    'description': description,
    'primaryCategoryId': primaryCategoryId,
    'primaryCategoryName': primaryCategoryName,
    'ratingAvg': ratingAvg,
    'verified': verified,
    'createdAt': createdAt.toIso8601String(),
    'cityId': cityId,
    'cityName': cityName,
    'isActive': isActive,
    'imageUrl': imageUrl,
  };

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
