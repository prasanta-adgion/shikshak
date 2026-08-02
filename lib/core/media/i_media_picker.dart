import 'package:Shikshak/core/media/picked_media.dart';
import 'package:image_cropper/image_cropper.dart';

abstract interface class IMediaPicker {
  Future<PickedMedia?> pickImage({
    required ImagePickSource source,
    bool crop = false,
    CropAspectRatio? aspectRatio,
  });

  Future<PickedMedia?> pickDocument({List<String>? allowedExtensions});
}
