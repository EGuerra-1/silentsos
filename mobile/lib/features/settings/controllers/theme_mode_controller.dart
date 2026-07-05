import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';

/// Estado global del modo de tema (sistema/claro/oscuro), persistido local.
final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>(
  (Ref ref) => ThemeModeController()..load(),
);

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system);

  /// Carga la preferencia guardada al iniciar la app.
  Future<void> load() async {
    state = _decode(await StorageService.getThemeMode());
  }

  /// Cambia y persiste el modo seleccionado.
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await StorageService.saveThemeMode(_encode(mode));
  }

  ThemeMode _decode(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}
