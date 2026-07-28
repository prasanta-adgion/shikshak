import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class DateTimeUtils {
  const DateTimeUtils._();

  // ── Pickers ────────────────────────────────────────────────────────────

  static Future<DateTime?> showAppDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
  }) {
    return showDatePicker(
      context: context,
      // Clamped rather than asserted: callers derive the range from a sibling
      // field, and a stale value would otherwise crash the picker.
      initialDate: _clamp(initialDate, firstDate, lastDate),
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: initialDatePickerMode,
      builder: (context, child) => _PickerFrame(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Theme(
            data: Theme.of(context).copyWith(
              datePickerTheme: DatePickerThemeData(
                backgroundColor: isDark
                    ? AppColors.darkNavy
                    : colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.card,
                ),
                headerBackgroundColor: AppColors.darkNavy,
                headerForegroundColor: colorScheme.onPrimary,
                headerHeadlineStyle: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                ),
                headerHelpStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onPrimary.withValues(alpha: 0.7),
                ),
                weekdayStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
                dayStyle: const TextStyle(fontSize: 14),
                dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return colorScheme.onPrimary;
                  }
                  if (states.contains(WidgetState.disabled)) {
                    return colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
                  }
                  return colorScheme.onSurface;
                }),
                dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return colorScheme.primary;
                  }
                  return Colors.transparent;
                }),
                dayOverlayColor: WidgetStateProperty.all(
                  colorScheme.primary.withValues(alpha: 0.08),
                ),
                todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return colorScheme.onPrimary;
                  }
                  return colorScheme.primary;
                }),
                todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return colorScheme.primary;
                  }
                  return Colors.transparent;
                }),
                todayBorder: BorderSide(color: colorScheme.primary, width: 1.5),
                yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return colorScheme.onPrimary;
                  }
                  return colorScheme.onSurface;
                }),
                yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return colorScheme.primary;
                  }
                  return Colors.transparent;
                }),
                yearOverlayColor: WidgetStateProperty.all(
                  colorScheme.primary.withValues(alpha: 0.08),
                ),
                surfaceTintColor: Colors.transparent,
                elevation: 8,
                shadowColor: colorScheme.primary.withValues(alpha: 0.2),
                confirmButtonStyle: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                cancelButtonStyle: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                dividerColor: Colors.transparent,
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }

  static Future<TimeOfDay?> showAppTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => _PickerFrame(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;

          return Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.card,
                ),
                dialBackgroundColor: colorScheme.primary.withValues(
                  alpha: 0.08,
                ),
                dialHandColor: colorScheme.primary,
                dialTextColor: colorScheme.onSurface,
                hourMinuteShape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.card,
                ),
                hourMinuteColor: colorScheme.primary.withValues(alpha: 0.1),
                hourMinuteTextColor: colorScheme.onSurface,
                hourMinuteTextStyle: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
                dayPeriodShape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.card,
                ),
                dayPeriodColor: colorScheme.primary.withValues(alpha: 0.1),
                dayPeriodTextColor: colorScheme.primary,
                dayPeriodTextStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                dayPeriodBorderSide: BorderSide.none,
                entryModeIconColor: colorScheme.primary,
                helpTextStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: colorScheme.onSurfaceVariant,
                ),
                confirmButtonStyle: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                cancelButtonStyle: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                elevation: 8,
                padding: const EdgeInsets.all(24),
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }

  // ── Formatting ─────────────────────────────────────────────────────────
  //
  // Hand-rolled: the project has no `intl` dependency.

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// `12 Mar 2020`
  static String dayMonthYear(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// `Mar 2020` — enough precision for an employment range.
  static String monthYear(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';

  /// `2019-04-01` — the shape API payloads carry.
  static String isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// `9:05 AM`
  static String timeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  static DateTime _clamp(DateTime value, DateTime first, DateTime last) {
    if (value.isBefore(first)) return first;
    if (value.isAfter(last)) return last;
    return value;
  }
}

/// Blurred backdrop and slight downscale shared by both pickers.
class _PickerFrame extends StatelessWidget {
  const _PickerFrame({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Transform.scale(scale: 0.85, child: Builder(builder: builder)),
    );
  }
}
