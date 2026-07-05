import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_display_controller.dart';
import '../datasource/profile_remote_datasource.dart';
import '../models/emergency_contact_model.dart';
import '../models/user_profile_model.dart';
import '../repositories/profile_repository.dart';
import '../services/profile_service.dart';

final profileRemoteProvider = Provider<ProfileRemoteDataSource>(
  (Ref ref) => ProfileRemoteDataSource(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (Ref ref) => ProfileRepository(ref.watch(profileRemoteProvider)),
);

final profileServiceProvider = Provider<ProfileService>(
  (Ref ref) => ProfileService(ref.watch(profileRepositoryProvider)),
);

final settingsDisplayProvider = StateNotifierProvider<
    SettingsDisplayController, AsyncValue<SettingsDisplayData>>(
  (Ref ref) => SettingsDisplayController(ref.watch(profileServiceProvider)),
);

final sessionUserProvider = Provider<AsyncValue<SessionUser>>((Ref ref) {
  final AsyncValue<SettingsDisplayData> display =
      ref.watch(settingsDisplayProvider);
  return display.whenData((SettingsDisplayData data) => data.sessionUser);
});

final sessionControllerProvider = Provider<SessionController>(
  (Ref ref) => SessionController(),
);

final userProfileProvider = FutureProvider<UserProfileModel>(
  (Ref ref) => ref.watch(profileServiceProvider).getCurrentUserProfile(),
);

final emergencyContactProvider = FutureProvider<EmergencyContactModel?>(
  (Ref ref) => ref.watch(profileServiceProvider).getEmergencyContact(),
);
