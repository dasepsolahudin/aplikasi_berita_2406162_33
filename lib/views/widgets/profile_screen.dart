import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/profile_controller.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

class _DbColumnNames {
  static const columnId = '_id';
  static const columnUsername = 'username';
  static const columnEmail = 'email';
  static const columnProfilePicturePath = 'profile_picture_path';
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Widget untuk menampilkan gambar profil
  Widget _buildProfileImage(String? path) {
    if (path == null || path.isEmpty) {
      return Icon(Icons.person, size: 45, color: Colors.grey.shade400);
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.person, size: 45, color: Colors.grey.shade400),
      );
    } else {
      final imageFile = File(path);
      if (imageFile.existsSync()) {
        return Image.file(imageFile, fit: BoxFit.cover);
      } else {
        return Icon(Icons.person, size: 45, color: Colors.grey.shade400);
      }
    }
  }

  // Widget untuk item statistik
  Widget _buildStatItem(BuildContext context, String count, String label) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        helper.vsSuperTiny,
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }

  // Widget untuk item daftar aksi
  Widget _buildProfileListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    Color? customColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final color = customColor ?? theme.textTheme.bodyLarge?.color;
    final iconColor = customColor ?? theme.colorScheme.primary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 8.0,
      ),
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(color: color),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: theme.hintColor,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          // PERUBAHAN: Mengubah warna teks judul secara spesifik di halaman ini
          title: Text(
            "Profil Saya",
            style: theme.appBarTheme.titleTextStyle?.copyWith(
              color: theme
                  .colorScheme
                  .onBackground, // Menggunakan warna teks utama dari tema (hitam pada tema terang)
            ),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Consumer<ProfileController>(
          builder: (context, controller, child) {
            if (controller.isLoading && controller.userData == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    controller.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (controller.userData == null) {
              return Center(
                child: Text(
                  "Tidak dapat memuat data profil.",
                  style: theme.textTheme.titleMedium,
                ),
              );
            }

            final userData = controller.userData!;
            String displayName =
                userData[_DbColumnNames.columnUsername] as String? ??
                'Nama Pengguna';
            String displayEmail =
                userData[_DbColumnNames.columnEmail] as String? ??
                'email@example.com';
            String? profilePicPath =
                userData[_DbColumnNames.columnProfilePicturePath] as String?;

            return RefreshIndicator(
              onRefresh: () => controller.refreshProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // --- HEADER PROFIL ---
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: theme.dividerColor,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: _buildProfileImage(profilePicPath),
                          ),
                        ),
                      ),
                      helper.vsMedium,
                      Text(
                        displayName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      helper.vsTiny,
                      Text(
                        displayEmail,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      helper.vsLarge,

                      // --- PANEL STATISTIK ---
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(context, '120', 'Artikel'),
                            SizedBox(
                              height: 30,
                              child: VerticalDivider(color: theme.dividerColor),
                            ),
                            _buildStatItem(context, '25', 'Bookmark'),
                            SizedBox(
                              height: 30,
                              child: VerticalDivider(color: theme.dividerColor),
                            ),
                            _buildStatItem(context, '1.2K', 'Suka'),
                          ],
                        ),
                      ),
                      helper.vsXLarge,

                      // --- DAFTAR AKSI ---
                      _buildProfileListItem(
                        context: context,
                        icon: Icons.person_outline,
                        title: "Edit Profil",
                        onTap: () async {
                          final String? userId =
                              controller.userData?[_DbColumnNames.columnId];
                          if (userId != null) {
                            final bool? profileWasUpdated = await context
                                .pushNamed<bool>(
                                  RouteName.editProfile,
                                  extra: userId,
                                );
                            if (profileWasUpdated == true && mounted) {
                              controller.refreshProfile();
                            }
                          }
                        },
                      ),
                      const Divider(),
                      _buildProfileListItem(
                        context: context,
                        icon: Icons.lock_outline_rounded,
                        title: "Ganti Password",
                        onTap: () =>
                            context.pushNamed(RouteName.changePassword),
                      ),
                      const Divider(),
                      _buildProfileListItem(
                        context: context,
                        icon: Icons.settings_outlined,
                        title: "Pengaturan",
                        onTap: () => context.pushNamed(RouteName.settings),
                      ),
                      const Divider(),
                      _buildProfileListItem(
                        context: context,
                        icon: Icons.logout_rounded,
                        title: "Logout",
                        customColor: theme.colorScheme.error,
                        onTap: () => controller.logout(context),
                      ),
                      // Padding tambahan untuk menghindari overlap dengan nav bar
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
