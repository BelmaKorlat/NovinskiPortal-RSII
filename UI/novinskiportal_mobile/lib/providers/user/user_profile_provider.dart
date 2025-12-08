import 'package:flutter/foundation.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';
import 'package:novinskiportal_mobile/models/user/user_models.dart';
import 'package:novinskiportal_mobile/services/user_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserService _service = UserService();

  UserDto? _user;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  String? _error;

  UserDto? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isChangingPassword => _isChangingPassword;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getProfile();
      _user = result;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Greška pri učitavanju profila.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final req = UpdateProfileRequest(
        firstName: firstName,
        lastName: lastName,
        username: username,
      );

      final updated = await _service.updateProfile(req);
      _user = updated;

      _isSaving = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isSaving = false;
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _isSaving = false;
      _error = 'Greška pri čuvanju profila.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    _isChangingPassword = true;
    _error = null;
    notifyListeners();

    try {
      final req = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );

      await _service.changePassword(req);

      _isChangingPassword = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isChangingPassword = false;
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _isChangingPassword = false;
      _error = 'Greška pri promjeni lozinke.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
