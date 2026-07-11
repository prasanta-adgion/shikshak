import 'package:flutter/material.dart';

/// Placeholder view models + data for the student dashboard.
///
/// Lives in the presentation layer on purpose: this is UI-only demo content
/// that will be replaced by real domain entities once the discovery API
/// exists.
class SubjectCategory {
  const SubjectCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;
}

class TutorInfo {
  const TutorInfo({
    required this.name,
    required this.subject,
    required this.qualification,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.feePerHour,
  });

  final String name;
  final String subject;
  final String qualification;
  final double rating;
  final int reviews;
  final String experience;
  final int feePerHour;
}

abstract final class StudentDummyData {
  static const categories = [
    SubjectCategory(
      name: 'Mathematics',
      icon: Icons.calculate_rounded,
      color: Color(0xFF6366F1),
    ),
    SubjectCategory(
      name: 'Science',
      icon: Icons.science_rounded,
      color: Color(0xFF14B8A6),
    ),
    SubjectCategory(
      name: 'English',
      icon: Icons.translate_rounded,
      color: Color(0xFFF59E0B),
    ),
    SubjectCategory(
      name: 'Coding',
      icon: Icons.code_rounded,
      color: Color(0xFF8B5CF6),
    ),
    SubjectCategory(
      name: 'Music',
      icon: Icons.music_note_rounded,
      color: Color(0xFFEC4899),
    ),
    SubjectCategory(
      name: 'Arts',
      icon: Icons.palette_rounded,
      color: Color(0xFFF97316),
    ),
  ];

  static const featuredTeachers = [
    TutorInfo(
      name: 'Priya Sharma',
      subject: 'Mathematics',
      qualification: 'M.Sc. Mathematics, B.Ed.',
      rating: 4.9,
      reviews: 128,
      experience: '8 yrs',
      feePerHour: 600,
    ),
    TutorInfo(
      name: 'Rahul Verma',
      subject: 'Physics',
      qualification: 'M.Tech, IIT Delhi',
      rating: 4.8,
      reviews: 96,
      experience: '6 yrs',
      feePerHour: 750,
    ),
    TutorInfo(
      name: 'Anjali Gupta',
      subject: 'English',
      qualification: 'M.A. English Literature',
      rating: 4.7,
      reviews: 84,
      experience: '5 yrs',
      feePerHour: 450,
    ),
    TutorInfo(
      name: 'Vikram Iyer',
      subject: 'Computer Science',
      qualification: 'B.Tech CSE, Ex-Infosys',
      rating: 4.9,
      reviews: 152,
      experience: '10 yrs',
      feePerHour: 900,
    ),
  ];

  static const recentTutors = [
    TutorInfo(
      name: 'Sneha Banerjee',
      subject: 'Chemistry',
      qualification: 'M.Sc. Chemistry',
      rating: 4.6,
      reviews: 58,
      experience: '4 yrs',
      feePerHour: 500,
    ),
    TutorInfo(
      name: 'Arjun Nair',
      subject: 'Biology',
      qualification: 'MBBS Student, AIIMS',
      rating: 4.8,
      reviews: 72,
      experience: '3 yrs',
      feePerHour: 550,
    ),
    TutorInfo(
      name: 'Kavita Rao',
      subject: 'Hindi',
      qualification: 'M.A. Hindi',
      rating: 4.5,
      reviews: 41,
      experience: '7 yrs',
      feePerHour: 400,
    ),
  ];
}
