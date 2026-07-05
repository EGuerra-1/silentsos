import '../../../core/exceptions/app_exception.dart';
import '../../../core/services/storage_service.dart';
import '../models/emergency_contact_model.dart';
import '../models/user_profile_model.dart';
import '../repositories/profile_repository.dart';

class ProfileService {
  const ProfileService(this._repository);

  final ProfileRepository _repository;

  Future<UserProfileModel> getCurrentUserProfile() async {
    final String? userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) {
      throw const AppException('No hay sesion activa.');
    }
    return _repository.getUserById(userId);
  }

  Future<UserProfileModel> updateCurrentUserProfile({
    required String fullName,
    required String email,
    required String cellphone,
    String? password,
  }) async {
    final String? userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) {
      throw const AppException('No hay sesion activa.');
    }

    final UserProfileModel updated = await _repository.updateUser(
      userId: userId,
      fullName: fullName.trim(),
      email: email.trim(),
      cellphone: cellphone.trim(),
      password: password?.trim().isEmpty == true ? null : password?.trim(),
    );

    await StorageService.updateUserProfile(
      userName: updated.fullName,
      userEmail: updated.email,
      userCellphone: updated.cellphone,
    );

    return updated;
  }

  Future<EmergencyContactModel?> getEmergencyContact() async {
    final List<EmergencyContactModel> contacts =
        await _repository.getEmergencyContacts();
    if (contacts.isEmpty) return null;
    return contacts.first;
  }

  Future<EmergencyContactModel> updateEmergencyContact({
    required String id,
    required String fullName,
    required String cellphone,
    required String relationship,
  }) =>
      _repository.updateEmergencyContact(
        id: id,
        fullName: fullName.trim(),
        cellphone: cellphone.trim(),
        relationship: relationship.trim(),
      );
}
