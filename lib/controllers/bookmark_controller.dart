// lib/controllers/bookmark_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/article_model.dart';

class BookmarkController with ChangeNotifier {
  static const String _bookmarkKey = 'bookmarked_articles';

  List<Article> _bookmarkedArticles = [];
  // Daftar baru untuk menampung hasil filter, yang akan ditampilkan di UI
  List<Article> _filteredArticles = [];

  List<Article> get bookmarkedArticles => _bookmarkedArticles;
  List<Article> get filteredArticles => _filteredArticles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _currentQuery = '';

  BookmarkController() {
    loadBookmarks();
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> articlesJsonList = _bookmarkedArticles
          .map((article) => jsonEncode(article.toJson()))
          .toList();
      await prefs.setStringList(_bookmarkKey, articlesJsonList);
    } catch (e) {
      _errorMessage = "Gagal menyimpan bookmark: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> loadBookmarks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? articlesJsonList = prefs.getStringList(_bookmarkKey);
      if (articlesJsonList != null) {
        _bookmarkedArticles = articlesJsonList
            .map((jsonString) => Article.fromJson(jsonDecode(jsonString)))
            .toList();
      } else {
        _bookmarkedArticles = [];
      }
      // Saat pertama kali load, hasil filter sama dengan daftar lengkap
      _filteredArticles = List.from(_bookmarkedArticles);
    } catch (e) {
      _errorMessage = "Gagal memuat bookmark: ${e.toString()}";
      _bookmarkedArticles = [];
      _filteredArticles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FUNGSI BARU: Untuk menyaring bookmark
  void filterBookmarks(String query) {
    _currentQuery = query;
    if (query.isEmpty) {
      _filteredArticles = List.from(_bookmarkedArticles);
    } else {
      _filteredArticles = _bookmarkedArticles.where((article) {
        final titleLower = article.title.toLowerCase();
        final queryLower = query.toLowerCase();
        // Anda juga bisa menambahkan pencarian di deskripsi jika perlu
        // final descriptionLower = article.description?.toLowerCase() ?? '';
        return titleLower.contains(queryLower);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> addArticleToBookmark(Article article) async {
    if (_bookmarkedArticles.any((a) => a.url == article.url)) return;
    _bookmarkedArticles.insert(0, article);
    await _saveBookmarks();
    // Setelah menambah, perbarui juga daftar filter
    filterBookmarks(_currentQuery);
    notifyListeners();
  }

  Future<void> removeArticleFromBookmark(Article article) async {
    _bookmarkedArticles.removeWhere((a) => a.url == article.url);
    await _saveBookmarks();
    // Setelah menghapus, perbarui juga daftar filter
    filterBookmarks(_currentQuery);
    notifyListeners();
  }

  Future<bool> checkIsBookmarked(String articleUrl) async {
    return _bookmarkedArticles.any((article) => article.url == articleUrl);
  }
}
