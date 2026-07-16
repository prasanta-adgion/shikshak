import 'package:flutter/widgets.dart';

/// Corner radius scale.
abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static const BorderRadius input = BorderRadius.all(Radius.circular(sm + 2));
  static const BorderRadius button = BorderRadius.all(Radius.circular(sm + 2));
  static const BorderRadius card = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
  static const BorderRadius chip = BorderRadius.all(Radius.circular(pill));
}
