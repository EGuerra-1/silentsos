import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final userProfileProvider = FutureProvider.autoDispose<UserProfileModel>(
  (Ref ref) => ref.watch(profileServiceProvider).getCurrentUserProfile(),
);

final emergencyContactProvider =
    FutureProvider.autoDispose<EmergencyContactModel?>(
  (Ref ref) => ref.watch(profileServiceProvider).getEmergencyContact(),
);
