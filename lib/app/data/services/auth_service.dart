import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';

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
  
  /// Track if the user has snoozed the password reminder
  final RxBool hasSnoozedPasswordReminder = false.obs;

  bool get isLoggedIn => currentUser.value != null;
  bool get isOnboarded => currentUser.value?.isOnboarded ?? false;

  /// Fungsi inisialisasi yang bisa ditunggu (await) di main.dart
  Future<AuthService> init() async {
    await _restoreSession();
    return this;
  }

  /// Restore sesi dari storage saat app dibuka ulang.
  Future<void> _restoreSession() async {
    final userJson = await _storage.read(key: _userKey);
    print("DEBUG: Memulihkan sesi user. Data ditemukan: ${userJson != null}");
    
    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        currentUser.value = UserModel.fromJson(userData);
        print("DEBUG: Sesi berhasil dipulihkan untuk: ${currentUser.value?.email}");
        
        // Restore snooze state specific to this user
        if (currentUser.value?.id != null) {
          final snoozeKey = 'snooze_password_${currentUser.value!.id}';
          final snoozeVal = await _storage.read(key: snoozeKey);
          hasSnoozedPasswordReminder.value = snoozeVal == 'true';
        }
      } catch (e) {
        print("DEBUG: Gagal decode user data: $e");
        await clearSession();
      }
    }
  }

  /// Simpan token JWT ke secure storage.
  Future<void> saveToken(String token) async {
    print("DEBUG: Menyimpan token baru.");
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Simpan data user ke secure storage dan update observable.
  Future<void> saveUser(UserModel user) async {
    print("DEBUG: Menyimpan data user: ${user.email}");
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    currentUser.value = user;
    print("DEBUG: Data user tersimpan di memory.");
  }

  /// Ambil token dari secure storage.
  Future<String?> getToken() => _storage.read(key: _tokenKey);

  /// Snooze password reminder
  Future<void> snoozePasswordReminder() async {
    final userId = currentUser.value?.id;
    if (userId != null) {
      hasSnoozedPasswordReminder.value = true;
      await _storage.write(key: 'snooze_password_$userId', value: 'true');
    }
  }

  /// Clear snooze password reminder
  Future<void> clearSnoozePasswordReminder() async {
    final userId = currentUser.value?.id;
    if (userId != null) {
      hasSnoozedPasswordReminder.value = false;
      await _storage.delete(key: 'snooze_password_$userId');
    }
  }

  /// Hapus semua data sesi.
  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    // don't delete snooze states here so they persist, or delete them if needed. 
    // It's fine to leave them since they are keyed by user ID.
    currentUser.value = null;
    hasSnoozedPasswordReminder.value = false;
  }

  /// Logout — hapus sesi dan redirect ke login.
  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await clearSession();
    Get.offAllNamed(Routes.LOGIN);
  }
}
