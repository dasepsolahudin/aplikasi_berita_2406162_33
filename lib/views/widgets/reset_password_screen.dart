import 'package:inews/views/utils/form_validaror.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/reset_password_controller.dart';
import '../utils/helper.dart' as helper;

import '../../routes/route_name.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email; // Email diteruskan dari ForgotPasswordScreen

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Metode helper untuk membangun TextFormField password (mirip ChangePasswordScreen)
  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.textTheme.bodyMedium?.color,
            fontWeight: helper.medium,
          ),
        ),
        helper.vsSuperTiny,
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              size: 22,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.hintColor,
              ),
              onPressed: onVisibilityToggle,
            ),
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.grey.shade800.withOpacity(0.5)
                : helper.cGrey.withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.5,
              ),
            ),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        helper.vsMedium,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return ChangeNotifierProvider(
      create: (_) => ResetPasswordController(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Reset Password',
            style: theme.appBarTheme.titleTextStyle,
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: theme.appBarTheme.elevation,
        ),
        body: Consumer<ResetPasswordController>(
          builder: (context, controller, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    helper.vsLarge,
                    Text(
                      'Buat Password Baru',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    helper.vsSmall,
                    Text(
                      'Password baru Anda harus berbeda dari password sebelumnya.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    helper.vsXLarge,

                    _buildPasswordField(
                      context: context,
                      controller: controller.newPasswordController,
                      labelText: 'Password Baru',
                      hintText: 'Minimal 8 karakter',
                      isVisible: controller.isNewPasswordVisible,
                      onVisibilityToggle:
                          controller.toggleNewPasswordVisibility,
                      validator: AppValidators.validatePassword,
                    ),

                    _buildPasswordField(
                      context: context,
                      controller: controller.confirmNewPasswordController,
                      labelText: 'Konfirmasi Password Baru',
                      hintText: 'Ulangi password baru Anda',
                      isVisible: controller.isConfirmNewPasswordVisible,
                      onVisibilityToggle:
                          controller.toggleConfirmNewPasswordVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password tidak boleh kosong.';
                        }
                        if (value != controller.newPasswordController.text) {
                          return 'Password baru tidak cocok.';
                        }
                        return null;
                      },
                    ),

                    helper.vsLarge,

                    if (controller.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          controller.errorMessage!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Pesan sukses tidak ditampilkan di sini, tapi melalui dialog jika diperlukan
                    // atau langsung navigasi.
                    ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(
                                  context,
                                ).unfocus(); // Tutup keyboard
                                bool success = await controller.resetPassword(
                                  widget.email,
                                );
                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        controller.successMessage ??
                                            'Password berhasil direset!',
                                        style: TextStyle(color: helper.cWhite),
                                      ),
                                      backgroundColor: helper.cSuccess,
                                    ),
                                  );
                                  // Arahkan ke halaman login setelah sukses reset password
                                  // Menggunakan goNamed untuk me-replace stack hingga ke login
                                  context.goNamed(RouteName.login);
                                }
                                // Pesan error sudah dihandle dengan _errorMessage dan ditampilkan di atas tombol
                                // atau bisa juga dengan SnackBar jika _errorMessage di controller tidak null
                                else if (controller.errorMessage != null &&
                                    mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        controller.errorMessage!,
                                        style: TextStyle(color: helper.cWhite),
                                      ),
                                      backgroundColor: helper.cError,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: textTheme.labelLarge,
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Simpan Password Baru'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
