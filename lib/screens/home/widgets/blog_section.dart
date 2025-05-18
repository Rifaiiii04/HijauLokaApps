import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/models/blog_post.dart';
import 'package:hijauloka/services/blog_service.dart';
import 'package:intl/intl.dart';

class BlogSection extends StatefulWidget {
  const BlogSection({super.key});

  @override
  State<BlogSection> createState() => _BlogSectionState();
}

class _BlogSectionState extends State<BlogSection> {
  final _blogService = BlogService();
  bool _isLoading = true;
  List<BlogPost> _posts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final posts = await _blogService.getPosts();
      setState(() {
        _posts = posts.take(3).toList(); // Only take the first 3 posts
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat artikel: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Postingan Blog Terbaru',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tips perawatan tanaman dan panduan berkebun',
            style: TextStyle(fontSize: 13, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/blog');
            },
            icon: const Text('Lihat Semua'),
            label: const Icon(Icons.arrow_forward, size: 14),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_posts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Belum ada artikel yang tersedia'),
              ),
            )
          else
            Column(
              children: [
                // Featured blog post (first post)
                if (_posts.isNotEmpty) _buildFeatureBlogPost(_posts[0]),
                const SizedBox(height: 12),

                // Small blog posts (second and third posts)
                if (_posts.length > 1) _buildSmallBlogPost(_posts[1]),
                if (_posts.length > 1) const SizedBox(height: 12),
                if (_posts.length > 2) _buildSmallBlogPost(_posts[2]),
              ],
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeatureBlogPost(BlogPost post) {
    return GestureDetector(
      onTap: () => _navigateToBlogDetail(post),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child:
                  post.featuredImage != null &&
                          post.featuredImage!.startsWith('http')
                      ? Image.network(
                        post.featuredImage!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/img/news1.png',
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 160,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              );
                            },
                          );
                        },
                      )
                      : Image.asset(
                        'assets/img/news1.png',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 160,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'By ${post.authorName ?? 'Penulis'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'dd MMM yyyy',
                          'id_ID',
                        ).format(post.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (post.excerpt != null)
                    Text(
                      post.excerpt!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Text(
                        'Baca Selengkapnya',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: AppTheme.primaryColor,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBlogPost(BlogPost post) {
    return GestureDetector(
      onTap: () => _navigateToBlogDetail(post),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: SizedBox(
                width: 90,
                height: 90,
                child:
                    post.featuredImage != null &&
                            post.featuredImage!.startsWith('http')
                        ? Image.network(
                          post.featuredImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/img/news1.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                );
                              },
                            );
                          },
                        )
                        : Image.asset(
                          'assets/img/news1.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 30,
                              ),
                            );
                          },
                        ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'By ${post.authorName ?? 'Penulis'}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM', 'id_ID').format(post.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBlogDetail(BlogPost post) {
    Navigator.pushNamed(context, '/blog-detail', arguments: post);
  }
}
