import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/route_name.dart';

// Kelas DatabaseHelper tidak lagi digunakan di sini, jadi kita bisa menghapus import-nya
// untuk menghindari kebingungan. Namun, nama kolomnya kita pakai kembali untuk kompatibilitas UI.
class _DbColumnNames {
  static const columnId = '_id';
  static const columnUsername = 'username';
  static const columnEmail = 'email';
  static const columnPhoneNumber = 'phone_number';
  static const columnAddress = 'address';
  static const columnCity = 'city';
  static const columnProfilePicturePath = 'profile_picture_path';
}

class ProfileController with ChangeNotifier {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  String? get profileImagePath => _userData != null
      ? _userData![_DbColumnNames.columnProfilePicturePath] as String?
      : null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileController() {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Update UI untuk menampilkan loading indicator

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Baca semua data sesi sebagai String dari SharedPreferences
      final String? userId = prefs.getString('currentUserId');
      final String? username = prefs.getString('currentUsername');
      final String? email = prefs.getString('currentUserEmail');
      final String? avatarUrl = prefs.getString('currentUserAvatarUrl');
      // Data profil lokal (jika pernah diedit) juga bisa kita baca
      final String? localProfilePicPath = prefs.getString(
        'localProfilePicPath',
      );
      final String? phoneNumber = prefs.getString('localPhoneNumber');
      final String? address = prefs.getString('localAddress');
      final String? city = prefs.getString('localCity');

      if (userId != null) {
        // Susun data pengguna langsung dari SharedPreferences
        _userData = {
          _DbColumnNames.columnId: userId,
          _DbColumnNames.columnUsername: username ?? 'No Name',
          _DbColumnNames.columnEmail: email ?? 'No Email',
          _DbColumnNames.columnProfilePicturePath:
              localProfilePicPath ?? avatarUrl, // Prioritaskan gambar lokal
          _DbColumnNames.columnPhoneNumber: phoneNumber ?? '',
          _DbColumnNames.columnAddress: address ?? '',
          _DbColumnNames.columnCity: city ?? '',
        };
      } else {
        _errorMessage = "Sesi tidak ditemukan. Silakan login kembali.";
        _userData = null;
      }
    } catch (e) {
      _errorMessage = "Error memuat profil: ${e.toString()}";
      _userData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // <-- INI YANG PALING PENTING
    await prefs.remove('currentUserId');
    await prefs.remove('currentUsername');
    await prefs.remove('currentUserEmail');
    await prefs.remove('currentUserProfilePicPath');

    debugPrint('Sesi pengguna dan token telah dihapus.');

    _userData = null;
    _isLoading = false;

    // Gunakan 'if (context.mounted)' untuk keamanan
    if (context.mounted) {
      context.goNamed(RouteName.login);
    }
  }
}
