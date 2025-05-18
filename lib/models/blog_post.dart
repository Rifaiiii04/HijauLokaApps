class BlogPost {
  final int id;
  final String title;
  final String slug;
  final String content;
  final String? excerpt;
  final String? featuredImage;
  final int? categoryId;
  final String status;
  final int authorId;
  final int views;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? categoryName;
  final String? authorName;
  final List<String> tags;

  BlogPost({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.excerpt,
    this.featuredImage,
    this.categoryId,
    required this.status,
    required this.authorId,
    required this.views,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.authorName,
    this.tags = const [],
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String? featuredImage;
    if (json['featured_image'] != null &&
        json['featured_image'].toString().isNotEmpty) {
      final img = json['featured_image'].toString();
      featuredImage =
          img.startsWith('http')
              ? img
              : 'https://admin.hijauloka.my.id/uploads/blog/$img';
    }

    return BlogPost(
      id: parseInt(json['id']),
      title: json['title'],
      slug: json['slug'],
      content: json['content'],
      excerpt: json['excerpt'],
      featuredImage: featuredImage,
      categoryId:
          json['category_id'] != null ? parseInt(json['category_id']) : null,
      status: json['status'],
      authorId: parseInt(json['author_id']),
      views: parseInt(json['views']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      categoryName: json['category_name'],
      authorName: json['author_name'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'excerpt': excerpt,
      'featured_image': featuredImage,
      'category_id': categoryId,
      'status': status,
      'author_id': authorId,
      'views': views,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category_name': categoryName,
      'author_name': authorName,
      'tags': tags,
    };
  }
}
