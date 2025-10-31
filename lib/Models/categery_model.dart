// lib/Models/category_model.dart
class Category {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final bool active;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.active,
  });

  /// Factory constructor required by your code: Category.fromJson(...)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json.containsKey('imageUrl') && json['imageUrl'] != null ? json['imageUrl'].toString() : null,
      active: json['active'] == true || json['active']?.toString() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'active': active,
  };
}
