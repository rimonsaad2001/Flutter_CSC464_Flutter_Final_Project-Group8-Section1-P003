import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageHelper {
  static Widget load(
    String image, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    const fallback = Icon(Icons.image_not_supported);

    // ❌ empty or null-safe check
    if (image.isEmpty) {
      return fallback;
    }

    // 🌐 Network image
    if (image.startsWith('http')) {
      return Image.network(
        image,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    // 📦 Base64 image (safe decode)
    try {
      Uint8List bytes = base64Decode(image);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    } catch (e) {
      return fallback;
    }
  }
}
