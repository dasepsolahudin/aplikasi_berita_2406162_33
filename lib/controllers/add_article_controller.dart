import 'dart:io';
import 'package:flutter/material.dart';
import '../services/news_api_service.dart';
import '../services/image_upload_service.dart';

class AddArticleController with ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  final ImageUploadService _imageUploadService =
      ImageUploadService(); // <-- Inisialisasi service

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _statusMessage = "";
  String get statusMessage => _statusMessage;

  Future<Map<String, dynamic>> publishArticle({
    required String title,
    required String content,
    required String category,
    required String tagsString,
    File? imageFile, // <-- Terima file gambar lagi
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? imageUrl;
      // Langkah 1: Jika ada gambar, unggah ke Cloudinary terlebih dahulu
      if (imageFile != null) {
        _statusMessage = "Mengunggah gambar...";
        notifyListeners();

        imageUrl = await _imageUploadService.uploadImage(imageFile);
        if (imageUrl == null) {
          throw Exception("Gagal mengunggah gambar ke server.");
        }
      }

      // Langkah 2: Kirim data (termasuk URL gambar) ke API server Anda
      _statusMessage = "Memublikasikan artikel...";
      notifyListeners();

      final List<String> tagsList = tagsString
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final result = await _newsApiService.addArticle(
        title: title,
        content: content,
        category: category,
        tags: tagsList,
        imageUrl: imageUrl, // <-- Kirim URL yang didapat dari Cloudinary
      );

      if (!result['success']) {
        _errorMessage = result['message'];
      }

      _statusMessage = "";
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _statusMessage = "";
      return {'success': false, 'message': _errorMessage!};
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
