import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsService {
  Future<List<Article>> fetchTopHeadlines({String category = 'general'}) async {
    final uri = Uri.https('newsapi.org', '/v2/top-headlines', {
      'country': 'us',
      'category': category,
      'pageSize': '20',
    });

    return _getArticles(uri);
  }

  Future<List<Article>> searchArticles({required String query}) async {
    final uri = Uri.https('newsapi.org', '/v2/everything', {
      'q': query,
      'pageSize': '20',
      'sortBy': 'publishedAt',
    });

    return _getArticles(uri);
  }

  Future<List<Article>> _getArticles(Uri uri) async {
    final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('NEWS_API_KEY belum diatur. Periksa file .env.');
    }

    final response = await http.get(uri, headers: {'X-Api-Key': apiKey});

    if (response.statusCode != 200) {
      throw Exception(
        'Permintaan berita gagal. Kode HTTP: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['status'] != 'ok') {
      throw Exception(data['message'] ?? 'NewsAPI mengembalikan kesalahan.');
    }

    final articlesJson = data['articles'] as List<dynamic>? ?? [];

    return articlesJson
        .map((json) => Article.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
