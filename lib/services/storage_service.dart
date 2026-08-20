import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final FirebaseStorage _storage =
      FirebaseStorage.instance;

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  static Future<String> uploadProductImage(
      File file,
      String productId,
      ) async {
    final reference = _storage
        .ref()
        .child('products')
        .child('$productId.jpg');

    await reference.putFile(file);

    return await reference.getDownloadURL();
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  static Future<String> uploadProfileImage(
      File file,
      String userId,
      ) async {
    final reference = _storage
        .ref()
        .child('profiles')
        .child('$userId.jpg');

    await reference.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
      ),
    );

    return await reference.getDownloadURL();
  }

  // ============================================================
  // DELETE PROFILE IMAGE
  // ============================================================

  static Future<void> deleteProfileImage(
      String userId,
      ) async {
    try {
      final reference = _storage
          .ref()
          .child('profiles')
          .child('$userId.jpg');

      await reference.delete();
    } catch (_) {
      // Image may not exist yet.
    }
  }
}