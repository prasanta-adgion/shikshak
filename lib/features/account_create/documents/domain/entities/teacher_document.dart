class TeacherDocument {
  const TeacherDocument({
    this.documentType,
    this.fileName,
    this.fileUrl,
    this.mimeType,
    this.fileSizeBytes,
  });

  final DocumentType? documentType;
  final String? fileName;
  final String? fileUrl;
  final String? mimeType;
  final int? fileSizeBytes;

  bool get hasFile => fileName != null;

  /// `1.2 MB` — for display only; the payload carries raw bytes.
  String get readableSize {
    final bytes = fileSizeBytes;
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  TeacherDocument copyWith({
    DocumentType? documentType,
    String? fileName,
    String? fileUrl,
    String? mimeType,
    int? fileSizeBytes,
  }) => TeacherDocument(
    documentType: documentType ?? this.documentType,
    fileName: fileName ?? this.fileName,
    fileUrl: fileUrl ?? this.fileUrl,
    mimeType: mimeType ?? this.mimeType,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
  );

  /// Drops the file while keeping the chosen type.
  TeacherDocument withoutFile() => TeacherDocument(documentType: documentType);
}

/// Values the `documentType` field accepts.
enum DocumentType {
  resume('Resume', 'resume'),
  idProof('ID Proof', 'id_proof'),
  certificate('Certificate', 'certificate'),
  other('Other', 'other');

  const DocumentType(this.label, this.wireValue);

  final String label;
  final String wireValue;
}
