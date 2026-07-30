import 'package:flutter/material.dart';

import '../../../../../core/media/picked_media.dart';
import '../../domain/entities/teacher_document.dart';

class DocumentFormController {
  DocumentFormController({TeacherDocument? initial})
    : documentType = ValueNotifier<DocumentType?>(initial?.documentType),
      fileUrl = ValueNotifier<String?>(initial?.fileUrl),
      fileName = ValueNotifier<String?>(initial?.fileName),
      localFilePath = ValueNotifier<String?>(initial?.localFilePath),
      mimeType = ValueNotifier<String?>(initial?.mimeType),
      fileSizeBytes = ValueNotifier<int?>(initial?.fileSizeBytes);

  final formKey = GlobalKey<FormState>();

  final ValueNotifier<DocumentType?> documentType;

  /// Remote URL of a file already stored, and the four fields that describe
  /// one picked on the device but not yet uploaded.
  final ValueNotifier<String?> fileUrl;
  final ValueNotifier<String?> fileName;
  final ValueNotifier<String?> localFilePath;
  final ValueNotifier<String?> mimeType;
  final ValueNotifier<int?> fileSizeBytes;

  /// The type select has no validator of its own, so its error stays hidden
  /// until the first submit.
  final showErrors = ValueNotifier<bool>(false);

  /// True once there is something to send — a stored URL or a picked file.
  bool get hasFile =>
      (fileName.value?.isNotEmpty ?? false) ||
      (fileUrl.value?.isNotEmpty ?? false);

  /// True when nothing has been chosen — the teacher has filed what they
  /// wanted and left the form blank.
  bool get isEmpty => documentType.value == null && !hasFile;

  bool validate() {
    showErrors.value = true;

    final formValid = formKey.currentState?.validate() ?? true;
    return formValid && documentType.value != null && hasFile;
  }

  /// Replaces the attached file. The stored URL is dropped so the new file is
  /// uploaded rather than the old one being sent again.
  void attach(PickedMedia media) {
    fileName.value = media.name;
    localFilePath.value = media.path;
    mimeType.value = media.mimeType;
    fileSizeBytes.value = media.sizeBytes;
    fileUrl.value = null;
  }

  void removeFile() {
    fileName.value = null;
    localFilePath.value = null;
    mimeType.value = null;
    fileSizeBytes.value = null;
    fileUrl.value = null;
  }

  TeacherDocument toDocument() => TeacherDocument(
    documentType: documentType.value,
    fileName: fileName.value,
    localFilePath: localFilePath.value,
    fileUrl: fileUrl.value,
    mimeType: mimeType.value,
    fileSizeBytes: fileSizeBytes.value,
  );

  void setFrom(TeacherDocument document) {
    documentType.value = document.documentType;
    fileName.value = document.fileName;
    localFilePath.value = document.localFilePath;
    fileUrl.value = document.fileUrl;
    mimeType.value = document.mimeType;
    fileSizeBytes.value = document.fileSizeBytes;
    showErrors.value = false;
  }

  void reset() {
    formKey.currentState?.reset();
    documentType.value = null;
    removeFile();
    showErrors.value = false;
  }

  void dispose() {
    documentType.dispose();
    fileUrl.dispose();
    fileName.dispose();
    localFilePath.dispose();
    mimeType.dispose();
    fileSizeBytes.dispose();
    showErrors.dispose();
  }
}
