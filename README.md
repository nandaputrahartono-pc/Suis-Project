# Welcome to Suis-Project 🎨🤖

Selamat datang di **Suis-Project**, sebuah project full-stack desktop yang menggabungkan aplikasi Virtual Assistant berbasis Flutter dengan backend AI yang canggih. Project ini dirancang khusus untuk platform desktop (**Windows**, **Linux**, dan **macOS**) dengan estetika **Pixel Art** yang unik untuk memberikan pengalaman interaksi yang futuristik namun tetap memiliki nuansa retro yang hangat.

---

## 📂 Struktur Project

```text
suis-ai/
├── virtual_projek/      # Aplikasi Desktop (Flutter - Windows, Linux, macOS)
└── virtual_ai/          # Backend Service (TypeScript/Node.js + Fastify + Groq)
```

- **`virtual_projek/`**: Antarmuka pengguna desktop utama dengan visualisasi Pixel Art, sistem tema, dan pengolah suara.
- **`virtual_ai/`**: Otak dari asisten virtual, memproses chat via Groq API dan menghasilkan suara TTS (Text-To-Speech) super cepat.

---

## ✨ Fitur Utama

*   **Antarmuka Pixel-Art Premium**: Visual retro-futuristik desktop yang dikurasi dengan cermat.
*   **Real-time Voice Assistant**: Interaksi suara dua arah yang mulus secara hands-free langsung di komputermu.
*   **Pixel Particle & Soundwave Visualizer**: Efek visual dinamis yang merespons suara asisten secara real-time.
*   **Multi-Model Engine**: Dukungan pergantian model AI (Queen, GPT, Claude) dengan deskripsi unik.
*   **Dual Mode Theme**: Mode gelap (Dark Mode) dan terang dengan palet warna yang harmonis.

---

## 🛠️ Prasyarat (Prerequisites)

Sebelum memulai, pastikan perangkat kamu sudah memiliki perkakas berikut:

