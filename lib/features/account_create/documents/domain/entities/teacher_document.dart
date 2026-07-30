class TeacherDocument {
  const TeacherDocument({
    this.documentType,
    this.fileName,
    this.localFilePath,
    this.fileUrl,
    this.mimeType,
    this.fileSizeBytes,
  });

  final DocumentType? documentType;

  /// Display name of the attached file — what the payload carries.
  final String? fileName;

  /// Path on the device, set by the picker. Distinct from [fileName]: only a
  /// real path can be uploaded, and it never reaches the payload.
  final String? localFilePath;

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
    String? localFilePath,
    String? fileUrl,
    String? mimeType,
    int? fileSizeBytes,
  }) => TeacherDocument(
    documentType: documentType ?? this.documentType,
    fileName: fileName ?? this.fileName,
    localFilePath: localFilePath ?? this.localFilePath,
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
