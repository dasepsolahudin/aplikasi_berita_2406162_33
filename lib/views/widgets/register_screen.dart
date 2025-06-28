import 'dart:ui'; // Diperlukan untuk ImageFilter.blur
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';
import '../utils/form_validaror.dart';
import '../../services/auth_api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  Future<void> _attemptRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final authService = AuthApiService();
        // Fungsi register dari API service saat ini dinonaktifkan.
        // Untuk tujuan demonstrasi UI, kita akan menampilkan pesan error.
        await Future.delayed(const Duration(seconds: 2)); // Simulasi proses
        Map<String, dynamic> result = {
          'success': false,
          'message': 'Fitur registrasi belum tersedia saat ini.',
        };

        // Kode di bawah ini bisa diaktifkan jika API sudah siap
        // Map<String, dynamic> result = await authService.register(
        //   _usernameController.text.trim(),
        //   _emailController.text.trim(),
        //   _passwordController.text,
        // );

        if (!mounted) return;
        if (result['success']) {
          await _showSuccessDialogAndNavigate(
            context,
            result['message'],
            RouteName.login,
          );
        } else {
          _showErrorSnackBar(result['message']);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(
            'Terjadi kesalahan saat registrasi. Silakan coba lagi.',
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isConfirmPassword = false,
  }) {
    final hintColor = Colors.white.withOpacity(0.6);
    bool isVisible = isConfirmPassword
        ? _isConfirmPasswordVisible
        : _isPasswordVisible;

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: isPassword && !isVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: hintColor),
        floatingLabelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: hintColor,
                ),
                onPressed: () {
                  setState(() {
                    if (isConfirmPassword) {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    } else {
                      _isPasswordVisible = !_isPasswordVisible;
                    }
                  });
                },
              )
            : null,
      ),
      keyboardType: isPassword
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: isConfirmPassword
          ? TextInputAction.done
          : TextInputAction.next,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/iconlogin1.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.black);
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Create Account',
                                    textAlign: TextAlign.center,
                                    style: helper.headline3.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  helper.vsLarge,
                                  _buildTextField(
                                    controller: _usernameController,
                                    labelText: 'Username',
                                    validator: AppValidators.validateName,
                                  ),
                                  helper.vsMedium,
                                  _buildTextField(
                                    controller: _emailController,
                                    labelText: 'Email',
                                    validator: AppValidators.validateEmail,
                                  ),
                                  helper.vsMedium,
                                  _buildTextField(
                                    controller: _passwordController,
                                    labelText: 'Password',
                                    validator: AppValidators.validatePassword,
                                    isPassword: true,
                                  ),
                                  helper.vsMedium,
                                  _buildTextField(
                                    controller: _confirmPasswordController,
                                    labelText: 'Confirm Password',
                                    validator: _validateConfirmPassword,
                                    isPassword: true,
                                    isConfirmPassword: true,
                                  ),
                                  helper.vsLarge,
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _attemptRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Register',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Sign in',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    context.goNamed(RouteName.login),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi dialog dan snackbar tidak perlu diubah
  Future<void> _showSuccessDialogAndNavigate(
    BuildContext context,
    String message,
    String routeName,
  ) async {
    // ... implementasi tetap sama
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
