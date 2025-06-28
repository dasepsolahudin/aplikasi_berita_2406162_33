import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class ImageUploadService {
  static const String _cloudName = "dvxdxblgx";
  static const String _uploadPreset = "rrtlbwdh";

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  Future<String?> uploadImage(File imageFile) async {
    try {
      print("Mengunggah gambar ke Cloudinary...");
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      print("Unggah berhasil. URL: ${response.secureUrl}");
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print("Error mengunggah gambar: ${e.message}");
      print(e.request);
      return null;
    } catch (e) {
      print("Terjadi kesalahan tidak terduga saat mengunggah gambar: $e");
      return null;
    }
  }
}
