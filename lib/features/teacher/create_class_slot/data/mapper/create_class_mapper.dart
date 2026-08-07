import '../../../../../core/utils/date_time_picker_func.dart';
import '../../domain/params/create_class_params.dart';
import '../model/create_class_request.dart';

abstract final class CreateClassMapper {
  static CreateClassRequest toRequest(CreateClassParams params) {
    final validUntil = params.validUntil;

    return CreateClassRequest(
      title: params.title.trim(),
      description: _orNull(params.description),
      subjects: params.subjects,
      classes: params.classes,
      dayOfWeek: params.day.wireIndex,
      startTime: params.startTime.wire,
      endTime: params.endTime.wire,
      validFrom: DateTimeUtils.isoDate(params.validFrom),
      validUntil: validUntil == null ? null : DateTimeUtils.isoDate(validUntil),
      mode: params.mode.wire,

      venueName: params.mode.hasVenue ? _orNull(params.venueName) : null,
      venueAddress: params.mode.hasVenue ? _orNull(params.venueAddress) : null,
    );
  }

  static String? _orNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
