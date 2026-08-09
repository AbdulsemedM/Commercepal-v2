import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Picks and compresses images for visual product search.
class CameraService {
  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const int maxDimension = 800;
  static const int imageQuality = 70;

  Future<String?> pickFromCameraBase64() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxDimension.toDouble(),
      maxHeight: maxDimension.toDouble(),
      imageQuality: imageQuality,
    );
    if (image == null) return null;
    return _encodeImage(image);
  }

  Future<String?> pickFromGalleryBase64() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxDimension.toDouble(),
      maxHeight: maxDimension.toDouble(),
      imageQuality: imageQuality,
    );
    if (image == null) return null;
    return _encodeImage(image);
  }

  Future<String> _encodeImage(XFile image) async {
    final Uint8List bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }
}
