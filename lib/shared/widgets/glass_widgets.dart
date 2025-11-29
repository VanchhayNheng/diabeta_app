import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double opacity;
  final double blur;

  const GlassCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.opacity = 0.95,
    this.blur = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? AppTheme.radiusXL,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: borderRadius ?? AppTheme.radiusXL,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: AppTheme.elevation3,
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final EdgeInsets? padding;
  final bool isLoading;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
    this.padding,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.primaryShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppTheme.radiusMedium,
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 18),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}

class GlassTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int? maxLines;

  const GlassTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final String? change;
  final bool? isPositive;

  // The constructor is already declared as const.
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.change,
    this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 1. ADDED const
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.08),
        borderRadius: AppTheme.radiusMedium,
      ),
      child: Column(
        // 2. ADDED const for children that don't depend on constructor arguments or context
        children: [
          // 3. ADDED const to TextStyle
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8), // ADDED const
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(height: 4), // ADDED const
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          // Conditional widgets cannot be const, but their children can be
          if (change != null) ...[
            const SizedBox(height: 8), // ADDED const
            Text(
              change!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isPositive == true
                    ? AppTheme.successGreen
                    : AppTheme.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppTheme.radiusLarge,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radiusLarge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppTheme.primaryShadow,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class Badge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const Badge({
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  factory Badge.success(String text) {
    return Badge(
      text: text,
      backgroundColor: AppTheme.successGreen.withOpacity(0.15),
      textColor: AppTheme.successGreen,
    );
  }

  factory Badge.warning(String text) {
    return Badge(
      text: text,
      backgroundColor: AppTheme.warningOrange.withOpacity(0.15),
      textColor: AppTheme.warningOrange,
    );
  }

  factory Badge.info(String text) {
    return Badge(
      text: text,
      backgroundColor: AppTheme.primaryPurple.withOpacity(0.15),
      textColor: AppTheme.primaryPurple,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontSize: 11,
            ),
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String? badge;
  final VoidCallback onTap;

  const QuickActionCard({
    Key? key,
    required this.icon,
    required this.title,
    this.badge,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppTheme.radiusLarge,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radiusLarge,
        child: SizedBox(
          width: 140,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (badge != null) ...[
                const SizedBox(height: 6),
                Badge.warning(badge!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
