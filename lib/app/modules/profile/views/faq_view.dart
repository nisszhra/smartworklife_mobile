import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaqView extends StatelessWidget {
  const FaqView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF9F9FF);
    const Color primary = Color(0xFF005AB4);
    const Color textDark = Color(0xFF181C22);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Panduan & FAQ',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panduan Penggunaan Fitur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildGuideCard(
              icon: Icons.mic_none_outlined,
              title: 'Smart Notulen',
              description:
                  'Gunakan Smart Notulen untuk merekam & mentranskrip rapat secara otomatis dengan AI. Anda juga dapat menyunting draf notulen dan menyimpannya sebagai arsip digital.',
            ),
            const SizedBox(height: 12),
            _buildGuideCard(
              icon: Icons.timer_outlined,
              title: 'Pomodoro Timer',
              description:
                  'Tingkatkan produktivitas kerja Anda dengan Pomodoro Timer. Atur waktu fokus bekerja/belajar serta waktu istirahat singkat dan panjang secara teratur.',
            ),
            const SizedBox(height: 12),
            _buildGuideCard(
              icon: Icons.fitbit_outlined,
              title: 'Stretching & Hidrasi',
              description:
                  'Jaga kebugaran fisik Anda selama bekerja dengan mengikuti panduan peregangan otot (Stretching) dan pantau target hidrasi asupan air harian Anda.',
            ),
            const SizedBox(height: 32),
            const Text(
              'Pertanyaan Umum (FAQ)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqTile(
              question: 'Apakah hasil transkripsi rapat 100% akurat?',
              answer:
                  'Akurasi transkripsi otomatis dipengaruhi oleh kualitas rekaman audio dan kejelasan ucapan peserta rapat. Anda dapat menyunting kembali teks hasil transkrip draf sebelum disimpan.',
            ),
            const Divider(height: 24, color: Color(0xFFE2E8F0)),
            _buildFaqTile(
              question: 'Bagaimana cara mengubah profil personal saya?',
              answer:
                  'Buka menu Edit Profil pada halaman profil, isi informasi yang ingin diubah (seperti nama, usia, berat badan, dsb), lalu tekan tombol "Save Changes" di bagian bawah.',
            ),
            const Divider(height: 24, color: Color(0xFFE2E8F0)),
            _buildFaqTile(
              question: 'Bagaimana cara mengganti kata sandi akun saya?',
              answer:
                  'Pilih menu "Akun & Keamanan" di halaman pengaturan profil. Anda dapat memasukkan kata sandi lama dan baru, atau menggunakan tautan "Lupa Password?" jika lupa sandi Anda saat ini.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC1C6D5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF005AB4), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181C22),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile({
    required String question,
    required String answer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181C22),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
