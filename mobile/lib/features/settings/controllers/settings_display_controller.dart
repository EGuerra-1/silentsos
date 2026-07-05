import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../models/emergency_contact_model.dart';
import '../models/user_profile_model.dart';
import '../services/profile_service.dart';

/// Datos basicos del usuario en sesion, leidos del almacenamiento seguro.
class SessionUser {
  const SessionUser({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;

  /// Inicial para el avatar (fallback "S" de SilentSOS).
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'S';

  factory SessionUser.fromProfile(UserProfileModel profile) {
    return SessionUser(
      name: profile.fullName,
      email: profile.email,
      role: profile.role,
    );
  }
}

/// Snapshot de perfil + contacto mostrado en Ajustes.
class SettingsDisplayData {
  const SettingsDisplayData({
    required this.profile,
    this.emergencyContact,
  });

  final UserProfileModel profile;
  final EmergencyContactModel? emergencyContact;

  SessionUser get sessionUser => SessionUser.fromProfile(profile);

  SettingsDisplayData copyWith({
    UserProfileModel? profile,
    EmergencyContactModel? emergencyContact,
    bool clearEmergencyContact = false,
  }) {
    return SettingsDisplayData(
      profile: profile ?? this.profile,
      emergencyContact: clearEmergencyContact
          ? null
          : emergencyContact ?? this.emergencyContact,
    );
  }
}

/// Estado compartido de Ajustes con actualizacion optimista tras editar.
class SettingsDisplayController
    extends StateNotifier<AsyncValue<SettingsDisplayData>> {
  SettingsDisplayController(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final ProfileService _service;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<SettingsDisplayData>(() async {
      final UserProfileModel profile = await _service.getCurrentUserProfile();
      final EmergencyContactModel? contact =
          await _service.getEmergencyContact();
      return SettingsDisplayData(
        profile: profile,
        emergencyContact: contact,
      );
    });
  }

  Future<void> applyProfile(UserProfileModel profile) async {
    await StorageService.updateUserProfile(
      userName: profile.fullName,
      userEmail: profile.email,
      userCellphone: profile.cellphone,
    );

    final SettingsDisplayData? current = state.valueOrNull;
    state = AsyncValue.data(
      (current ?? SettingsDisplayData(profile: profile)).copyWith(
        profile: profile,
      ),
    );
  }

  void applyEmergencyContact(EmergencyContactModel contact) {
    final SettingsDisplayData? current = state.valueOrNull;
    if (current == null) {
      state = AsyncValue.data(
        SettingsDisplayData(
          profile: UserProfileModel(
            id: contact.userId,
            fullName: '',
            email: '',
            cellphone: '',
            role: 'user',
          ),
          emergencyContact: contact,
        ),
      );
      return;
    }

    state = AsyncValue.data(
      current.copyWith(emergencyContact: contact),
    );
  }
}

class SessionController {
  Future<void> logout() => StorageService.clear();
}
