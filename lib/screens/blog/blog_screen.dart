import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/models/blog_post.dart';
import 'package:hijauloka/services/blog_service.dart';
import 'package:hijauloka/widgets/app_header.dart';
import 'package:intl/intl.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
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
        _posts = posts;
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isMediumScreen = size.width >= 360 && size.width < 600;
    final isLargeScreen = size.width >= 600;

    return Scaffold(
      appBar: const AppHeader(showBackButton: false),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadPosts,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadPosts,
                child:
                    _posts.isEmpty
                        ? const Center(
                          child: Text('Belum ada artikel yang tersedia'),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            return Card(
                              margin: EdgeInsets.only(
                                bottom: isSmallScreen ? 8 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/blog-detail',
                                    arguments: post,
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (post.featuredImage != null)
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child:
                                            post.featuredImage!.startsWith(
                                                  'http',
                                                )
                                                ? Image.network(
                                                  post.featuredImage!,
                                                  height: 200,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    print(
                                                      'Error loading network image: $error',
                                                    );
                                                    return Image.asset(
                                                      'assets/img/news1.png',
                                                      height: 200,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        print(
                                                          'Error loading asset image: $error',
                                                        );
                                                        return Container(
                                                          height: 200,
                                                          color:
                                                              Colors.grey[200],
                                                          child: const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size: 50,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                )
                                                : Image.asset(
                                                  'assets/img/news1.png',
                                                  height: 200,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    print(
                                                      'Error loading asset image: $error',
                                                    );
                                                    return Container(
                                                      height: 200,
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 50,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                                ),
                                      ),
                                    Padding(
                                      padding: EdgeInsets.all(
                                        isSmallScreen ? 12 : 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post.title,
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 16 : 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (post.excerpt != null)
                                            Text(
                                              post.excerpt!,
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 12 : 14,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: isSmallScreen ? 12 : 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                DateFormat(
                                                  'dd MMM yyyy',
                                                  'id_ID',
                                                ).format(post.createdAt),
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 12 : 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(
                                                Icons.visibility,
                                                size: isSmallScreen ? 12 : 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${post.views} views',
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 12 : 14,
                                                  color: Colors.grey[600],
                                                ),
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
                          },
                        ),
              ),
    );
  }
}
