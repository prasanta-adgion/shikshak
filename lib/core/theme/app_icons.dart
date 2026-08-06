import 'package:flutter/material.dart';

/// Semantic icon registry.
///
/// Widgets reference icons by meaning (`AppIcons.teacher`) instead of raw
/// [Icons] constants, so swapping to a custom icon font later is a
/// single-file change.
abstract final class AppIcons {
  // Brand / identity
  static const IconData logo = Icons.auto_stories_rounded;

  // Roles
  static const IconData teacher = Icons.co_present_rounded;
  static const IconData student = Icons.school_rounded;

  // Auth
  static const IconData email = Icons.alternate_email_rounded;
  static const IconData phone = Icons.phone_iphone_rounded;
  static const IconData identifier = Icons.person_outline_rounded;
  static const IconData password = Icons.lock_outline_rounded;
  static const IconData passwordVisible = Icons.visibility_outlined;
  static const IconData passwordHidden = Icons.visibility_off_outlined;
  static const IconData name = Icons.badge_outlined;
  static const IconData qualification = Icons.workspace_premium_outlined;
  static const IconData experience = Icons.timeline_rounded;
  static const IconData city = Icons.location_city_rounded;
  static const IconData studentClass = Icons.class_outlined;

  // Navigation & actions
  static const IconData back = Icons.arrow_back_ios_new_rounded;
  static const IconData forward = Icons.arrow_forward_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData notifications = Icons.notifications_none_rounded;
  static const IconData logout = Icons.logout_rounded;
  static const IconData more = Icons.more_horiz_rounded;

  // Dashboard — student
  static const IconData home = Icons.home_rounded;
  static const IconData homeOutlined = Icons.home_outlined;
  static const IconData bookings = Icons.event_note_rounded;
  static const IconData bookingsOutlined = Icons.event_note_outlined;
  static const IconData materials = Icons.menu_book_rounded;
  static const IconData materialsOutlined = Icons.menu_book_outlined;
  static const IconData profile = Icons.person_rounded;
  static const IconData profileOutlined = Icons.person_outline_rounded;
  static const IconData star = Icons.star_rounded;

  // Dashboard — teacher
  static const IconData schedule = Icons.calendar_month_rounded;
  static const IconData scheduleOutlined = Icons.calendar_month_outlined;
  static const IconData students = Icons.groups_rounded;
  static const IconData studentsOutlined = Icons.groups_outlined;
  static const IconData earnings = Icons.account_balance_wallet_rounded;
  static const IconData earningsOutlined =
      Icons.account_balance_wallet_outlined;
  static const IconData availability = Icons.event_available_rounded;
  static const IconData trendingUp = Icons.trending_up_rounded;
  static const IconData hours = Icons.schedule_rounded;
  static const IconData rating = Icons.grade_rounded;

  // Class schedule
  static const IconData addClass = Icons.add_rounded;
  static const IconData classOnline = Icons.videocam_outlined;
  static const IconData classInPerson = Icons.location_on_outlined;
  static const IconData classHybrid = Icons.sync_alt_rounded;
  static const IconData subject = Icons.menu_book_outlined;
  static const IconData inactive = Icons.pause_circle_outline_rounded;

  // Profile
  static const IconData gender = Icons.wc_rounded;
  static const IconData birthday = Icons.cake_outlined;
  static const IconData address = Icons.location_on_outlined;
  static const IconData country = Icons.public_rounded;
  static const IconData postalCode = Icons.markunread_mailbox_outlined;
  static const IconData about = Icons.info_outline_rounded;
  static const IconData education = Icons.school_outlined;
  static const IconData documents = Icons.folder_open_rounded;

  // States
  static const IconData error = Icons.error_outline_rounded;
  static const IconData empty = Icons.inbox_rounded;
  static const IconData retry = Icons.refresh_rounded;
  static const IconData success = Icons.check_circle_rounded;
}
