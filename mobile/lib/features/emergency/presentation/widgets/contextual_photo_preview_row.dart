import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Vista previa compacta de las dos fotos capturadas.
class ContextualPhotoPreviewRow extends StatelessWidget {
  const ContextualPhotoPreviewRow({
    super.key,
    required this.frontImagePath,
    required this.backImagePath,
  });

  final String frontImagePath;
  final String backImagePath;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _PreviewTile(
            label: AppStrings.emergencyContextBackTitle,
            icon: Icons.photo_camera_back_rounded,
            imagePath: backImagePath,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _PreviewTile(
            label: AppStrings.emergencyContextFrontTitle,
            icon: Icons.face_retouching_natural_rounded,
            imagePath: frontImagePath,
          ),
        ),
      ],
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.label,
    required this.icon,
    required this.imagePath,
  });

  final String label;
  final IconData icon;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 4 / 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.55),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg - 1),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.file(File(imagePath), fit: BoxFit.cover),
                  Positioned(
                    left: AppSpacing.xs,
                    top: AppSpacing.xs,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(icon, size: 12, color: colors.primary),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.emergencyContextPhotoReady,
                              style: context.text.labelSmall?.copyWith(
                                color: colors.onSurface,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: context.text.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
