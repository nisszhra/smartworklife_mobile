import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;

    const Color primary = Color(0xFF005AB4);
    const Color background = Color(0xFFF9F9FF);
    const Color surface = Colors.white;
    const Color onSurface = Color(0xFF181C22);
    const Color onSurfaceVariant = Color(0xFF414753);
    const Color outline = Color(0xFFC1C6D5);

    return Scaffold(
      backgroundColor: background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
        child: Column(
          children: [
            // Persistent Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Left: Back Button (Only on Step 2)
                      Obx(() => ctrl.currentPage.value > 0
                          ? IconButton(
                              onPressed: ctrl.previous,
                              icon: const Icon(Icons.arrow_back, color: onSurfaceVariant),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          : const SizedBox(width: 48)), // Maintain spacing if hidden
                      
                      // Right: Step Label & Progress segments
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Obx(() => Text(
                            'Step ${ctrl.currentPage.value + 1} of 2',
                            style: TextStyle(color: onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600),
                          )),
                          const SizedBox(height: 8),
                          Obx(() => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Segment 1
                              Container(
                                width: 32,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: ctrl.currentPage.value >= 0 ? primary : outline.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Segment 2
                              Container(
                                width: 32,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: ctrl.currentPage.value >= 1 ? primary : outline.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: ctrl.pageController,
                onPageChanged: (index) => ctrl.currentPage.value = index,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildHealthProfile(context, primary, onSurface, onSurfaceVariant, outline, ctrl),
                  _buildWorkProfile(context, primary, onSurface, onSurfaceVariant, outline, ctrl),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHealthProfile(BuildContext context, Color primary, Color onSurface, Color onSurfaceVariant, Color outline, OnboardingController ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

            // Title
            Text(
              'Halo! Mari atur profil kesehatanmu.',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: onSurface, height: 1.2),
            ),
            const SizedBox(height: 12),
            Text(
              'Informasi ini akan membantu kami mempersonalisasi rencana kesehatan Anda.',
              style: TextStyle(fontSize: 16, color: onSurfaceVariant),
            ),
            const SizedBox(height: 32),

            // Name
            Text('Nama Pengguna', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
            const SizedBox(height: 8),
            Obx(() => TextFormField(
              controller: ctrl.nameController,
              focusNode: ctrl.nameFocusNode,
              readOnly: !ctrl.isEditingName.value,
              decoration: InputDecoration(
                hintText: 'Masukkan nama pengguna',
                suffixIcon: IconButton(
                  icon: Icon(Icons.edit, color: ctrl.isEditingName.value ? primary : outline),
                  onPressed: () {
                    ctrl.isEditingName.value = true;
                    ctrl.nameFocusNode.requestFocus();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )),
            const SizedBox(height: 24),

            // Gender
            Text('Jenis Kelamin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(() => _GenderCard(
                    label: 'Laki-laki',
                    icon: Icons.male,
                    isSelected: ctrl.selectedGender.value == 'Laki-laki',
                    onTap: () => ctrl.selectedGender.value = 'Laki-laki',
                    primary: primary,
                    outline: outline,
                  )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => _GenderCard(
                    label: 'Perempuan',
                    icon: Icons.female,
                    isSelected: ctrl.selectedGender.value == 'Perempuan',
                    onTap: () => ctrl.selectedGender.value = 'Perempuan',
                    primary: primary,
                    outline: outline,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Age
            Text('Usia', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
            const SizedBox(height: 8),
            TextFormField(
              controller: ctrl.ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan usia',
                suffixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Text('Tahun', style: TextStyle(color: onSurfaceVariant)),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Weight & Height
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Berat Badan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: ctrl.weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '00',
                          suffixText: 'kg',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tinggi Badan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: ctrl.heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '000',
                          suffixText: 'cm',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Data Anda dienkripsi secara aman dan hanya digunakan untuk menghitung metrik kesehatan dasar.',
                      style: TextStyle(fontSize: 12, color: onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ctrl.next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lanjutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkProfile(BuildContext context, Color primary, Color onSurface, Color onSurfaceVariant, Color outline, OnboardingController ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

            // Title
            Text(
              'Berapa jam biasanya kamu bekerja?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: onSurface, height: 1.2),
            ),
            const SizedBox(height: 12),
            Text(
              'Informasi ini membantu kami menyesuaikan jadwal kesehatan dan produktivitas harianmu.',
              style: TextStyle(fontSize: 16, color: onSurfaceVariant),
            ),
            const SizedBox(height: 40),

            // Work Hours
            Text('JAM KERJA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: onSurfaceVariant, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: outline.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ctrl.selectStartTime(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mulai', style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                            ctrl.startTime.value,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primary),
                          )),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 40, width: 1, color: outline.withOpacity(0.3)),
                  const SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ctrl.selectEndTime(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selesai', style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                            ctrl.endTime.value,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primary),
                          )),
                        ],
                      ),
                    ),
                  ),
                  Icon(Icons.access_time, color: outline),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Industry
            Text('DI BIDANG APA KAMU BEKERJA?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: onSurfaceVariant, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
              value: ctrl.selectedIndustry.value.isEmpty ? null : ctrl.selectedIndustry.value,
              decoration: InputDecoration(
                hintText: 'Pilih Bidang Pekerjaan',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outline.withOpacity(0.5))),
              ),
              items: ctrl.industries.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => ctrl.selectedIndustry.value = value ?? '',
            )),
            Obx(() {
              if (ctrl.selectedIndustry.value == 'Lainnya') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: ctrl.otherIndustryController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan bidang pekerjaan',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outline.withOpacity(0.5))),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 32),

            // Tip Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Tahukah kamu? Orang yang bekerja di bidang kreatif cenderung lebih produktif dengan istirahat 15 menit setiap 2 jam.',
                      style: TextStyle(fontSize: 14, color: onSurfaceVariant, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ctrl.next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Selesai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Dengan menekan Selesai, kamu menyetujui pengaturan profil kerja ini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primary;
  final Color outline;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.primary,
    required this.outline,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : outline.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: isSelected ? primary : outline),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primary : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
