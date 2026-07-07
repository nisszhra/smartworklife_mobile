import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/translation_service.dart';

class LanguageView extends StatefulWidget {
  const LanguageView({super.key});

  @override
  State<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  // Baca langsung dari Get.locale - sinkronus, selalu akurat, tanpa async
  late String _selectedLang;

  @override
  void initState() {
    super.initState();
    _selectedLang = Get.locale?.languageCode ?? 'en';
  }

  Future<void> _selectLanguage(String langCode) async {
    setState(() {
      _selectedLang = langCode;
    });
    await TranslationService.saveLocale(langCode);
  }

  Future<void> _continue() async {
    await TranslationService.applyLocale(_selectedLang);

    final bool isFromSettings = Get.arguments?['fromSettings'] ?? false;
    if (!isFromSettings) {
      Get.offAllNamed('/onboarding');
    }
    // Jika dari settings: tetap di halaman ini, tidak navigasi ke mana-mana
  }

  @override
  Widget build(BuildContext context) {
    final bool isFromSettings = Get.arguments?['fromSettings'] ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isFromSettings
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Get.back(),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/images/logo_polos_smartworklife.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.language, size: 100, color: Color(0xFF005AB4)),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'select_language'.tr,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005AB4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'choose_your_language'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildOption(title: 'english'.tr, langCode: 'en', flag: '🇬🇧'),
              const SizedBox(height: 16),
              _buildOption(title: 'indonesian'.tr, langCode: 'id', flag: '🇮🇩'),
              const Spacer(),
              ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005AB4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'continue'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({required String title, required String langCode, required String flag}) {
    final bool isSelected = _selectedLang == langCode;
    return GestureDetector(
      onTap: () => _selectLanguage(langCode),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF005AB4).withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF005AB4) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF005AB4) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF005AB4)),
          ],
        ),
      ),
    );
  }
}
