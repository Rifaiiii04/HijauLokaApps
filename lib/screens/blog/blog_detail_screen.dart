import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/models/blog_post.dart';
import 'package:hijauloka/services/blog_service.dart';
import 'package:hijauloka/widgets/app_header.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';

class BlogDetailScreen extends StatefulWidget {
  const BlogDetailScreen({super.key});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final _blogService = BlogService();
  bool _isLoading = true;
  BlogPost? _post;
  String? _errorMessage;
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _loadPost();
      _isFirstLoad = false;
    }
  }

  Future<void> _loadPost() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final post = ModalRoute.of(context)!.settings.arguments as BlogPost;
      await _blogService.incrementViews(post.id);

      setState(() {
        _post = post;
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
      appBar: const AppHeader(title: 'Artikel', showBackButton: true),
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
                      onPressed: _loadPost,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_post!.featuredImage != null)
                      Image.network(
                        _post!.featuredImage!,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _post!.title,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: isSmallScreen ? 14 : 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _post!.authorName ?? 'Penulis Tidak Diketahui',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.calendar_today,
                                size: isSmallScreen ? 14 : 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                  'id_ID',
                                ).format(_post!.createdAt),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.visibility,
                                size: isSmallScreen ? 14 : 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_post!.views} views',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          if (_post!.categoryName != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: isSmallScreen ? 14 : 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _post!.categoryName!,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (_post!.tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children:
                                  _post!.tags.map((tag) {
                                    return Chip(
                                      label: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                      backgroundColor: Colors.grey[200],
                                    );
                                  }).toList(),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Html(
                            data: _post!.content,
                            style: {
                              "body": Style(
                                fontSize: FontSize(isSmallScreen ? 14 : 16),
                                lineHeight: LineHeight.em(1.6),
                              ),
                              "p": Style(margin: Margins(bottom: Margin(16))),
                              "h1": Style(
                                fontSize: FontSize(isSmallScreen ? 20 : 24),
                                fontWeight: FontWeight.bold,
                                margin: Margins(
                                  bottom: Margin(16),
                                  top: Margin(24),
                                ),
                              ),
                              "h2": Style(
                                fontSize: FontSize(isSmallScreen ? 18 : 22),
                                fontWeight: FontWeight.bold,
                                margin: Margins(
                                  bottom: Margin(14),
                                  top: Margin(20),
                                ),
                              ),
                              "h3": Style(
                                fontSize: FontSize(isSmallScreen ? 16 : 20),
                                fontWeight: FontWeight.bold,
                                margin: Margins(
                                  bottom: Margin(12),
                                  top: Margin(16),
                                ),
                              ),
                              "a": Style(
                                color: AppTheme.primaryColor,
                                textDecoration: TextDecoration.underline,
                              ),
                              "img": Style(
                                margin: Margins(
                                  top: Margin(16),
                                  bottom: Margin(16),
                                ),
                              ),
                              "ul": Style(
                                margin: Margins(
                                  bottom: Margin(16),
                                  left: Margin(20),
                                ),
                              ),
                              "ol": Style(
                                margin: Margins(
                                  bottom: Margin(16),
                                  left: Margin(20),
                                ),
                              ),
                              "li": Style(margin: Margins(bottom: Margin(8))),
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
