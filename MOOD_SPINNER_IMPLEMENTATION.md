# Implementasi Mood Tracker Spinning Wheel

## Fitur yang Sudah Diimplementasikan

### 1. **Manual Spinning Wheel UI**
- **File**: `lib/widgets/mood_spinner_widget.dart`
- **Fitur**:
  - Menggunakan gambar `Spin Emote.png` sebagai background wheel
  - 5 mood options: Senang, Biasa Saja, Sedih, Marah, Murung
  - **Manual drag/swipe** untuk memutar wheel (bukan random)
  - Momentum physics saat melepas drag
  - Visual feedback dengan pointer indicator di atas wheel
  - Instruksi "Seret roda untuk memilih mood"
  - Display mood yang terpilih berdasarkan posisi pointer

### 2. **Validasi Harian**
- **Logic**: User hanya bisa memilih mood **sekali per hari**
- **Implementasi**:
  - Cek mood hari ini saat halaman dimuat
  - Jika sudah memilih, spinner tidak bisa diputar (canSpin = false)
  - Tampilan berubah menjadi "DONE" dengan warna abu-abu
  - Menampilkan pesan "Sudah memilih mood hari ini"

### 3. **Integrasi Database**
- **Backend**: Endpoint API sudah siap di Laravel
- **Validasi Backend**: Mencegah multiple mood entries per hari
- **Response**: Error code `MOOD_ALREADY_SELECTED_TODAY` jika sudah memilih

### 4. **Mood Options**
Sesuai dengan database schema:
- `senang` - 😊 Senang (Hijau)
- `biasa_saja` - 😐 Biasa Saja (Kuning)
- `sedih` - 😢 Sedih (Merah)
- `marah` - 😡 Marah (Coklat Tua)
- `murung` - 😟 Murung (Oranye)

## Files yang Dimodifikasi/Dibuat

### Baru Dibuat:
1. `lib/widgets/mood_spinner_widget.dart` - Widget spinning wheel utama

### Dimodifikasi:
1. `lib/screens/mood_tracker_screen.dart` - Menggunakan spinner widget dan validasi harian
2. `lib/services/mood_service.dart` - Menambah method `saveMoodByType`
3. `quranicare_be/app/Http/Controllers/API/MoodController.php` - Validasi backend

## Cara Penggunaan

1. User masuk ke halaman mood tracker (`/mood-tracker`)
2. Jika belum memilih mood hari ini:
   - User **seret/drag** wheel untuk memutarnya secara manual
   - Wheel berputar mengikuti gerakan jari/mouse
   - Saat dilepas, wheel akan berputar dengan momentum dan berhenti
   - Mood yang ditunjuk pointer (di atas) otomatis dipilih dan disimpan
3. Jika sudah memilih mood hari ini:
   - Wheel overlay dengan ikon gembok (🔒)
   - Instruksi berubah menjadi "Sudah memilih mood hari ini"
   - Wheel tidak bisa diputar lagi (disabled)
   - Tampil pesan konfirmasi

## API Endpoints yang Digunakan

- `GET /api/mood/today` - Cek mood hari ini
- `POST /api/mood` - Simpan mood baru (dengan validasi harian)

## Struktur Database

```sql
-- Table: moods
- user_id: bigint (FK ke users)
- mood_type: enum('senang','sedih','biasa_saja','marah','murung')
- mood_date: date
- mood_time: time
- notes: text (optional)

-- Table: mood_statistics  
- user_id: bigint (FK ke users)
- date: date
- mood_counts: longtext (JSON)
- dominant_mood: enum (sama seperti mood_type)
- mood_score: decimal(3,2)
- total_entries: int
```

## Kustomisasi Lebih Lanjut

Jika ingin mengubah behavior:

1. **Rubah ke validasi mingguan**: Ganti logic di `_checkTodayMood()` 
2. **Tambah mood baru**: Update enum di backend dan list `_moods` di widget
3. **Ganti gambar spinner**: Replace file `assets/images/Spin Emote.png`
4. **Ubah sensitivitas drag**: Modifikasi nilai `0.008` di `_handlePanUpdate()`
5. **Ubah momentum**: Sesuaikan multiplier di `_handlePanEnd()`
6. **Ganti ke random lagi**: Ganti `GestureDetector` dengan tombol dan random logic

## Error Handling

- Network error: Fallback ke allow selection
- Backend validation error: Show error message
- Asset not found: Fallback ke gradient background

---

**Status**: ✅ **SELESAI DIIMPLEMENTASIKAN**

Semua requirement sudah terpenuhi:
- ✅ **Manual spinning wheel** dengan gambar Spin Emote.png (tidak random)
- ✅ 5 mood options sesuai database
- ✅ Drag & swipe gesture untuk memutar wheel
- ✅ Momentum physics saat melepas drag
- ✅ Simpan ke database via API
- ✅ Validasi harian (sekali per hari)
- ✅ UI responsive dan user-friendly