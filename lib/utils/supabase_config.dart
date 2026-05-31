import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://fghccefhxorhnpgvxjvb.supabase.co';

  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZnaGNjZWZoeG9yaG5wZ3Z4anZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyMjEwMTMsImV4cCI6MjA5NTc5NzAxM30.wK7KvMbvYax4u9jTCDRIVwX4NC00EMxgvEk1awWptKQ';

  static SupabaseClient get client => Supabase.instance.client;

  static String _mimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  static Future<String?> uploadReportPhoto(String localPath) async {
    try {
      final file = File(localPath);
      final bytes = await file.readAsBytes();
      final ext = localPath.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.hashCode}.$ext';

      await client.storage.from('reports').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: _mimeType(ext)),
          );

      final publicUrl = client.storage.from('reports').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('[SupabaseConfig] uploadReportPhoto failed: $e');
      return null;
    }
  }
}
