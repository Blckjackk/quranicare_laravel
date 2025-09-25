# Mood Tracker Feature Documentation

## Overview
Fitur Mood Tracker telah berhasil dibuat dengan widget selector berbentuk lingkaran yang interaktif, sesuai dengan desain yang Anda berikan. User dapat memilih mood mereka dengan interface yang intuitif dan data akan disimpan ke database.

## Fitur yang Telah Dibuat

### 1. MoodSelectorWidget (Circular Mood Selector)
- **Lokasi**: `lib/widgets/mood_selector_widget.dart`
- **Fitur**:
  - Interface circular dengan 5 pilihan mood (sedih, murung, biasa saja, senang, marah)
  - Animasi scale saat mood dipilih
  - Visual feedback dengan warna dan shadow
  - Non-random selection (user bisa pilih sendiri mood mereka)

### 2. MoodService (API Service)
- **Lokasi**: `lib/services/mood_service.dart`
- **Fitur**:
  - Method untuk menyimpan mood (`saveMood`)
  - Method untuk mengambil mood hari ini (`getTodayMoods`)
  - Method untuk history mood (`getMoodHistory`)
  - Method untuk statistik mood (`getMoodStatistics`)
  - Method untuk update dan delete mood

### 3. Updated MoodTrackerScreen
- **Lokasi**: `lib/screens/mood_tracker_screen.dart`
- **Fitur**:
  - Design sesuai dengan mockup "Bagaimana Perasaan Kamu Hari Ini??"
  - Menggunakan MoodSelectorWidget yang baru
  - Loading state saat menyimpan data
  - Error handling dengan snackbar
  - Success feedback

### 4. Database Integration
- **Backend sudah siap**: Tabel `moods` sudah ada dengan fields yang diperlukan
- **API endpoints sudah tersedia**: MoodController dengan semua method CRUD

### 5. Home Screen Integration
- **Tombol "Pilih dengan Spin"** ditambahkan di home screen pada bagian mood tracking
- Navigasi ke mood tracker screen yang baru
- Integrasi dengan mood selection yang sudah ada

## Cara Penggunaan

### 1. Navigasi ke Mood Tracker
Dari home screen, user bisa:
1. Memilih mood langsung dari grid mood yang ada (seperti sebelumnya)
2. Atau klik tombol **"Pilih dengan Spin"** untuk membuka mood selector circular

### 2. Memilih Mood
Di mood tracker screen:
1. User melihat interface dengan teks "Bagaimana Perasaan Kamu Hari Ini??"
2. User dapat tap pada salah satu emoji mood di lingkaran selector
3. Mood yang dipilih akan ter-highlight dengan animasi dan perubahan warna
4. User klik tombol "Simpan Mood Saya" untuk menyimpan ke database

### 3. Feedback
- Loading indicator saat menyimpan
- Success message saat berhasil disimpan
- Error message jika ada masalah

## Mood Options Available
1. **Sedih** 😢 - Warna merah tua
2. **Murung** 😟 - Warna orange
3. **Biasa Saja** 😐 - Warna kuning
4. **Senang** 😊 - Warna hijau
5. **Marah** 😡 - Warna coklat tua

## Next Steps & Improvements

### 1. Authentication Integration
Saat ini menggunakan token placeholder. Perlu integrasi dengan:
- Auth service untuk mendapatkan user token
- User session management

### 2. Backend Configuration
Update base URL di MoodService (`lib/services/mood_service.dart`):
```dart
static const String baseUrl = 'YOUR_BACKEND_URL/api';
```

### 3. Additional Features
- History mood dengan chart/grafik
- Mood statistics dashboard
- Push notifications untuk reminder mood check
- Export data mood ke PDF/Excel

### 4. UI Enhancements
- Tambahkan haptic feedback saat memilih mood
- Animasi yang lebih smooth
- Dark mode support
- Accessibility improvements

## File Structure
```
lib/
├── screens/
│   └── mood_tracker_screen.dart      # Updated mood tracker dengan design baru
├── widgets/
│   └── mood_selector_widget.dart     # Widget circular mood selector
├── services/
│   └── mood_service.dart             # Service untuk API mood
└── main.dart                         # Route '/mood-tracker' sudah ada

quranicare_be/
├── app/
│   ├── Http/Controllers/API/
│   │   └── MoodController.php        # Controller API mood (sudah ada)
│   └── Models/
│       └── Mood.php                  # Model mood (sudah ada)
└── database/migrations/
    └── create_moods_table.php        # Migration tabel moods (sudah ada)
```

## Testing
Untuk testing fitur:
1. Jalankan Flutter app: `flutter run`
2. Buka home screen
3. Scroll ke bagian mood tracking
4. Klik tombol "Pilih dengan Spin"
5. Pilih mood dan coba simpan

**Note**: Pastikan backend Laravel sudah running dan database sudah di-migrate.

## Troubleshooting

### Jika ada error HTTP
- Pastikan backend URL benar di `MoodService`
- Pastikan Laravel API sudah running
- Check CORS settings di backend

### Jika mood tidak tersimpan
- Check token authentication
- Pastikan database connection OK
- Check Laravel logs untuk error details

---

Fitur mood tracker sudah siap digunakan! 🎉