class Article {
  final String? sourceId;
  final String? sourceName;
  final String? author;
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;
  final String? slug;
  final String? category; // <-- TAMBAHKAN FIELD BARU UNTUK KATEGORI

  Article({
    this.sourceId,
    this.sourceName,
    this.author,
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.slug,
    this.category, // <-- Tambahkan di constructor
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      sourceId: json['id'] as String?,
      sourceName: json['author_name'] as String? ?? 'Sumber tidak diketahui',
      author: json['author_name'] as String?,
      title: json['title'] as String? ?? 'Tanpa Judul',
      description: json['summary'] as String? ?? json['content'] as String?,
      url: json['slug'] != null ? '/api/news/${json['slug']}' : null,
      urlToImage: json['featured_image_url'] as String?,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      content: json['content'] as String?,
      slug: json['slug'] as String?,
      category:
          json['category'] as String?, // <-- Ambil data kategori dari JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': {'id': sourceId, 'name': sourceName},
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
      'slug': slug,
      'category': category, // <-- Tambahkan di proses konversi ke JSON
    };
  }
}
