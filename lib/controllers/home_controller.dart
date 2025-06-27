import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/news_api_service.dart';
import '../data/models/article_model.dart';

class HomeController with ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  // Hapus _dbHelper
  // final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Article> _articles = [];
  List<Article> get articles => _articles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Set<String> _bookmarkedArticleUrls = {};

  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  String? _currentSearchQuery;
  String? get currentSearchQuery => _currentSearchQuery;

  HomeController() {
    fetchArticles();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Diubah untuk menggunakan SharedPreferences
  Future<void> _loadBookmarkedStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? articlesJsonList = prefs.getStringList('bookmarked_articles');
      if (articlesJsonList != null) {
        final bookmarks = articlesJsonList
            .map((jsonString) => Article.fromJson(jsonDecode(jsonString)))
            .toList();
        _bookmarkedArticleUrls = bookmarks
            .map((article) => article.url!)
            .where((url) => url.isNotEmpty)
            .toSet();
      } else {
        _bookmarkedArticleUrls = {};
      }
    } catch (e) {
      print("HomeController: Error loading bookmark statuses: $e");
    }
  }

  Future<void> fetchArticles() async {
    _isSearchActive = false;
    _currentSearchQuery = null;
    _setLoading(true);
    _setError(null);
    _articles = [];
    notifyListeners();

    try {
      _articles = await _newsApiService.fetchTopHeadlines(category: null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      await _loadBookmarkedStatus();
      _setLoading(false);
    }
  }

  Future<void> searchArticles(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      fetchArticles();
      return;
    }

    _currentSearchQuery = trimmedQuery;
    _isSearchActive = true;
    _setLoading(true);
    _setError(null);
    _articles = [];

    try {
      _articles = await _newsApiService.searchNews(trimmedQuery);
      await _loadBookmarkedStatus();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  bool isArticleBookmarked(String? articleUrl) {
    if (articleUrl == null || articleUrl.isEmpty) return false;
    return _bookmarkedArticleUrls.contains(articleUrl);
  }

  // Diubah untuk menggunakan SharedPreferences
  Future<void> toggleBookmark(Article article) async {
    if (article.url == null || article.url!.isEmpty) {
      _setError("Artikel tidak memiliki URL yang valid untuk di-bookmark.");
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String> articlesJsonList =
        prefs.getStringList('bookmarked_articles') ?? [];
    List<Article> bookmarks = articlesJsonList
        .map((json) => Article.fromJson(jsonDecode(json)))
        .toList();

    if (_bookmarkedArticleUrls.contains(article.url)) {
      _bookmarkedArticleUrls.remove(article.url);
      bookmarks.removeWhere((a) => a.url == article.url);
    } else {
      _bookmarkedArticleUrls.add(article.url!);
      bookmarks.insert(0, article);
    }

    final List<String> newArticlesJsonList =
        bookmarks.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList('bookmarked_articles', newArticlesJsonList);

    notifyListeners();
  }
}