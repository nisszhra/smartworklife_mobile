import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF9F9FF);
    const Color textDark = Color(0xFF181C22);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Kebijakan Privasi & Ketentuan',
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
              'Kebijakan Privasi Smart WorkLife',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terakhir diperbarui: Juni 2026',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '1. Pengumpulan Informasi',
              content:
                  'Kami mengumpulkan informasi profil dasar Anda (seperti nama, usia, jenis kelamin, berat, dan tinggi badan) serta data preferensi kerja (seperti jam mulai & selesai kerja) untuk mempersonalisasi fitur asisten kerja dan rekomendasi kesehatan Anda.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '2. Pemrosesan Data Suara & Transkrip',
              content:
                  'Untuk fitur Smart Notulen, rekaman audio dan transkripsi teks Anda diproses secara aman. Kami berkomitmen untuk menjaga data audio dan transkrip hasil rekaman tetap privat dan hanya dapat diakses oleh pemilik akun.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '3. Data Kesehatan & Aktivitas fisik',
              content:
                  'Data mengenai sesi Pomodoro, aktivitas peregangan tubuh (Stretching), dan jumlah asupan air harian disimpan untuk menyajikan laporan analitik performa kerja Anda dari hari ke hari.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '4. Keamanan Informasi',
              content:
                  'Kami menerapkan standar keamanan enkripsi data guna melindungi kredensial akun dan data pribadi Anda dari akses yang tidak sah, penyalahgunaan, atau kebocoran data.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '5. Penghapusan Akun',
              content:
                  'Apabila Anda memilih untuk menghapus akun melalui menu Akun & Keamanan, seluruh data personal, transkrip rekaman, serta histori aktivitas Anda akan dihapus secara permanen dari basis data kami dan tidak dapat dikembalikan.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181C22),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
