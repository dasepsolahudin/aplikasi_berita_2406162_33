import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inews/routes/route_name.dart';
import '../utils/helper.dart' as helper;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengecek sesi dan navigasi
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Beri sedikit jeda agar splash screen terlihat
    await Future.delayed(const Duration(seconds: 3));

    // Pastikan widget masih ada di tree sebelum navigasi
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      // Coba dapatkan token dari penyimpanan
      final String? token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        // Jika token ada, pengguna sudah login. Langsung ke halaman utama.
        print("Token sesi ditemukan. Mengarahkan ke halaman utama.");
        context.goNamed(RouteName.home);
      } else {
        // Jika tidak ada token, lanjutkan alur normal ke onboarding/login.
        print("Token sesi tidak ditemukan. Mengarahkan ke halaman perkenalan.");
        context.goNamed(RouteName.introduction);
      }
    } catch (e) {
      // Jika terjadi error saat membaca shared_preferences, arahkan ke halaman perkenalan sebagai fallback
      print("Terjadi error saat mengecek sesi: $e");
      context.goNamed(RouteName.introduction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: helper.cWhite,
      body: Center(child: Image.asset('assets/images/icon.png', width: 300)),
    );
  }
}
