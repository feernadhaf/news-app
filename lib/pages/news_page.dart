import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/news_service.dart';
import 'article_detail_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsService _newsService = NewsService();
  late Future<List<Article>> _newsFuture;
  String _selectedCategory = 'general';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _localFilterController = TextEditingController();
  String _localKeyword = '';

final List<Map<String, String>> _categories = [
    {'label': 'Umum', 'value': 'general'},
    {'label': 'Bisnis', 'value': 'business'},
    {'label': 'Hiburan', 'value': 'entertainment'},
    {'label': 'Kesehatan', 'value': 'health'},
    {'label': 'Sains', 'value': 'science'},
    {'label': 'Olahraga', 'value': 'sports'},
    {'label': 'Teknologi', 'value': 'technology'},
  ];

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsService.fetchTopHeadlines();
  }

  void _retryFetchingNews() {
    setState(() {
      final query = _searchController.text.trim();
      _newsFuture = query.isEmpty
          ? _newsService.fetchTopHeadlines(category: _selectedCategory)
          : _newsService.searchArticles(query: query);
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      _newsFuture = _newsService.fetchTopHeadlines(category: category);
    });
  }

  void _searchNews() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _selectCategory(_selectedCategory);
      return;
    }

    setState(() {
      _newsFuture = _newsService.searchArticles(query: query);
    });
  }

  List<Article> filterByTitle(List<Article> articles, String keyword) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    if (normalizedKeyword.isEmpty) return articles;

    return articles.where((article) {
      return article.title.toLowerCase().contains(normalizedKeyword);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _localFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Daily News',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Search & Filter Section Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              children: [
                // Global Search API
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchNews(),
                  decoration: InputDecoration(
                    hintText: 'Cari berita di internet...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      onPressed: _searchNews,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 10),
                // Local Filter Bar
                TextField(
                  controller: _localFilterController,
                  decoration: InputDecoration(
                    labelText: 'Filter judul di halaman ini',
                    labelStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    hintText: 'Contoh: AI, Sport, dll',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.filter_list_rounded, size: 20, color: Colors.grey[500]),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey[100],
                    suffixIcon: _localKeyword.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _localFilterController.clear();
                              setState(() {
                                _localKeyword = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _localKeyword = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Categories Horizontal ListView
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = _selectedCategory == category['value'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: ChoiceChip(
                    label: Text(category['label']!),
                    selected: selected,
                    selectedColor: Colors.indigo,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: selected ? Colors.indigo : Colors.transparent,
                      ),
                    ),
                    onSelected: (_) => _selectCategory(category['value']!),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Colors.black12),

          // Article List Section
          Expanded(
            child: FutureBuilder<List<Article>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 52, color: Colors.red[300]),
                          const SizedBox(height: 12),
                          const Text('Gagal mengambil berita', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _retryFetchingNews,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final articles = snapshot.data ?? <Article>[];
                final filteredArticles = filterByTitle(articles, _localKeyword);

                if (filteredArticles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('Tidak ada berita yang cocok.', style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                    final article = filteredArticles[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleDetailPage(article: article),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (article.imageUrl.isNotEmpty)
                                  Image.network(
                                    article.imageUrl,
                                    width: double.infinity,
                                    height: 190,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 120,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Icon(Icons.broken_image_rounded, size: 36, color: Colors.grey[400]),
                                        ),
                                      );
                                    },
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Source Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          article.sourceName.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.indigo,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Title
                                      Text(
                                        article.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Description
                                      Text(
                                        article.description.isEmpty
                                            ? 'Deskripsi tidak tersedia.'
                                            : article.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}