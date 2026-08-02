class PickedMedia {
  /// Absolute path on the device — what gets uploaded.
  final String path;

  /// File name with its extension, for display and for the payload.
  final String name;

  final int sizeBytes;

  /// Derived from the extension, e.g. `application/pdf`.
  final String mimeType;

  const PickedMedia({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.mimeType,
  });

  /// `1.2 MB` — for display only; payloads carry [sizeBytes].
  String get readableSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Extension without the dot, lowercased. Empty when the name has none.
  String get extension {
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }
}

enum ImagePickSource { camera, gallery }

abstract final class MimeTypes {
  static const String fallback = 'application/octet-stream';

  static const Map<String, String> _byExtension = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'heic': 'image/heic',
    'webp': 'image/webp',
    'gif': 'image/gif',
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'txt': 'text/plain',
  };

  /// Extensions the document picker offers.
  static const List<String> documentExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'doc',
    'docx',
  ];

  static String forFileName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return fallback;
    return _byExtension[name.substring(dot + 1).toLowerCase()] ?? fallback;
  }
}
