class Category {
  final int id;
  final String name;
  final String? iconPath;

  Category({required this.id, required this.name, this.iconPath});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: int.parse(json['id_kategori'].toString()),
      name: json['nama_kategori'],
      iconPath: json['icon_path'],
    );
  }
}
