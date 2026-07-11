import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';

/// Placeholder view models + data for the teacher dashboard.
/// Presentation-layer only; replaced by real analytics/booking entities
/// once those APIs exist.
class DashboardStat {
  const DashboardStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.delta,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  /// e.g. "+3 this week"
  final String? delta;
}

class ClassRequest {
  const ClassRequest({
    required this.studentName,
    required this.subject,
    required this.grade,
    required this.schedule,
    required this.mode,
  });

  final String studentName;
  final String subject;
  final String grade;
  final String schedule;
  final String mode;
}

class WeekdayAvailability {
  const WeekdayAvailability(this.day, this.available);

  final String day;
  final bool available;
}

abstract final class TeacherDummyData {
  static const stats = [
    DashboardStat(
      label: 'Total Students',
      value: '48',
      icon: AppIcons.students,
      color: AppColors.primary,
      delta: '+3 this week',
    ),
    DashboardStat(
      label: 'Classes This Week',
      value: '12',
      icon: AppIcons.schedule,
      color: AppColors.tertiary,
      delta: '4 remaining',
    ),
    DashboardStat(
      label: 'Average Rating',
      value: '4.8',
      icon: AppIcons.rating,
      color: AppColors.secondary,
      delta: '128 reviews',
    ),
    DashboardStat(
      label: 'Hours Taught',
      value: '320',
      icon: AppIcons.hours,
      color: AppColors.info,
      delta: '+9 this week',
    ),
  ];

  static const earningsThisMonth = '₹24,500';
  static const earningsGrowth = '+12.5% vs last month';

  /// Relative weekly earnings used to draw the mini bar chart (0..1).
  static const weeklyEarnings = [0.45, 0.6, 0.38, 0.75, 0.55, 0.9, 0.7];

  static const availability = [
    WeekdayAvailability('Mon', true),
    WeekdayAvailability('Tue', true),
    WeekdayAvailability('Wed', false),
    WeekdayAvailability('Thu', true),
    WeekdayAvailability('Fri', true),
    WeekdayAvailability('Sat', true),
    WeekdayAvailability('Sun', false),
  ];

  static const recentRequests = [
    ClassRequest(
      studentName: 'Aarav Mehta',
      subject: 'Mathematics',
      grade: 'Class 10',
      schedule: 'Mon & Wed, 5:00 PM',
      mode: 'Online',
    ),
    ClassRequest(
      studentName: 'Ishita Roy',
      subject: 'Physics',
      grade: 'Class 12',
      schedule: 'Tue & Thu, 6:30 PM',
      mode: 'Home Visit',
    ),
    ClassRequest(
      studentName: 'Rohan Das',
      subject: 'Mathematics',
      grade: 'Class 8',
      schedule: 'Sat, 10:00 AM',
      mode: 'Online',
    ),
  ];
}
