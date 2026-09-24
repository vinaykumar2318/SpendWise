class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
  });

  final String id;
  final String name;
  final String icon;
  final int colorValue;

  Category copyWith({String? id, String? name, String? icon, int? colorValue}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
