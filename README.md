# Welcome to Suis-Project 🎨🤖

Selamat datang di **Suis-Project**, sebuah project full-stack yang menggabungkan aplikasi mobile **Android** (berbasis Flutter) dengan backend AI canggih (Node.js). Project ini dirancang dengan estetika **Pixel Art** yang unik untuk memberikan pengalaman interaksi asisten virtual yang futuristik namun tetap bernuansa retro.

---

## 📂 Struktur Project

```text
suis-ai/
├── virtual_projek/      # Frontend Aplikasi Mobile (Android - Flutter)
└── virtual_ai/          # Backend Service (TypeScript/Node.js + Fastify + Groq)
```

*   **`virtual_projek/`**: Aplikasi Android Flutter dengan visualisasi partikel pixel, soundwave real-time, dan sistem voice conversation.
*   **`virtual_ai/`**: Service backend yang menangani komunikasi dengan Groq Cloud API (otak AI) dan konversi teks-ke-suara menggunakan Edge TTS.

---

## ✨ Fitur Utama

*   **Antarmuka Pixel-Art Premium**: Visual retro-futuristik yang dikurasi dengan cermat untuk platform Android.
*   **Real-time Voice Assistant**: Interaksi suara dua arah hands-free otomatis.
*   **Pixel Particle & Soundwave Visualizer**: Efek partikel dan soundwave dinamis yang merespons irama suara asisten secara real-time.
*   **Multi-Model Engine**: Dukungan pergantian model AI (Queen, GPT, Claude) dengan deskripsi unik.
*   **Dual Mode Theme**: Mode gelap (Dark Mode) dan terang dengan palet warna yang nyaman di mata.

---

## 🛠️ Prasyarat & Setup PC Pengembang (Windows, Linux, macOS)

Aplikasi target akhir kita adalah **Android**. Namun, kamu bisa menggunakan komputer pengembang dengan sistem operasi **Windows**, **Linux**, atau **macOS** untuk menulis kode dan melakukan debugging.

