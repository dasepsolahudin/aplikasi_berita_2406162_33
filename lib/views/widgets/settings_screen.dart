import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/theme_controller.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary, size: 26),
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          color: textTheme.bodyLarge?.color,
          fontWeight: helper.medium,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            )
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: theme.hintColor,
                )
              : null),
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fitur "$title" belum tersedia.')),
            );
          },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final themeController = Provider.of<ThemeController>(context);

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
        title: Text('Pengaturan', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: ListView(
        children: <Widget>[
          helper.vsMedium,
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              "Tampilan",
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.brightness_6_outlined,
            title: "Mode Tema",
            trailing: DropdownButton<ThemeMode>(
              value: themeController.themeMode,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.hintColor,
              ),
              underline: const SizedBox.shrink(),
              dropdownColor: theme.cardColor,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(
                    "Sistem",
                    style: textTheme.titleMedium?.copyWith(
                      color: textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(
                    "Terang",
                    style: textTheme.titleMedium?.copyWith(
                      color: textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(
                    "Gelap",
                    style: textTheme.titleMedium?.copyWith(
                      color: textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  Provider.of<ThemeController>(
                    context,
                    listen: false,
                  ).setTheme(newMode);
                }
              },
            ),
            onTap: null,
          ),
          Divider(
            indent: 16,
            endIndent: 16,
            color: theme.dividerColor.withOpacity(0.5),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              "Akun",
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.lock_outline_rounded,
            title: "Ubah Password",
            onTap: () {
              context.pushNamed(RouteName.changePassword);
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.notifications_outlined,
            title: "Notifikasi",
            trailing: Switch(
              value: true,
              onChanged: (bool value) {
                // TODO: Logika untuk mengubah status notifikasi
              },

              activeTrackColor: colorScheme.primary.withOpacity(
                0.5,
              ), // Opsional
            ),
            onTap: null,
          ),
          Divider(
            indent: 16,
            endIndent: 16,
            color: theme.dividerColor.withOpacity(0.5),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              "Tentang Aplikasi",
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.info_outline_rounded,
            title: "Versi Aplikasi",
            subtitle: "1.0.0 (Contoh)",
            onTap: null,
            trailing: null,
          ),
          _buildSettingsItem(
            context,
            icon: Icons.shield_outlined,
            title: "Kebijakan Privasi",
            onTap: () {
              // TODO: Buka URL Kebijakan Privasi
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.description_outlined,
            title: "Syarat & Ketentuan",
            onTap: () {
              // TODO: Buka URL Syarat & Ketentuan
            },
          ),
          Divider(
            indent: 16,
            endIndent: 16,
            color: theme.dividerColor.withOpacity(0.5),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.delete_forever_outlined,
            title: "Hapus Akun",
            onTap: () {
              // TODO: Implementasi logika hapus akun
            },
          ),
          helper.vsMedium,
        ],
      ),
    );
  }
}