*   **Flutter SDK** (Versi 3.19.x ke atas) -> [Unduh di sini](https://docs.flutter.dev/get-started/install)
*   **Node.js** (Versi 18 ke atas) & **npm** -> [Unduh di sini](https://nodejs.org/)
*   **Git** -> [Unduh di sini](https://git-scm.com/)

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
    > Backend secara default akan berjalan di `http://localhost:3000`. Jika port ini sudah terpakai, ubah variabel `PORT` di file `.env`.

---

### 3. Platform-Specific Setup & Run (Frontend)

Buka terminal baru, lalu masuk ke direktori frontend:
```bash
cd virtual_projek
flutter pub get
```

#### 🪟 Windows Desktop
1.  Pastikan **Developer Mode** sudah aktif di Windows Settings kamu (*Settings -> Update & Security -> For developers -> Developer Mode*).
2.  Instal **Visual Studio 2022** dan pastikan mencentang beban kerja (workload) **"Desktop development with C++"** saat instalasi.
3.  Aktifkan dukungan Windows Desktop di Flutter:
    ```bash
    flutter config --enable-windows-desktop
    ```
4.  Cek kesiapan sistem dengan perintah:
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

#### 🍎 macOS Desktop
1.  Pastikan **Xcode** sudah terinstal (bisa diunduh lewat Mac App Store) dan jalankan setup command line tools:
    ```bash
    sudo xcode-select --install
    ```
2.  Instal **CocoaPods** untuk manajemen dependensi iOS/macOS:
    ```bash
    brew install cocoapods
    ```
3.  Aktifkan dukungan macOS Desktop di Flutter:
    ```bash
    flutter config --enable-macos-desktop
    ```
4.  Masuk ke folder macOS dan jalankan instalasi pods:
    ```bash
    cd macos && pod install && cd ..
    ```
5.  Jalankan aplikasi:
    ```bash
    flutter run -d macos
    ```

---

## 📡 Konfigurasi Jaringan & Debugging Desktop

Karena kamu mendevelop aplikasi **desktop** (Windows, Linux, macOS), frontend dan backend kamu berjalan pada **komputer fisik yang sama (Localhost)**.

### 1. URL Backend Flutter (Out-of-the-Box)
Secara default, kode Flutter di project ini sudah diatur untuk terhubung langsung ke **`http://localhost:3000`**. Kamu **tidak perlu** mengubah IP address apa pun di kode jika menjalankan aplikasi & backend di komputer yang sama!

Jika kamu perlu memeriksanya atau mengubah port backend di kemudian hari, nilai URL didefinisikan pada variabel `_backendUrl` di 2 file berikut:
1.  **`virtual_projek/lib/providers/chat_provider.dart`** (Sekitar Baris 81)
    ```dart
    static const String _backendUrl = 'http://localhost:3000';
    ```
2.  **`virtual_projek/lib/providers/va_provider.dart`** (Sekitar Baris 29)
    ```dart
    static const String _backendUrl = 'http://localhost:3000';
    ```

### 2. Cara Melakukan Debugging Desktop

1.  Pastikan Backend Fastify sudah berjalan di terminal kamu (`npm run dev` di folder `virtual_ai`).
2.  Gunakan editor pilihanmu (**VS Code** atau **Android Studio**):
    *   **VS Code**: Buka folder `virtual_projek`, pilih perangkat desktop kamu di bagian kanan bawah (Windows/Linux/macOS), lalu tekan `F5` untuk menjalankan dengan debugger lengkap.
    *   **Terminal**: Cukup ketik perintah `flutter run` di folder `virtual_projek` dan pilih target desktopmu.
3.  **Hot Reload**: Selama debugging aktif, kamu cukup menekan tombol `r` di terminal atau menekan `Ctrl+S` / `Cmd+S` di VS Code untuk melihat perubahan tampilan secara instan tanpa perlu mem-build ulang!

---

## ⚠️ Gotchas & Solusi Masalah Umum Desktop

### 1. macOS Sandboxing & Izin Jaringan
Secara default, aplikasi desktop macOS berjalan dalam mode *Sandbox* yang membatasi aplikasi untuk mengakses jaringan internet/localhost.
*   **Solusi**: Project ini sudah dikonfigurasi secara proaktif agar dapat menembus Sandbox untuk tujuan development. Kunci berikut telah ditambahkan di `DebugProfile.entitlements` dan `Release.entitlements`:
    ```xml
    <key>com.apple.security.network.client</key>
    <true/>
    ```
*   Jika aplikasi macOS tidak bisa terhubung ke backend, pastikan file entitlement kamu di folder `macos/Runner/` telah memiliki kunci di atas.

### 2. macOS Microphone Permission (Izin Mikrofon)
Untuk menggunakan asisten suara di macOS, sistem memerlukan izin akses mikrofon.
*   **Solusi**: Deskripsi izin berikut sudah dipasang di `macos/Runner/Info.plist`:
    ```xml
    <key>NSMicrophoneUsageDescription</key>
    <string>Aplikasi ini memerlukan akses ke mikrofon untuk fitur asisten suara.</string>
    ```
*   Saat pertama kali menggunakan fitur voice assistant, pastikan memilih **"Allow"** pada pop-up sistem yang muncul.

### 3. Masalah Driver Audio di Linux (ALSA/PulseAudio)
*   **Gejala**: Suara asisten TTS tidak berbunyi atau terjadi error pemutaran audio di Linux.
*   **Solusi**: Pastikan dependensi audio Linux kamu sudah terinstal lengkap. Jalankan:
    ```bash
    sudo apt-get install -y libasound2-dev libpulse-dev
    ```

### 4. Windows Developer Mode Error
*   **Gejala**: Flutter tidak bisa mem-build aplikasi Windows Desktop.
*   **Solusi**: Buka Pengaturan Windows -> Cari "Developer Settings" -> Aktifkan tombol **Developer Mode**.

---
*Dikembangkan dengan penuh cinta dan dedikasi oleh [Nanda Putra](https://github.com/nandaputrahartono-pc)* 🚀
