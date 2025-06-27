import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}api/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'email': email, 'password': password}),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 &&
          responseBody['body']['success'] == true) {
        final data = responseBody['body']['data'];
        final author = data['author'];
        final token = data['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('currentUserId', author['id']);
        await prefs.setString(
          'currentUsername',
          "${author['firstName']} ${author['lastName']}",
        );
        await prefs.setString('currentUserEmail', author['email']);

        // --- TAMBAHAN: Simpan URL avatar dari API ---
        // Jika avatarUrl null dari API, akan disimpan sebagai null. Ini sudah benar.
        if (author['avatarUrl'] != null) {
          await prefs.setString('currentUserAvatarUrl', author['avatarUrl']);
        } else {
          // Pastikan key lama dihapus jika API mengembalikan null
          await prefs.remove('currentUserAvatarUrl');
        }

        print('Login berhasil, token dan data pengguna disimpan.');

        return {'success': true, 'message': 'Login berhasil!'};
      } else {
        String errorMessage =
            responseBody['body']?['message'] ?? 'Email atau password salah.';
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Error pada AuthApiService: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Silakan coba lagi.',
      };
    }
  }

  // Fungsi registrasi ini tetap dinonaktifkan karena tidak ada endpoint API
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': false,
      'message': 'Fitur registrasi belum tersedia saat ini.',
    };
  }
}
