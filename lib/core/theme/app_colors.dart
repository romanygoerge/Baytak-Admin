import 'package:flutter/material.dart';

/// Baytak Color System
/// Premium teal/emerald-based palette for real estate
class AppColors {
  AppColors._();

  // ─── Primary (Teal/Emerald) ──────────────────────────────────────
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFFCCFBF1);
  static const Color primaryDark = Color(0xFF2DD4BF);
  static const Color primaryDarkContainer = Color(0xFF134E4A);

  // ─── Secondary (Deep Blue) ────────────────────────────────────────
  static const Color secondary = Color(0xFF1E3A5F);
  static const Color secondaryLight = Color(0xFFDBEAFE);
  static const Color secondaryDark = Color(0xFF60A5FA);

  // ─── Accent (Amber/Gold) ──────────────────────────────────────────
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentDark = Color(0xFFFBBF24);

  // ─── Status Colors ────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFF87171);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ─── Light Theme Colors ───────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8FAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color inputFillLight = Color(0xFFF1F5F9);
  static const Color chipBackgroundLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);

  // ─── Dark Theme Colors ────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color inputFillDark = Color(0xFF334155);
  static const Color chipBackgroundDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF334155);

  // ─── Text Colors ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textHintDark = Color(0xFF475569);

  // ─── Property Status Colors ───────────────────────────────────────
  static const Color forSale = Color(0xFF0D9488);
  static const Color forRent = Color(0xFF6366F1);
  static const Color featured = Color(0xFFF59E0B);
  static const Color sponsored = Color(0xFFEC4899);

  // ─── Premium Category Colors ──────────────────────────────────────
  static const Color categoryApartment = Color(0xFF0D9488);
  static const Color categoryVilla = Color(0xFF6366F1);
  static const Color categoryDuplex = Color(0xFFEC4899);
  static const Color categoryPenthouse = Color(0xFFF59E0B);
  static const Color categoryStudio = Color(0xFF8B5CF6);
  static const Color categoryShop = Color(0xFF3B82F6);
  static const Color categoryOffice = Color(0xFF14B8A6);
  static const Color categoryLand = Color(0xFF22C55E);

  // ─── Gradient Colors ──────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D9488), Color(0xFF0891B2)],
  );

  static const LinearGradient primaryGradientDeep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F766E), Color(0xFF0E7490), Color(0xFF0891B2)],
  );

  static const LinearGradient heroGradientLogin = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D9488), Color(0xFF0E7490), Color(0xFF0EA5E9)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE2E8F0), Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
  );

  // ─── Banner Gradients ─────────────────────────────────────────────
  static const List<LinearGradient> bannerGradients = [
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0D9488), Color(0xFF0891B2), Color(0xFF06B6D4)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF59E0B), Color(0xFFF97316), Color(0xFFEF4444)],
    ),
  ];

  // ─── Category Gradients ───────────────────────────────────────────
  static List<LinearGradient> get categoryGradients => [
    const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)]),
    const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
    const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFF472B6)]),
    const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]),
    const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)]),
    const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)]),
    const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF2DD4BF)]),
    const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF4ADE80)]),
    const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFFB923C)]),
    const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFF87171)]),
    const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)]),
    const LinearGradient(colors: [Color(0xFFD946EF), Color(0xFFE879F9)]),
    const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)]),
    const LinearGradient(colors: [Color(0xFF84CC16), Color(0xFFA3E635)]),
  ];
}
