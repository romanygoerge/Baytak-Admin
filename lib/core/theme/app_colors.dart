import 'package:flutter/material.dart';

/// Baytak Color System
/// Luxury Midnight Navy & Royal Gold palette matching the official brand logo
class AppColors {
  AppColors._();

  // ─── Primary (Midnight Navy Blue - From Logo B & Typography) ──────
  static const Color primary = Color(0xFF132238);
  static const Color primaryLight = Color(0xFF1E3554);
  static const Color primaryDark = Color(0xFF0B1524);
  static const Color primaryDarkContainer = Color(0xFF070E18);

  // ─── Secondary & Accent (Luxury Gold - From Logo Roof & Towers) ────
  static const Color secondary = Color(0xFFC5A059);
  static const Color secondaryLight = Color(0xFFE5C158);
  static const Color secondaryDark = Color(0xFF9A7B38);

  // ─── Accent (Gold) ────────────────────────────────────────────────
  static const Color accent = Color(0xFFC5A059);
  static const Color accentDark = Color(0xFFB8860B);

  // ─── Status Colors ────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFF87171);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ─── Light Theme Colors ───────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color inputFillLight = Color(0xFFF1F5F9);
  static const Color chipBackgroundLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);

  // ─── Dark Theme Colors (Rich Midnight Navy Black) ─────────────────
  static const Color backgroundDark = Color(0xFF0A111D);
  static const Color surfaceDark = Color(0xFF121E30);
  static const Color cardDark = Color(0xFF121E30);
  static const Color inputFillDark = Color(0xFF1B2A40);
  static const Color chipBackgroundDark = Color(0xFF1B2A40);
  static const Color borderDark = Color(0xFF1B2A40);

  // ─── Text Colors ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textHintDark = Color(0xFF475569);

  // ─── Property Status Colors ───────────────────────────────────────
  static const Color forSale = Color(0xFF132238);
  static const Color forRent = Color(0xFFC5A059);
  static const Color featured = Color(0xFFD4AF37);
  static const Color sponsored = Color(0xFFE5C158);

  // ─── Premium Category Colors ──────────────────────────────────────
  static const Color categoryApartment = Color(0xFF132238);
  static const Color categoryVilla = Color(0xFFC5A059);
  static const Color categoryDuplex = Color(0xFF1E3554);
  static const Color categoryPenthouse = Color(0xFFD4AF37);
  static const Color categoryStudio = Color(0xFF8B5CF6);
  static const Color categoryShop = Color(0xFF3B82F6);
  static const Color categoryOffice = Color(0xFF10B981);
  static const Color categoryLand = Color(0xFF22C55E);

  // ─── Gradient Colors (Navy & Gold Theme) ──────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF132238), Color(0xFF1E3A5F)],
  );

  static const LinearGradient primaryGradientDeep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1524), Color(0xFF132238), Color(0xFF1D3352)],
  );

  static const LinearGradient heroGradientLogin = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1524), Color(0xFF132238), Color(0xFF1E3A5F)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF121E30), Color(0xFF0A111D)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC5A059), Color(0xFFE5C158), Color(0xFFD4AF37)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF132238), Color(0xFFC5A059)],
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
      colors: [Color(0xFF132238), Color(0xFF1E3A5F), Color(0xFF2A4D7C)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFC5A059), Color(0xFFE5C158), Color(0xFFF5E096)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0B1524), Color(0xFF132238), Color(0xFFC5A059)],
    ),
  ];

  // ─── Category Gradients ───────────────────────────────────────────
  static List<LinearGradient> get categoryGradients => [
    const LinearGradient(colors: [Color(0xFF132238), Color(0xFF1E3554)]),
    const LinearGradient(colors: [Color(0xFFC5A059), Color(0xFFE5C158)]),
    const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2A4D7C)]),
    const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFF5E096)]),
    const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)]),
    const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)]),
    const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
    const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF4ADE80)]),
    const LinearGradient(colors: [Color(0xFF132238), Color(0xFFC5A059)]),
    const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFF87171)]),
    const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)]),
    const LinearGradient(colors: [Color(0xFFD946EF), Color(0xFFE879F9)]),
    const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)]),
    const LinearGradient(colors: [Color(0xFF84CC16), Color(0xFFA3E635)]),
  ];
}
