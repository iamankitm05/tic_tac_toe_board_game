import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';
import 'package:tic_tac_toe_board_game/utils/app_colors.dart';

abstract final class MyToast {
  static void success(BuildContext context, String message) {
    toastification.showCustom(
      context: context,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 300),
      builder: (context, item) {
        return _CustomNeonToast(
          message: message,
          accentColor: AppColors.greenAccent,
          icon: Icons.check_circle_outlined,
        );
      },
    );
  }

  static void error(BuildContext context, String message) {
    toastification.showCustom(
      context: context,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 300),
      builder: (context, item) {
        return _CustomNeonToast(
          message: message,
          accentColor: AppColors.creatorColor,
          icon: Icons.error_outline_rounded,
        );
      },
    );
  }

  static void warning(BuildContext context, String message) {
    toastification.showCustom(
      context: context,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 300),
      builder: (context, item) {
        return _CustomNeonToast(
          message: message,
          accentColor: AppColors.amberAccent,
          icon: Icons.warning_amber_outlined,
        );
      },
    );
  }

  static void info(BuildContext context, String message) {
    toastification.showCustom(
      context: context,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 300),
      builder: (context, item) {
        return _CustomNeonToast(
          message: message,
          accentColor: AppColors.guestColor,
          icon: Icons.info_outline_rounded,
        );
      },
    );
  }
}

class _CustomNeonToast extends StatelessWidget {
  const _CustomNeonToast({
    required this.message,
    required this.accentColor,
    required this.icon,
  });

  final String message;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground.withValues(
            alpha: 0.9,
          ), // Deep dark premium background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
