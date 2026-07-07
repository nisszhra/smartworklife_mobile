import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_translations.dart';

class TranslationService extends Translations {
  static const fallbackLocale = Locale('en', 'US');
  static const String _langKey = 'selected_language';

  // Read saved locale from storage, otherwise return English default
  static Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_langKey);
    if (savedLang != null && (savedLang == 'id' || savedLang.startsWith('id') || savedLang.startsWith('in'))) {
      return const Locale('id', 'ID');
    }
    // Default to English on fresh install
    return const Locale('en', 'US');
  }

  // Change locale and save it (all-in-one)
  static Future<void> changeLocale(String langCode) async {
    await saveLocale(langCode);
    await applyLocale(langCode);
  }

  // Only save locale to storage (without applying)
  static Future<void> saveLocale(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, langCode);
  }

  // Only apply locale (without saving)
  static Future<void> applyLocale(String langCode) async {
    final locale = langCode == 'id' ? const Locale('id', 'ID') : const Locale('en', 'US');
    Get.updateLocale(locale);
  }

  // Check if language has been selected before (for splash screen logic)
  static Future<bool> hasSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_langKey);
  }

  @override
  Map<String, Map<String, String>> get keys => AppTranslations.keys;
}
