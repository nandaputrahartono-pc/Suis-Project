# Welcome to Suis-Project 🎨🤖

Selamat datang di **Suis-Project**, sebuah project full-stack yang menggabungkan aplikasi Virtual Assistant berbasis Flutter dengan backend AI yang canggih. Project ini dirancang dengan estetika **Pixel Art** yang unik untuk memberikan pengalaman interaksi yang futuristik namun tetap memiliki nuansa retro yang hangat.

---

## 📂 Struktur Project

```text
suis-ai/
├── virtual_projek/      # Aplikasi Mobile & Desktop (Flutter)
└── virtual_ai/          # Backend Service (TypeScript/Node.js + Fastify + Groq)
```

- **`virtual_projek/`**: Antarmuka pengguna utama dengan visualisasi Pixel Art, sistem tema, dan pengolah suara.
- **`virtual_ai/`**: Otak dari asisten virtual, memproses chat via Groq API dan melakukan konversi Text-To-Speech (TTS) super cepat.

---

## ✨ Fitur Utama

*   **Antarmuka Pixel-Art Premium**: Visual retro-futuristik yang dikurasi dengan cermat.
*   **Real-time Voice Assistant**: Interaksi suara dua arah yang mulus secara hands-free.
*   **Pixel Particle & Soundwave Visualizer**: Efek visual dinamis yang merespons suara asisten secara real-time.
*   **Multi-Model Engine**: Dukungan pergantian model AI (Queen, GPT, Claude) dengan deskripsi unik.
*   **Dual Mode Theme**: Mode gelap (Dark Mode) dan terang dengan palet warna yang harmonis.

---

## 🛠️ Prasyarat (Prerequisites)

Sebelum memulai, pastikan perangkat kamu sudah memiliki perkakas berikut:

