import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_duration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../controllers/splash_controller.dart';

/// Splash de Stitch: gradiente indigo a pantalla completa, logo circular
/// blanco con anillo, nombre de la app y tagline.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });

    Future<void>(() async {
      await ref.read(splashControllerProvider).waitForBoot();
      final bool hasSession =
          await ref.read(splashControllerProvider).hasActiveSession();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        hasSession ? AppRouter.home : AppRouter.login,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                context.semantic.brandGradientStart,
                context.semantic.brandGradientEnd,
              ],
            ),
          ),
          child: SizedBox.expand(
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: AppDuration.splashIntro,
              curve: AppDuration.easeOut,
              child: AnimatedScale(
                scale: _visible ? 1 : 0.92,
                duration: AppDuration.splashIntro,
                curve: AppDuration.easeOut,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const _SplashLogo(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      AppStrings.appName,
                      style: context.text.headlineSmall?.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Padding(
                      padding: AppSpacing.pagePadding,
                      child: Text(
                        AppStrings.splashSubtitle,
                        textAlign: TextAlign.center,
                        style: context.text.bodySmall?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circulo blanco con anillo exterior, como el logo del splash de Stitch.
class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.onPrimary, width: 1.5),
      ),
      padding: const EdgeInsets.all(6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.onPrimary,
        ),
        child: Icon(
          Icons.family_restroom_rounded,
          size: 44,
          color: context.semantic.brandGradientEnd,
        ),
      ),
    );
  }
}
