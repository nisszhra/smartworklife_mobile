import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/models/user_model.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';

class AuthService extends GetxService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Observable current user — null jika belum login.
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  bool get isLoggedIn => currentUser.value != null;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _restoreSession();
  }

  /// Restore sesi dari storage saat app dibuka ulang.
  Future<void> _restoreSession() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      try {
        currentUser.value = UserModel.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>,
        );
      } catch (_) {
        await clearSession();
      }
    }
  }

  /// Simpan token JWT ke secure storage.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Simpan data user ke secure storage dan update observable.
  Future<void> saveUser(UserModel user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    currentUser.value = user;
  }

  /// Ambil token dari secure storage.
  Future<String?> getToken() => _storage.read(key: _tokenKey);

  /// Hapus semua data sesi.
  Future<void> clearSession() async {
    await _storage.deleteAll();
    currentUser.value = null;
  }

  /// Logout — hapus sesi dan redirect ke login.
  Future<void> logout() async {
    await clearSession();
    Get.offAllNamed(Routes.LOGIN);
  }
}
