import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/pages/article_detail_page.dart';

void main() {
  testWidgets('ArticleDetailPage displays the selected article data', (
    tester,
  ) async {
    final article = Article(
      title: 'Judul berita uji',
      description: 'Deskripsi berita uji',
      imageUrl: '',
      sourceName: 'Sumber Uji',
      publishedAt: '2026-11-05T10:00:00Z',
      url: 'https://example.com/article',
    );

    await tester.pumpWidget(
      MaterialApp(home: ArticleDetailPage(article: article)),
    );

    expect(find.text('Detail Berita'), findsOneWidget);
    expect(find.text('Judul berita uji'), findsOneWidget);
    expect(find.text('Sumber Uji'), findsOneWidget);
    expect(
      find.text('Tanggal publikasi: 2026-11-05T10:00:00Z'),
      findsOneWidget,
    );
    expect(find.text('Deskripsi berita uji'), findsOneWidget);
  });
}
