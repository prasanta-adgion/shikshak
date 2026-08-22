import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shiksak/core/media/i_media_picker.dart';

import '../theme/app_colors.dart';
import 'picked_media.dart';

class MediaPickerImpl implements IMediaPicker {
  MediaPickerImpl({ImagePicker? imagePicker, ImageCropper? cropper})
    : _picker = imagePicker ?? ImagePicker(),
      _cropper = cropper ?? ImageCropper();

  final ImagePicker _picker;
  final ImageCropper _cropper;

  static const double _maxImageEdge = 1600;
  static const int _imageQuality = 85;

  @override
  Future<PickedMedia?> pickImage({
    required ImagePickSource source,
    bool crop = false,
    CropAspectRatio? aspectRatio,
  }) async {
    final picked = await _picker.pickImage(
      source: source == ImagePickSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: _maxImageEdge,
      maxHeight: _maxImageEdge,
      imageQuality: _imageQuality,
    );
    if (picked == null) return null;

    if (!crop) return _fromPath(picked.path, name: picked.name);

    final cropped = await _cropImage(picked.path, aspectRatio: aspectRatio);
    // Cancelling the cropper cancels the pick — the alternative is silently
    // using an image the teacher was still editing.
    if (cropped == null) return null;

    return _fromPath(cropped.path, name: picked.name);
  }

  @override
  Future<PickedMedia?> pickDocument({List<String>? allowedExtensions}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions ?? MimeTypes.documentExtensions,
    );

    final file = result?.files.firstOrNull;
    final path = file?.path;
    if (file == null || path == null) return null;

    return PickedMedia(
      path: path,
      name: file.name,
      sizeBytes: file.size,
      mimeType: MimeTypes.forFileName(file.name),
    );
  }

  Future<CroppedFile?> _cropImage(
    String sourcePath, {
    CropAspectRatio? aspectRatio,
  }) {
    return _cropper.cropImage(
      sourcePath: sourcePath,
      aspectRatio: aspectRatio,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: _imageQuality,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop photo',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primary,
          lockAspectRatio: aspectRatio != null,
        ),
        IOSUiSettings(
          title: 'Crop photo',
          aspectRatioLockEnabled: aspectRatio != null,
        ),
      ],
    );
  }

  /// Reads the size off disk — neither picker reports it for images.
  Future<PickedMedia> _fromPath(String path, {required String name}) async {
    final length = await File(path).length();

    return PickedMedia(
      path: path,
      name: name,
      sizeBytes: length,
      mimeType: MimeTypes.forFileName(name),
    );
  }
}