*   **Flutter SDK** (Versi 3.19.x ke atas) -> [Unduh di sini](https://docs.flutter.dev/get-started/install)
*   **Node.js** (Versi 18 ke atas) & **npm** -> [Unduh di sini](https://nodejs.org/)
*   **Git** -> [Unduh di sini](https://git-scm.com/)
*   **Android Studio** (untuk build Android) atau **Visual Studio** / **Clang** (untuk build Desktop)

---

## 🚀 Setup & Panduan Penginstalan Lengkap

### 1. Clone Repository & Setup Root
```bash
git clone https://github.com/nandaputrahartono-pc/Suis-Project.git
cd Suis-Project
```

---

### 2. Setup Backend (`virtual_ai`)
Backend berfungsi sebagai API gateway untuk memproses teks lewat Groq dan menghasilkan suara TTS.

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
5.  Jalankan backend dalam mode pengembangan:
    ```bash
    npm run dev
    ```
    > [!NOTE]
    > Backend akan berjalan di `http://localhost:3000`. Jika port ini sudah terpakai, ubah variabel `PORT` di file `.env`.

---

### 3. Platform-Specific Setup & Run (Frontend)
Masuk terlebih dahulu ke direktori frontend:
```bash
cd ../virtual_projek
flutter pub get
```

#### 🪟 Windows Desktop
1.  Pastikan **Developer Mode** aktif di Windows Settings kamu.
2.  Instal **Visual Studio 2022** dengan beban kerja (workload) **"Desktop development with C++"** tercentang.
3.  Aktifkan dukungan Windows Desktop di Flutter:
    ```bash
    flutter config --enable-windows-desktop
    ```
4.  Cek kesiapan sistem:
    ```bash
    flutter doctor
    ```
5.  Jalankan aplikasi:
    ```bash
    flutter run -d windows
    ```

#### 🐧 Linux Desktop
1.  Instal dependensi build Linux berikut lewat terminal:
    ```bash
    sudo apt-get update
    sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
    ```
2.  Aktifkan dukungan Linux Desktop di Flutter:
    ```bash
    flutter config --enable-linux-desktop
    ```
3.  Jalankan aplikasi:
    ```bash
    flutter run -d linux
    ```

#### 🤖 Android Mobile (Build APK)
1.  Pastikan **Android SDK** dan **Command-line Tools** sudah terinstal melalui Android Studio SDK Manager.
2.  Setujui lisensi Android:
    ```bash
    flutter doctor --android-licenses
    ```
3.  Untuk mem-build APK Release:
    ```bash
    flutter build apk --release
    ```
    *File APK hasil build akan berada di `build/app/outputs/flutter-apk/app-release.apk`.*

---

## 📡 Konfigurasi Jaringan & Debugging (SANGAT PENTING!)

Agar aplikasi frontend dapat berkomunikasi dengan backend, kamu harus menyesuaikan alamat **`_backendUrl`** pada kode Flutter sesuai dengan perangkat yang kamu gunakan untuk debugging.

### 1. Tabel Konfigurasi IP Backend

| Perangkat Debugging | URL Backend Flutter | Penjelasan |
| :--- | :--- | :--- |
| **Windows / Linux Desktop** | `http://localhost:3000` | Frontend dan Backend berjalan di satu mesin yang sama. |
| **Android Emulator** | `http://10.0.2.2:3000` | Loopback IP khusus agar emulator Android bisa mengakses localhost PC. |
| **Handphone Fisik (Android)** | `http://<IP_PC_KAMU>:3000` | Menggunakan IP lokal PC agar HP bisa mengaksesnya lewat jaringan Wi-Fi lokal. |

### 2. Cara Mengubah URL Backend di Kode
Kamu wajib mengubah nilai variabel `_backendUrl` pada 2 file berikut sebelum menjalankan aplikasi:

1.  **`virtual_projek/lib/providers/chat_provider.dart`** (Sekitar Baris 81)
    ```dart
    static const String _backendUrl = 'http://192.168.1.21:3000'; // Ganti IP ini!
    ```
2.  **`virtual_projek/lib/providers/va_provider.dart`** (Sekitar Baris 29)
    ```dart
    static const String _backendUrl = 'http://192.168.1.21:3000'; // Ganti IP ini!
    ```

---

## 💻 Panduan Lengkap Debugging di Android

### A. Debugging via Android Emulator (AVD)

1.  Buka **Android Studio** -> **Device Manager** -> Jalankan salah satu emulator pilihanmu.
2.  Ubah `_backendUrl` di kedua file Dart di atas menjadi:
    ```dart
    static const String _backendUrl = 'http://10.0.2.2:3000';
    ```
3.  Jalankan aplikasi ke emulator melalui terminal:
    ```bash
    flutter run -d emulator
    ```
    *(Atau klik tombol **Run/Debug** di VS Code setelah memilih emulator).*

---

### B. Debugging via Handphone Fisik (Real Device) - USB Debugging

Ini adalah cara terbaik untuk menguji fitur Voice Assistant karena mikrofon bawaan HP asli jauh lebih jernih dan akurat dibanding mikrofon emulator!

#### Langkah 1: Aktifkan Developer Options & USB Debugging di HP
1.  Buka **Settings (Pengaturan)** di HP Android kamu.
2.  Masuk ke **About Phone (Tentang Ponsel)**.
3.  Cari **Build Number (Nomor Bentukan)** lalu **ketuk sebanyak 7 kali** dengan cepat hingga muncul notifikasi *"Anda sekarang adalah pengembang!"*.
4.  Kembali ke menu utama Settings -> Cari **Developer Options (Opsi Pengembang)**.
5.  Cari dan **Aktifkan USB Debugging (Debugging USB)**.

#### Langkah 2: Hubungkan HP ke Laptop/PC
1.  Hubungkan HP ke komputer menggunakan kabel USB berkualitas baik.
2.  Di layar HP akan muncul pop-up otorisasi *"Izinkan debugging USB?"*. Centang **"Selalu izinkan dari komputer ini"** lalu ketuk **OK**.
3.  Verifikasi apakah HP sudah terdeteksi oleh Flutter dengan mengetikkan perintah ini di terminal PC:
    ```bash
    flutter devices
    ```
    *HP kamu harus muncul di daftar perangkat yang aktif.*

#### Langkah 3: Samakan Koneksi Wi-Fi & Cari IP PC
1.  **SANGAT PENTING**: HP dan Laptop/PC kamu harus terhubung ke **jaringan Wi-Fi yang sama** (satu router/hotspot).
2.  Cari tahu IP Address lokal PC kamu:
    *   **Linux (Ubuntu/Debian)**: Jalankan `hostname -I` atau `ifconfig` di terminal. (Contoh IP: `192.168.1.15`).
    *   **Windows**: Jalankan `ipconfig` di Command Prompt (Cari baris `IPv4 Address` di bagian Wi-Fi adapter).
3.  Ubah variabel `_backendUrl` di file `chat_provider.dart` dan `va_provider.dart` dengan IP tersebut:
    ```dart
    static const String _backendUrl = 'http://192.168.1.15:3000';
    ```

#### Langkah 4: Jalankan Debugging
Jalankan perintah berikut di terminal:
```bash
flutter run
```
Pilih nomor indeks HP kamu yang muncul pada daftar. Sekarang kamu bisa memanfaatkan fitur **Hot Reload** (tekan `r` di terminal) dan log error real-time akan muncul langsung di layar monitormu!

---

### C. Debugging Tanpa Kabel (Wireless Debugging via Wi-Fi)

Jika kabel USB kamu sering longgar, kamu bisa melakukan debug secara nirkabel!

1.  Hubungkan HP dengan kabel USB terlebih dahulu (sekali saja untuk inisialisasi port).
2.  Pastikan HP dan PC berada di Wi-Fi yang sama.
3.  Jalankan perintah ini di terminal PC untuk mengaktifkan mode TCP/IP pada port `5555`:
    ```bash
    adb tcpip 5555
    ```
4.  Cabut kabel USB dari HP.
5.  Cari IP Address HP kamu (di HP: *Settings -> About Phone -> Status -> IP Address*, misal: `192.168.1.50`).
6.  Hubungkan secara nirkabel melalui terminal PC:
    ```bash
    adb connect 192.168.1.50:5555
    ```
7.  Jalankan `flutter devices` untuk memastikan HP nirkabel kamu sudah terbaca sebagai perangkat debug.
8.  Ketik `flutter run` untuk mulai debugging tanpa kabel!

---

## ⚠️ Gotchas & Solusi Masalah Umum

### 1. Error: "Connection refused" atau "Failed to connect to..." di HP/Emulator
*   **Penyebab**: Alamat IP PC salah, port 3000 diblokir oleh Firewall PC, atau HP/PC tidak satu Wi-Fi.
*   **Solusi**:
    1.  Cek kembali IP PC kamu menggunakan `hostname -I` atau `ipconfig`.
    2.  Matikan sementara Firewall PC atau izinkan koneksi masuk (*inbound rules*) untuk Port 3000.
    3.  Pastikan koneksi Wi-Fi HP tidak dalam mode "Isolated/Guest Network".

### 2. Suara Voice Assistant Tidak Terdengar di HP
*   **Penyebab**: Aplikasi tidak memiliki izin mikrofon atau volume media HP mati.
*   **Solusi**:
    *   Pastikan baris `<uses-permission android:name="android.permission.RECORD_AUDIO" />` sudah ada di `android/app/src/main/AndroidManifest.xml` (fitur ini sudah terpasang secara default di project ini).
    *   Izinkan akses mikrofon saat pertama kali aplikasi meminta izin di HP.

### 3. Masalah CORS (Cross-Origin Resource Sharing)
*   **Penyebab**: Browser atau perangkat memblokir request karena domain berbeda.
*   **Solusi**: Backend Fastify kami sudah dikonfigurasi dengan `@fastify/cors` untuk menerima request dari origin mana pun secara aman selama proses pengembangan.

---
*Dikembangkan dengan penuh cinta dan dedikasi oleh [Nanda Putra](https://github.com/nandaputrahartono-pc)* 🚀
