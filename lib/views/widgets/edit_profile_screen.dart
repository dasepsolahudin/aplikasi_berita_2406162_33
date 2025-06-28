import 'dart:io';
import 'package:inews/views/utils/form_validaror.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/edit_profile_controller.dart';
import '../utils/helper.dart' as helper;

class EditProfileScreen extends StatefulWidget {
  final String userId;

  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Fungsi helper untuk menampilkan gambar
  Widget _buildProfileImage(EditProfileController controller) {
    if (controller.selectedImageFile != null) {
      return Image.file(controller.selectedImageFile!, fit: BoxFit.cover);
    }
    if (!controller.imageWasRemoved &&
        controller.initialProfileImagePath != null) {
      final path = controller.initialProfileImagePath!;
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _defaultAvatar(),
        );
      } else {
        final file = File(path);
        if (file.existsSync()) {
          return Image.file(file, fit: BoxFit.cover);
        }
      }
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Icon(
      Icons.person_rounded,
      size: 80,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
    );
  }

  void _showImageSourceActionSheet(
    BuildContext context,
    EditProfileController controller,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 60.0,
            ), // Padding untuk menghindari tumpang tindih
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.photo_library_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    controller.pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Ambil Foto dari Kamera'),
                  onTap: () {
                    controller.pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                if (controller.selectedImageFile != null ||
                    (controller.initialProfileImagePath != null &&
                        !controller.imageWasRemoved))
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      'Hapus Foto Profil',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onTap: () {
                      controller.removeProfileImage();
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => EditProfileController(userId: widget.userId),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text('Edit Profil', style: theme.appBarTheme.titleTextStyle),
        ),
        // TOMBOL SIMPAN DIPINDAHKAN KE BAWAH
        bottomNavigationBar: Consumer<EditProfileController>(
          builder: (context, controller, child) {
            return Padding(
              // Padding untuk memastikan tombol tidak tertutup keyboard
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            Map<String, dynamic> result = await controller
                                .saveProfileChanges();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result['message'],
                                    style: TextStyle(
                                      color: theme.colorScheme.onInverseSurface,
                                    ),
                                  ),
                                  backgroundColor: result['success']
                                      ? helper.cSuccess
                                      : theme.colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              if (result['success']) {
                                context.pop(true);
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan Perubahan'),
                ),
              ),
            );
          },
        ),
        body: Consumer<EditProfileController>(
          builder: (context, controller, child) {
            if (controller.isLoading &&
                controller.usernameController.text.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              );
            }
            if (controller.errorMessage != null) {
              return Center(child: Text(controller.errorMessage!));
            }
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  // --- BAGIAN GAMBAR PROFIL DENGAN LATAR GRADASI ---
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: GestureDetector(
                      onTap: () =>
                          _showImageSourceActionSheet(context, controller),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 64,
                              backgroundColor: theme.cardColor,
                              child: CircleAvatar(
                                radius: 62,
                                backgroundColor: theme.scaffoldBackgroundColor,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 124,
                                    height: 124,
                                    child: _buildProfileImage(controller),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.dividerColor,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: theme.colorScheme.primary
                                    .withOpacity(0.9),
                                child: Icon(
                                  Icons.edit_rounded,
                                  color: theme.colorScheme.onPrimary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- FORMULIR DALAM WADAH KARTU ---
                  _buildTextField(
                    context: context,
                    controller: controller.usernameController,
                    label: "Nama Pengguna",
                    icon: Icons.person_outline_rounded,
                    validator: AppValidators.validateName,
                  ),
                  _buildTextField(
                    context: context,
                    controller: controller.emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                    validator: AppValidators.validateEmail,
                    readOnly: true,
                  ),
                  _buildTextField(
                    context: context,
                    controller: controller.phoneController,
                    label: "Nomor Telepon",
                    icon: Icons.phone_outlined,
                    validator: AppValidators.validatePhoneNumber,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    context: context,
                    controller: controller.addressController,
                    label: "Alamat",
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                  ),
                  _buildTextField(
                    context: context,
                    controller: controller.cityController,
                    label: "Kota",
                    icon: Icons.location_city_outlined,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET HELPER TEXT FIELD DENGAN GAYA MINIMALIS BARU ---
  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.hintColor),
          prefixIcon: Icon(icon, color: theme.hintColor, size: 22),
          filled: true,
          fillColor: readOnly
              ? theme.disabledColor.withOpacity(0.1)
              : theme.cardColor.withOpacity(0.5),
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
              width: 2.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
        keyboardType: keyboardType,
        readOnly: readOnly,
        maxLines: maxLines,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}
