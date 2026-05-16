# Welcome to Suis-Project 🎨🤖

Selamat datang di **Suis-Project**, sebuah project full-stack yang menggabungkan aplikasi Virtual Assistant berbasis Flutter dengan backend AI yang canggih. Project ini dirancang dengan estetika **Pixel Art** yang unik untuk memberikan pengalaman interaksi yang futuristik namun tetap memiliki nuansa retro yang hangat.

## 📂 Struktur Project

- **`virtual_projek/`**: Aplikasi mobile (Flutter) sebagai antarmuka utama.
- **`virtual_ai/`**: Backend service (TypeScript/Node.js) yang menangani integrasi AI (Groq & TTS).

## ✨ Fitur Utama

- **Antarmuka Pixel-Art**: Desain visual yang dikurasi secara khusus untuk memberikan kesan premium dan nostalgia.
- **Visualisasi Interaktif**: Dilengkapi dengan *Pixel Particle Visualizer* dan *Soundwave* yang bereaksi secara real-time saat berinteraksi.
- **Asisten Virtual Pintar**: Integrasi sistem chat dengan indikator "thinking" yang animatif, menciptakan percakapan yang terasa lebih hidup.
- **Sistem Tema Dinamis**: Mendukung mode gelap (Dark Mode) dengan palet warna yang harmonis dan nyaman di mata.

## 🚀 Persiapan Pengembangan

### 1. Clone Repository
```bash
git clone https://github.com/nandaputrahartono-pc/Suis-Project.git
cd Suis-Project
```

### 2. Setup Backend (virtual_ai)
```bash
cd virtual_ai
npm install
# Jangan lupa setup file .env dengan API Key Groq kamu
npm run dev
```

### 3. Setup Frontend (virtual_projek)
```bash
cd virtual_projek
flutter pub get
flutter run
```

## 🛠️ Teknologi yang Digunakan

- **Flutter & Dart**: Core framework pengembangan lintas platform.
- **TypeScript & Node.js**: Backend logic dan API integration.
- **Groq Cloud API**: Untuk otak AI yang sangat cepat.
- **Provider**: Untuk manajemen state yang efisien dan responsif.
- **Custom Pixel Engine**: Implementasi visualisasi partikel dan elemen UI kustom berbasis pixel.

---
*Dikembangkan oleh [Nanda Putra](https://github.com/nandaputrahartono-pc)*
