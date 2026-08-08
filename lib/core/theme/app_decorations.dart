import 'package:flutter/material.dart';

/// Reusable decorations and styles for consistent UI
class AppDecorations {
  AppDecorations._();

  // ─── Border Radius ─────────────────────────────────────
  static const double radiusXs = 8;
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radiusXxl = 28;
  static const double radiusFull = 100;

  // ─── Spacing ───────────────────────────────────────────
  static const double spaceXxs = 2;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 20;
  static const double spaceXxl = 24;
  static const double space3xl = 32;
  static const double space4xl = 40;
  static const double space5xl = 48;

  // ─── Shadows ───────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  // ─── Premium Colored Shadows ──────────────────────────
  static List<BoxShadow> coloredShadow(Color color, {double opacity = 0.25}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── Card Decorations ─────────────────────────────────
  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      ),
    );
  }

  // ─── Premium Card ─────────────────────────────────────
  static BoxDecoration premiumCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(radiusXl),
      border: Border.all(
        color: isDark
            ? const Color(0xFF334155).withValues(alpha: 0.5)
            : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
        if (!isDark)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
      ],
    );
  }

  // ─── Glass Morphism ───────────────────────────────────
  static BoxDecoration glassMorphism(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ─── Frosted Glass Search Bar ─────────────────────────
  static BoxDecoration frostedSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E293B).withValues(alpha: 0.9)
          : Colors.white,
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(
        color: isDark
            ? const Color(0xFF475569).withValues(alpha: 0.4)
            : const Color(0xFFE2E8F0),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        if (!isDark)
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 2),
          ),
      ],
    );
  }

  // ─── Category Item ────────────────────────────────────
  static BoxDecoration categoryItem({
    required LinearGradient gradient,
    bool isSelected = false,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(radiusMd),
      boxShadow: [
        BoxShadow(
          color: gradient.colors.first.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ─── Banner Card ──────────────────────────────────────
  static BoxDecoration bannerCard(LinearGradient gradient) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(radiusXl),
      boxShadow: [
        BoxShadow(
          color: gradient.colors.first.withValues(alpha: 0.3),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // ─── Gradient Overlay ──────────────────────────────────
  static BoxDecoration imageOverlay = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: 0.7),
      ],
    ),
  );

  // ─── Section Divider ──────────────────────────────────
  static Widget sectionDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 8,
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
    );
  }
}
