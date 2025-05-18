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
              : SafeArea(
                child: ListView(
                  children: [
                    // Featured Image
                    if (_post!.featuredImage != null)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child:
                            _post!.featuredImage!.startsWith('http')
                                ? Image.network(
                                  _post!.featuredImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/img/news1.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.image_not_supported,
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
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                      ),

                    // Article Content
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            _post!.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Metadata
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _post!.authorName ??
                                      'Penulis Tidak Diketahui',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                  'id_ID',
                                ).format(_post!.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (_post!.categoryName != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _post!.categoryName!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                              ] else
                                const Spacer(),
                              Icon(
                                Icons.visibility,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_post!.views} views',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 32),

                          // HTML Content with fixed width constraints
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return SizedBox(
                                width: constraints.maxWidth,
                                child: Html(
                                  data: _post!.content,
                                  shrinkWrap: true,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(16),
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                      maxLines: null,
                                      lineHeight: LineHeight.em(1.6),
                                    ),
                                    "p": Style(
                                      margin: Margins(bottom: Margin(16)),
                                    ),
                                    "h1, h2, h3, h4, h5, h6": Style(
                                      margin: Margins(
                                        top: Margin(16),
                                        bottom: Margin(8),
                                      ),
                                    ),
                                    "img": Style(alignment: Alignment.center),
                                  },
                                  extensions: [
                                    TagWrapExtension(
                                      tagsToWrap: {
                                        "table",
                                        "pre",
                                        "iframe",
                                        "video",
                                        "img",
                                      },
                                      builder: (child) {
                                        return SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: child,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Tags
                          if (_post!.tags.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  _post!.tags.map((tag) {
                                    return Chip(
                                      label: Text(
                                        tag,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.grey[200],
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    );
                                  }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