### Langkah Awal (Semua OS)
Pastikan PC kamu sudah memiliki perkakas dasar berikut:
*   **Flutter SDK** (v3.19.x ke atas) -> [Panduan Instalasi Flutter](https://docs.flutter.dev/get-started/install)
*   **Node.js** (v18 ke atas) & **npm** -> [Unduh Node.js](https://nodejs.org/)
*   **Git** -> [Unduh Git](https://git-scm.com/)
*   **Android Studio** -> [Unduh Android Studio](https://developer.android.com/studio) (Diperlukan untuk mendapatkan Android SDK, Emulator, dan Java Development Kit / JDK).

---

### 1. Setup Backend (`virtual_ai`) pada PC Pengembang
Backend berjalan di PC kamu (baik di Windows, Linux, maupun macOS) sebagai server lokal.

1.  Masuk ke direktori backend:
    ```bash
    cd virtual_ai
    ```
2.  Instal dependensi:
    ```bash
    npm install
    ```
3.  Salin file konfigurasi env:
    ```bash
    cp .env.example .env
    ```
4.  Buka file `.env` dan masukkan API Key Groq kamu:
    ```env
    GROQ_API_KEY=gsk_IsiDenganApiKeyGroqKamu
    PORT=3000
    DEFAULT_MODEL=llama-3.3-70b-versatile
    ```
5.  Jalankan server backend:
    ```bash
    npm run dev
    ```
    > [!NOTE]
    > Backend akan aktif di `http://localhost:3000` pada PC kamu.

---

### 2. Setup Lingkungan Android pada PC Pengembang (Windows / Linux / macOS)

Sebelum mem-build aplikasi Android, pastikan SDK Android dikonfigurasi dengan benar di PC kamu:

#### 🪟 Jika PC kamu menggunakan Windows:
1.  Buka Android Studio -> **SDK Manager**. Instal **Android SDK Command-line Tools** dan **Android Emulator**.
2.  Pastikan opsi **Hardware Virtualization** (Hyper-V atau Intel HAXM) aktif di BIOS PC kamu agar emulator berjalan cepat.
3.  Jalankan terminal dan verifikasi Android licenses:
    ```cmd
    flutter doctor --android-licenses
    ```

#### 🐧 Jika PC kamu menggunakan Linux:
1.  Instal library C++ dan dependensi build melalui terminal:
    ```bash
    sudo apt-get update
    sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
    ```
2.  Konfigurasikan **KVM (Kernel-based Virtual Machine)** agar Emulator Android berjalan sangat mulus:
    ```bash
    sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
    sudo adduser $USER kvm
    ```
3.  Setujui lisensi SDK Android:
    ```bash
    flutter doctor --android-licenses
    ```

#### 🍎 Jika PC kamu menggunakan macOS:
1.  Instal Xcode command line tools (opsional, tapi disarankan untuk kompabilitas perkakas):
    ```bash
    xcode-select --install
    ```
2.  Pastikan Android SDK terdeteksi di macOS. Setujui lisensi SDK Android:
    ```bash
    flutter doctor --android-licenses
    ```

---

## 📡 Konfigurasi Jaringan & Debugging Aplikasi Android (CRITICAL)

Karena aplikasi berjalan di perangkat Android (baik emulator maupun HP fisik) sedangkan backend berjalan di PC kamu, konfigurasi IP sangatlah krusial agar keduanya bisa saling terhubung.

### 1. Tabel Konfigurasi IP Backend di Flutter

Secara default, kode Flutter diatur menggunakan IP loopback emulator (`http://10.0.2.2:3000`). Sesuaikan alamat **`_backendUrl`** pada kode Flutter sebelum melakukan debug:

| Target Run/Debug | URL Backend Flutter | Penjelasan |
| :--- | :--- | :--- |
| **Android Emulator** | `http://10.0.2.2:3000` | IP loopback khusus agar emulator Android bisa mengakses localhost server di PC kamu. |
| **Handphone Fisik (Android)** | `http://<IP_PC_KAMU>:3000` | HP & PC harus berada di jaringan Wi-Fi yang sama agar HP bisa mengakses PC kamu lewat IP lokal. |

### 2. File yang Harus Diubah di Kode Flutter
Jika kamu mengganti target debugging, ubah nilai variabel `_backendUrl` pada 2 file berikut:

1.  **`virtual_projek/lib/providers/chat_provider.dart`** (Sekitar Baris 81)
    ```dart
    static const String _backendUrl = 'http://10.0.2.2:3000'; // Sesuaikan di sini!
    ```
2.  **`virtual_projek/lib/providers/va_provider.dart`** (Sekitar Baris 29)
    ```dart
    static const String _backendUrl = 'http://10.0.2.2:3000'; // Sesuaikan di sini!
    ```

---

## 📲 Panduan Lengkap Menjalankan & Debugging Aplikasi Android

### A. Menggunakan Android Emulator (AVD)

1.  Buka **Android Studio** -> **Device Manager** -> Klik tombol Play pada salah satu Virtual Device (Emulator) pilihanmu.
2.  Pastikan variabel `_backendUrl` di kode Flutter menggunakan default: `http://10.0.2.2:3000`.
3.  Masuk ke direktori frontend di terminal PC:
    ```bash
    cd virtual_projek
    flutter pub get
    ```
4.  Jalankan aplikasi ke emulator:
    ```bash
    flutter run
    ```
    *(Atau tekan tombol **Run/Debug** / `F5` langsung dari VS Code).*

---

### B. Menggunakan Handphone Fisik (Real Device) via Kabel USB

Menggunakan HP fisik sangat disarankan untuk menguji fitur Voice Assistant agar suara mikrofon lebih jernih dan responsif!

#### Langkah 1: Aktifkan Developer Options & USB Debugging di HP
1.  Buka **Settings (Pengaturan)** di HP Android kamu.
2.  Masuk ke **About Phone (Tentang Ponsel)** -> Cari **Build Number (Nomor Bentukan)**.
3.  **Ketuk Build Number sebanyak 7 kali** dengan cepat hingga muncul pesan *"Anda sekarang adalah pengembang!"*.
4.  Kembali ke menu utama Settings -> Masuk ke **Developer Options (Opsi Pengembang)**.
5.  Cari dan **Aktifkan USB Debugging**.

#### Langkah 2: Hubungkan HP & Pastikan Terbaca di PC
1.  Hubungkan HP ke PC menggunakan kabel data USB.
2.  Saat muncul pop-up otorisasi *"Izinkan debugging USB?"* di layar HP, centang **"Selalu izinkan dari komputer ini"** lalu ketuk **OK**.
3.  Verifikasi di terminal PC apakah HP sudah terbaca:
    ```bash
    flutter devices
    ```

#### Langkah 3: Koneksi Wi-Fi & Cari IP PC
1.  **WAJIB**: Hubungkan HP dan PC/Laptop kamu ke **jaringan Wi-Fi yang sama**.
2.  Cari tahu IP Address lokal PC kamu:
    *   **Windows**: Jalankan `ipconfig` di CMD (Cari `IPv4 Address` di adapter Wi-Fi).
    *   **Linux/macOS**: Jalankan `hostname -I` atau `ifconfig` di terminal. (Contoh IP: `192.168.1.15`).
3.  Ubah variabel `_backendUrl` di file `chat_provider.dart` dan `va_provider.dart` dengan IP tersebut:
    ```dart
    static const String _backendUrl = 'http://192.168.1.15:3000';
    ```

#### Langkah 4: Jalankan Debugging
Ketik perintah di terminal PC:
```bash
flutter run
```
Aplikasi akan terpasang di HP kamu secara instan, lengkap dengan fitur **Hot Reload** (tekan `r` di terminal untuk update UI dalam 1 detik!).

---

### C. Wireless Debugging (Debugging Wi-Fi Tanpa Kabel)

Bosan dengan kabel USB yang sering longgar? Kamu bisa melakukan debug nirkabel!

1.  Hubungkan HP ke PC dengan kabel USB sekali saja untuk inisialisasi port.
2.  Jalankan perintah ini di terminal PC:
    ```bash
    adb tcpip 5555
    ```
3.  Cabut kabel USB dari HP.
4.  Cari IP Address HP kamu (*Settings -> About Phone -> Status -> IP Address*, misal: `192.168.1.50`).
5.  Hubungkan secara nirkabel dari PC:
    ```bash
    adb connect 192.168.1.50:5555
    ```
6.  Ketik `flutter run` untuk mulai debugging tanpa kabel!

---

## 🛠️ Cara Membuat File APK (Build APK)

Jika kamu ingin membagikan aplikasi Android ini ke teman atau menginstalnya secara permanen di HP tanpa PC:

1.  Pastikan backend kamu dideploy ke server online/VPS, atau jika masih lokal, pastikan kamu menggunakan IP Wi-Fi PC yang aktif saat build.
2.  Jalankan perintah build di folder `virtual_projek`:
    ```bash
    flutter build apk --release
    ```
3.  File APK hasil build yang siap diinstal akan berada di:
    `virtual_projek/build/app/outputs/flutter-apk/app-release.apk`

---

## ⚠️ Solusi Masalah Umum (Troubleshooting)

### 1. Error: "Connection Refused" di HP Fisik
*   **Penyebab**: Firewall di PC kamu memblokir koneksi masuk dari HP, atau IP PC kamu berubah.
*   **Solusi**:
    1.  Cek kembali IP PC kamu menggunakan `ipconfig` / `hostname -I`.
    2.  Izinkan port `3000` pada pengaturan Firewall PC kamu, atau nonaktifkan sementara Firewall saat debugging.

### 2. Mikrofon Tidak Mau Merekam Suara (Izin Akses)
*   **Penyebab**: Aplikasi tidak diberikan izin akses mikrofon oleh Android.
*   **Solusi**: Project ini sudah otomatis menyertakan tag `<uses-permission android:name="android.permission.RECORD_AUDIO" />` di file `AndroidManifest.xml`. Pastikan kamu mengetuk **"Izinkan saat aplikasi digunakan"** ketika HP meminta izin mikrofon pertama kali.

---
*Dikembangkan dengan penuh cinta dan dedikasi oleh [Nanda Putra](https://github.com/nandaputrahartono-pc)* 🚀
