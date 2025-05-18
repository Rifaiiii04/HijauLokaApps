import 'dart:convert';
import 'package:hijauloka/config/api_config.dart';
import 'package:hijauloka/models/blog_post.dart';
import 'package:http/http.dart' as http;

class BlogService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<List<BlogPost>> getPosts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/blog/posts.php'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BlogPost.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<BlogPost> getPost(String slug) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/blog/post.php?slug=$slug'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BlogPost.fromJson(data);
      } else {
        throw Exception('Failed to load post');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<BlogPost>> getPostsByCategory(String categorySlug) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/blog/category.php?slug=$categorySlug'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BlogPost.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<BlogPost>> getPostsByTag(String tagSlug) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/blog/tag.php?slug=$tagSlug'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BlogPost.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> incrementViews(int postId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/blog/increment_views.php'),
        body: {'post_id': postId.toString()},
      );
    } catch (e) {
      // Silently fail - view count is not critical
      print('Error incrementing views: $e');
    }
  }
}
