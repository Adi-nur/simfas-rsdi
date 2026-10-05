class Category {
  final String id;
  final String name;
  final String code;
  final String description;
  final int itemCount;

  const Category({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    this.itemCount = 0,
  });

  factory Category.fromMap(Map<String, dynamic> map, {int itemCount = 0}) {
    return Category(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      itemCount: itemCount,
    );
  }
}
