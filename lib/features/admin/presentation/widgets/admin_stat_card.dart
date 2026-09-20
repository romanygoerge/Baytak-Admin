import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Premium interactive stat card for admin dashboard
class AdminStatCard extends StatefulWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final bool isDark;
  final String? subtitle;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.isDark,
    this.subtitle,
  });

  @override
  State<AdminStatCard> createState() => _AdminStatCardState();
}

class _AdminStatCardState extends State<AdminStatCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.4)
                  : (widget.isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.borderLight),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.color.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: widget.isDark ? 0.25 : 0.04),
                blurRadius: _isHovered ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withValues(alpha: 0.2),
                          widget.color.withValues(alpha: 0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: widget.color.withValues(alpha: 0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: _isHovered ? 0.3 : 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 22),
                  ),
                  const Spacer(),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: widget.count),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        _formatNumber(value),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
