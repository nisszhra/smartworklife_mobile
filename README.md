# 💼 Smart-WorkLife Mobile

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![GetX](https://img.shields.io/badge/State_Management-GetX_4.7.3-purple.svg?style=for-the-badge)](https://pub.dev/packages/get)
[![AI Powered](https://img.shields.io/badge/AI-ML_Kit_Pose_Detection-orange.svg?style=for-the-badge)](https://developers.google.com/ml-kit)

**Smart-WorkLife Mobile** adalah aplikasi asisten digital keseimbangan hidup dan produktivitas kerja (*work-life balance*) bertenaga kecerdasan buatan (AI). Aplikasi ini dirancang khusus untuk membantu pekerja profesional dan pengembang menjaga kesehatan fisik dan mental serta efektivitas waktu kerja sehari-hari secara seimbang melalui platform mobile yang premium, interaktif, dan responsif.

---

## 🚀 Fitur Utama Aplikasi

### 🤖 1. Pelacak Peregangan AI (*Stretching Tracker*)
Modul cerdas yang memantau gerakan peregangan tubuh secara real-time untuk mengurangi kekakuan otot akibat duduk terlalu lama:
* **Deteksi Pose AI:** Menggunakan *Google ML Kit Pose Detection* melalui kamera depan untuk mengenali sendi tubuh secara akurat.
* **Analisis Gerakan Aktif:**
  * **Neck Tilt (Peregangan Leher):** Mendeteksi gerakan memiringkan leher ke kiri/kanan secara bergantian secara sudut presisi.
  * **Shoulder Rolls (Putaran Bahu):** Mengukur rotasi dan jarak sendi bahu ke telinga untuk memastikan gerakan yang benar.
* **Real-time Feedback & Repetisi:** Memberikan arahan suara/teks real-time saat gerakan salah dan secara otomatis meningkatkan counter repetisi ketika gerakan benar selesai dilakukan (target default: 8 repetisi).
* **Desain Kamera Anti-Gepeng:** Tampilan kamera dioptimalkan dengan rasio aspek portrait murni (`FittedBox` + `ClipRect`) yang dinamis di berbagai layar HP tanpa distorsi.
* **Panel Glassmorphism:** Kontrol dan informasi gerakan didesain dengan efek kaca transparan premium (`BackdropFilter` & `blur`) untuk visual yang bersih dan modern.
* **Smart Completion:** Tombol "Selesai" hanya akan aktif secara dinamis ketika pengguna berhasil mencapai jumlah repetisi target.

### ⏱️ 2. Pengatur Waktu Pomodoro (*Pomodoro Timer*)
Meningkatkan fokus dan produktivitas melalui teknik manajemen waktu Pomodoro klasik:
* Durasi kerja terfokus (misalnya 25 menit) diselingi dengan istirahat singkat (misalnya 5 menit).
* Tampilan visual yang hidup dengan mikro-animasi transisi saat beroperasi.

### 📝 3. Manajemen Rapat & Klasifikasi Suara (*Notulen*)
Pencatatan notulensi rapat cerdas yang terintegrasi:
* **Audio Recording:** Perekaman audio rapat langsung dari perangkat.
* **Audio Classification (TFLite):** Klasifikasi audio pintar berbasis kecerdasan buatan untuk mengklasifikasikan rekaman secara real-time maupun *file-based*.

### 📅 4. Daftar Tugas Harian (*To-Do List*)
Manajer prioritas tugas harian terintegrasi untuk melacak pekerjaan, menandai tugas yang selesai, dan menyortir tugas berdasarkan skala prioritas harian.

### 🏥 5. Pemantauan Kesehatan & Notifikasi
* **Health Tracker:** Memantau metrik kesehatan penting pengguna.
* **Smart Notifications:** Mengingatkan pengguna untuk meregangkan tubuh, mengambil istirahat Pomodoro, atau minum air putih secara berkala.

---

## 🛠️ Tech Stack & Library Inti

Aplikasi ini dibangun menggunakan arsitektur modular modern berbasis Flutter dengan pustaka-pustaka andalan berikut:

| Kategori | Teknologi / Library | Versi | Deskripsi |
| :--- | :--- | :--- | :--- |
| **Framework** | **Flutter SDK** | `>=3.9.2` | Framework cross-platform utama |
| **State & Router** | [**GetX**](https://pub.dev/packages/get) | `^4.7.3` | State management reaktif, injeksi dependensi, dan navigasi |
| **Networking** | [**Dio**](https://pub.dev/packages/dio) | `^5.7.0` | HTTP Client tangguh untuk komunikasi dengan backend server |
| **Storage** | [**Flutter Secure Storage**](https://pub.dev/packages/flutter_secure_storage) | `^9.2.2` | Enkripsi kredensial & auth token secara aman di local device |
| **AI Pose** | [**ML Kit Pose Detection**](https://pub.dev/packages/google_mlkit_pose_detection) | `^0.14.1` | Pustaka Google ML Kit untuk mendeteksi kerangka sendi tubuh |
| **Camera Capture**| [**Camera**](https://pub.dev/packages/camera) | `^0.12.0+1` | Mengontrol akses preview dan streaming kamera |
| **Permissions** | [**Permission Handler**](https://pub.dev/packages/permission_handler) | `^12.0.1` | Manajemen izin sistem (Kamera, Mikrofon, Storage) |

---

## 📂 Struktur Direktori Proyek

Proyek ini menerapkan pola arsitektur **GetX Pattern** untuk menjaga pemisahan kode (*separation of concerns*) yang bersih dan modular:

```text
lib/
├── app/
│   ├── bindings/             # Binding global (misal: InitialBinding)
│   ├── data/                 # Data Layer terpusat
│   │   ├── models/           # Data Transfer Object (DTO) & Entitas model data
│   │   ├── providers/        # Koneksi langsung ke API (misal: AuthProvider)
│   │   ├── repositories/     # Abstraksi data (penghubung provider & controller)
│   │   └── services/         # Layanan jangka panjang (DioService, AuthService, UserService)
│   ├── modules/              # Modul fitur berbasis MVC (Model-View-Controller)
│   │   ├── login/            # Modul Halaman Masuk
│   │   ├── signup/           # Modul Pendaftaran Akun
│   │   ├── main/             # Shell Navigasi Utama (BottomNavigationBar & Central AppBar)
│   │   ├── home/             # Beranda Utama Dashboard
│   │   ├── stretching/       # Fitur Peregangan Tubuh AI (View, Controller, Binding)
│   │   ├── pomodoro/         # Halaman Timer Pomodoro
│   │   ├── todolist/         # Modul Daftar Tugas Harian
│   │   ├── notulen/          # Pencatatan Rapat & Klasifikasi Suara
│   │   └── verifikasi/       # Modul Kode Verifikasi OTP
│   └── routes/               # Manajemen Routing Aplikasi
│       ├── app_pages.dart    # Daftar rute aktif & Bindings modul rute
│       └── app_routes.dart   # String konstanta rute (contoh: Routes.LOGIN)
└── main.dart                 # Titik masuk utama aplikasi (Inisialisasi Service & Startup Route)
```

---

## 🏃 Cara Menjalankan Proyek Secara Lokal

### 📋 Prasyarat
1. **Flutter SDK** versi `>= 3.9.2` telah terpasang di komputer Anda.
2. Gunakan perangkat seluler fisik (Android atau iOS) untuk pengetesan modul kamera AI (*ML Kit Pose Detection* tidak direkomendasikan pada emulator biasa).
3. Pastikan port server backend aktif dan dapat diakses.

### ⚙️ Langkah Pemasangan
1. **Klon Repositori:**
   ```bash
   git clone https://github.com/username/worklife_mobile.git
   cd worklife_mobile
   ```

2. **Unduh Dependensi:**
   Unduh paket pustaka yang dideklarasikan di `pubspec.yaml`:
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Alamat API Backend:**
   Buka file layanan jaringan [dio_service.dart](file:///d:/SEMESTER%206/Capstone/worklife_mobile/lib/app/data/services/dio_service.dart) dan sesuaikan properti alamat IP komputer lokal / server backend Anda (`_baseUrl`).

4. **Jalankan Aplikasi:**
   Koneksikan perangkat HP fisik Anda, nyalakan *USB Debugging*, lalu jalankan perintah:
   ```bash
   flutter run
   ```

---

## 🧪 Analisis & Standar Kualitas Kode
Untuk menjaga kualitas kode dan memastikan tidak ada error kompilasi, Anda dapat menjalankan analisis kode statis Flutter bawaan secara mandiri melalui terminal:
```bash
flutter analyze
```
Proyek ini mengadopsi lint `flutter_lints` untuk memastikan penulisan kode Dart mengikuti praktik terbaik dari Google Team.

---
*Dibuat dengan penuh ❤️ sebagai proyek Capstone berkualitas tinggi untuk keseimbangan kerja profesional.*
