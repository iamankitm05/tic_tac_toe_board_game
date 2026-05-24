import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primaryBackground = Color(0xFF0F0E26); // Deep space background
  static const Color cardBackground = Color(0xFF0D0C1D); // Glass card color
  static const Color creatorColor = Colors.pinkAccent; // Player 1 (X) status
  static const Color guestColor = Colors.cyanAccent; // Player 2 (O) status
  
  static const Color pinkAccent = Colors.pinkAccent;
  static const Color cyanAccent = Colors.cyanAccent;
  static const Color indigoAccent = Colors.indigoAccent;
  static const Color purpleAccent = Colors.purpleAccent;
  static const Color greenAccent = Colors.greenAccent;
  static const Color redAccent = Colors.redAccent;
  static const Color amberAccent = Colors.amberAccent;
  static const Color orangeAccent = Colors.orangeAccent;
  
  static final Color glassBorder = Colors.white.withValues(alpha: 0.08);
  static final Color textMuted = Colors.white.withValues(alpha: 0.38);
  static final Color textSecondary = Colors.white.withValues(alpha: 0.7);
  static const Color textPrimary = Colors.white;
}
