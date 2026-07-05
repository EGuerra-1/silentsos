import '../datasource/profile_remote_datasource.dart';
import '../models/emergency_contact_model.dart';
import '../models/user_profile_model.dart';

class ProfileRepository {
  const ProfileRepository(this._remote);

  final ProfileRemoteDataSource _remote;

  Future<UserProfileModel> getUserById(String userId) =>
      _remote.fetchUserById(userId);

  Future<UserProfileModel> updateUser({
    required String userId,
    String? fullName,
    String? email,
    String? cellphone,
    String? password,
  }) =>
      _remote.updateUser(
        userId: userId,
        fullName: fullName,
        email: email,
        cellphone: cellphone,
        password: password,
      );

  Future<List<EmergencyContactModel>> getEmergencyContacts() =>
      _remote.fetchEmergencyContacts();

  Future<EmergencyContactModel> updateEmergencyContact({
    required String id,
    String? fullName,
    String? cellphone,
    String? relationship,
  }) =>
      _remote.updateEmergencyContact(
        id: id,
        fullName: fullName,
        cellphone: cellphone,
        relationship: relationship,
      );
}
