import 'package:inews/views/utils/form_validaror.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';
import '../../services/database_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final user = await DatabaseHelper.instance.getUserByEmail(email);

      if (!mounted) return;

      if (user != null) {
        context.pushNamed(RouteName.resetPassword, extra: email);
      } else {
        setState(() {
          _errorMessage = "Email tidak terdaftar di sistem kami.";
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text('Lupa Password', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              helper.vsLarge,
              Text(
                'Masukkan Email Akun Anda',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              helper.vsSmall,
              Text(
                'Kami akan mengirimkan instruksi (simulasi) untuk mereset password Anda jika email terdaftar.',
                style: textTheme.bodyMedium?.copyWith(
                  color: textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              helper.vsXLarge,
              Text(
                'Email Terdaftar',
                style: textTheme.titleSmall?.copyWith(
                  color: textTheme.bodyMedium?.color,
                  fontWeight: helper.medium,
                ),
              ),
              helper.vsSuperTiny,
              TextFormField(
                controller: _emailController,
                validator: AppValidators.validateEmail,
                style: textTheme.titleMedium?.copyWith(
                  color: textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan email Anda',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    size: 22,
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
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 1.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 1.5,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              helper.vsMedium,
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              helper.vsMedium,
              ElevatedButton(
                onPressed: _isLoading ? null : _submitEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: textTheme.labelLarge,
                ),
                child: _isLoading
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
                    : const Text('Kirim Instruksi'),
              ),
              helper.vsLarge,
            ],
          ),
        ),
      ),
    );
  }
}
