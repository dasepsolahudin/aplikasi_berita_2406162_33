import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';
import '../utils/form_validaror.dart';
import '../../services/auth_api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        String email = _emailController.text.trim();
        String password = _passwordController.text;
        final authService = AuthApiService();
        Map<String, dynamic> result = await authService.login(email, password);

        if (!mounted) return;
        if (result['success']) {
          await _showSuccessDialogAndNavigate(
            context,
            result['message'],
            RouteName.home,
          );
        } else {
          _showErrorSnackBar(result['message']);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(
            'Terjadi kesalahan saat login. Silakan coba lagi.',
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
  }) {
    final hintColor = Colors.white.withOpacity(0.6);

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: isPassword && !_isPasswordVisible,
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
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: hintColor,
                ),
                onPressed: () => setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                }),
              )
            : null,
      ),
      keyboardType: isPassword
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Latar Belakang Gambar
          Image.asset(
            'assets/images/iconlogin1.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.black);
            },
          ),
          // Gradient Gelap di atas gambar
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
          // Konten Form dengan Efek Kaca Buram
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      // Panel Kaca
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
                                    'Hello again!',
                                    textAlign: TextAlign.center,
                                    style: helper.headline3.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  helper.vsLarge,
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
                                  // Tombol Login Warna Hitam
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _attemptLogin,
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
                                              'Login',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                  helper.vsSmall,
                                  TextButton(
                                    onPressed: () => context.pushNamed(
                                      RouteName.forgotPassword,
                                    ),
                                    child: const Text(
                                      'Forgot your password?',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      // Link Sign Up
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Don’t have an account? ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Sign up',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    context.goNamed(RouteName.register),
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

  Future<void> _showSuccessDialogAndNavigate(
    BuildContext context,
    String message,
    String routeName,
  ) async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
            context.goNamed(routeName);
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Theme.of(context).cardColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              helper.vsMedium,
              Icon(
                Icons.check_circle_outline_rounded,
                color: helper.cSuccess,
                size: 60.0,
              ),
              helper.vsMedium,
              Text(
                message,
                textAlign: TextAlign.center,
                style: helper.subtitle1.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: helper.bold,
                ),
              ),
              helper.vsMedium,
            ],
          ),
        );
      },
    );
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
