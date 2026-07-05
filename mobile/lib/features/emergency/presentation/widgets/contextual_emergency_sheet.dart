import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controllers/emergency_controller.dart';
import '../../models/emergency_model.dart';
import '../../providers/emergency_provider.dart';
import '../../services/contextual_image_picker.dart';
import 'contextual_photo_preview_row.dart';

/// Sheet de confirmacion tras capturar ambas fotos automaticamente.
class ContextualEmergencySheet extends ConsumerStatefulWidget {
  const ContextualEmergencySheet({
    super.key,
    required this.capture,
    required this.onRetake,
  });

  final ContextualImageCaptureResult capture;
  final VoidCallback onRetake;

  @override
  ConsumerState<ContextualEmergencySheet> createState() =>
      _ContextualEmergencySheetState();
}

class _ContextualEmergencySheetState
    extends ConsumerState<ContextualEmergencySheet> {
  final TextEditingController _contextCtrl = TextEditingController();

  @override
  void dispose() {
    _contextCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final EmergencyFlowState flow = ref.read(emergencyControllerProvider);
    if (flow.isBusy) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: Icon(Icons.photo_camera_rounded, color: context.colors.primary),
          title: const Text(AppStrings.emergencyContextConfirmTitle),
          content: const Text(AppStrings.emergencyContextConfirmBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(AppStrings.settingsCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(AppStrings.emergencyContextConfirmAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await ref.read(emergencyControllerProvider.notifier).triggerContextual(
          ContextualEmergencyPayload(
            frontImagePath: widget.capture.frontImagePath,
            backImagePath: widget.capture.backImagePath,
            contextText: _contextCtrl.text.trim().isEmpty
                ? null
                : _contextCtrl.text.trim(),
          ),
        );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final EmergencyFlowState flow = ref.watch(emergencyControllerProvider);
    final ColorScheme colors = context.colors;
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _SheetHeader(colors: colors),
                      const SizedBox(height: AppSpacing.lg),
                      ContextualPhotoPreviewRow(
                        frontImagePath: widget.capture.frontImagePath,
                        backImagePath: widget.capture.backImagePath,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.45,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.sm,
                            AppSpacing.xs,
                            AppSpacing.sm,
                            AppSpacing.sm,
                          ),
                          child: AppTextField(
                            controller: _contextCtrl,
                            label: AppStrings.emergencyContextTextLabel,
                            hint: AppStrings.emergencyContextTextHint,
                            maxLines: 3,
                            maxLength: 5000,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(
                    top: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppButton(
                      label: AppStrings.emergencyContextSubmit,
                      trailingIcon: Icons.emergency_share_rounded,
                      isLoading: flow.isBusy,
                      onPressed: flow.isBusy ? null : _submit,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    TextButton.icon(
                      onPressed: flow.isBusy
                          ? null
                          : () {
                              Navigator.pop(context);
                              widget.onRetake();
                            },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(AppStrings.emergencyContextRetake),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: colors.primary,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.emergencyContextSheetTitle,
                style: context.text.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                AppStrings.emergencyContextSheetSubtitle,
                style: context.text.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
