# 📊 Sakinah Tracker - Dokumentasi Lengkap

## 🎯 Overview

Sakinah Tracker adalah fitur komprehensif untuk memantau aktivitas spiritual dan mental health harian pengguna aplikasi QuraniCare. Fitur ini mengintegrasikan semua aktivitas pengguna dari berbagai modul aplikasi dalam satu dashboard yang informatif dan visual.

## ✨ Fitur Utama

### 📅 Calendar View
- **Visualisasi Bulanan**: Tampilan kalender dengan indikator aktivitas per hari
- **Color-coded Intensity**: Warna berbeda menunjukkan jumlah aktivitas (0-8+ aktivitas)
- **Interactive Selection**: Klik tanggal untuk melihat detail aktivitas hari tersebut
- **Navigation**: Dropdown untuk navigasi bulan dan tahun

### 📊 Daily Activity Summary
- **Aktivitas Harian**: Daftar lengkap aktivitas yang dilakukan pada tanggal terpilih
- **Metadata Detail**: Setiap aktivitas menampilkan informasi spesifik:
  - Waktu pelaksanaan
  - Durasi (jika ada)
  - Detail tambahan (surah, mood, dll)
- **Empty State**: Pesan informatif jika tidak ada aktivitas pada tanggal tertentu

### 📈 Monthly Statistics
- **Total Activities**: Jumlah total aktivitas dalam bulan
- **Active Days**: Berapa hari dalam bulan yang ada aktivitas
- **Average per Day**: Rata-rata aktivitas per hari
- **Most Active Type**: Jenis aktivitas yang paling sering dilakukan
- **Activity Breakdown**: Distribusi aktivitas per jenis dengan persentase dan progress bar

### 🔄 Real-time Updates
- **Event-driven Tracking**: Setiap aktivitas dicatat secara otomatis
- **Instant Sync**: Data terupdate langsung saat aktivitas dilakukan
- **Refresh Button**: Opsi manual refresh untuk memuat data terbaru

## 🛠️ Arsitektur Teknis

### Backend (Laravel)

#### 1. Event-Driven Architecture
```php
// Setiap aktivitas trigger event otomatis
event(new UserActivityEvent(
    $userId,
    'activity_type', 
    'Description',
    $metadata
));
```

#### 2. Database Structure
- **Table**: `user_activity_logs`
- **Columns**: 
  - `user_id`: ID pengguna
  - `activity_type`: Jenis aktivitas (8 types)
  - `activity_name`: Nama aktivitas
  - `activity_date`: Tanggal aktivitas
  - `metadata`: JSON data tambahan
  - `created_at`: Timestamp

#### 3. API Endpoints
```php
// Daily activities
GET /api/sakinah-tracker/daily/{date}

// Monthly summary
GET /api/sakinah-tracker/monthly/{year}/{month}

// Calendar data
GET /api/sakinah-tracker/calendar/{year}/{month}

// Activity summary
GET /api/sakinah-tracker/summary
```

#### 4. Integrated Controllers
- ✅ **DoaDzikirController**: Dzikir sessions tracking
- ✅ **QuranReadingController**: Quran reading sessions
- ✅ **BreathingExerciseController**: Breathing exercise sessions
- ✅ **AudioRelaxController**: Audio listening sessions
- ✅ **JournalController**: Journal entries and reflections
- ✅ **QalbuChatbotController**: AI counseling sessions
- ✅ **MoodController**: Mood tracking entries

### Frontend (Flutter)

#### 1. Service Layer
```dart
class SakinahTrackerService {
  // API communication dengan authentication
  // Mock data fallback untuk testing
  // Error handling comprehensive
}
```

#### 2. Data Models
```dart
class UserActivity {
  // Activity data dengan helper methods
  String get displayName // Nama aktivitas dalam Bahasa Indonesia
  String get iconEmoji   // Emoji sesuai jenis aktivitas
  String? get duration   // Durasi dari metadata
}

class ActivitySummary {
  // Monthly statistics dengan calculation methods
  String get mostActiveType
  double getActivityPercentage(String type)
}
```

#### 3. UI Components
- **Enhanced Calendar**: Custom calendar dengan activity indicators
- **Activity Cards**: Rich display untuk setiap aktivitas
- **Statistics Grid**: Visual representation data bulanan
- **Empty State**: User-friendly message untuk hari tanpa aktivitas

## 📱 Jenis Aktivitas yang Di-track

| No | Activity Type | Emoji | Deskripsi | Metadata Contoh |
|----|---------------|-------|-----------|-----------------|
| 1 | `quran_reading` | 📖 | Membaca Al-Qur'an | surah_name, verses_count, duration |
| 2 | `dzikir_session` | 🤲 | Sesi Dzikir & Doa | dzikir_type, repetition_count, duration |
| 3 | `breathing_exercise` | 🧘 | Latihan Pernapasan | exercise_name, cycles, duration |
| 4 | `audio_listening` | 🎧 | Mendengarkan Audio | audio_title, artist, category |
| 5 | `journal_entry` | 📝 | Menulis Jurnal | word_count, mood, tags, ayah_reference |
| 6 | `qalbuchat_session` | 💬 | Sesi QalbuChat | conversation_length, topic |
| 7 | `psychology_assessment` | 🧠 | Asesmen Psikologi | assessment_type, score |
| 8 | `mood_tracking` | 😊 | Pelacakan Mood | mood_type, mood_level, notes |

## 🎨 Visual Design

### Color Scheme
- **Primary Green**: `#8FA68E` - Warna utama aplikasi
- **Activity Intensity Colors**:
  - No activity: `#E5E7EB` (Abu-abu terang)
  - 1-2 activities: `#BEF264` (Hijau muda)
  - 3-5 activities: `#84CC16` (Hijau sedang)  
  - 6-8 activities: `#65A30D` (Hijau tua)
  - 8+ activities: `#166534` (Hijau pekat)

### Typography
- **Headers**: Bold, 18-24px
- **Body**: Regular, 14-16px
- **Metadata**: Light, 12px
- **Font**: System default (Roboto/SF Pro)

## 🚀 User Journey

### 1. Accessing Sakinah Tracker
```
Home Screen → Profile → Sakinah Tracker
```

### 2. Viewing Activities
```
Calendar View → Select Date → View Daily Activities
```

### 3. Understanding Data
```
Activity Icons → Descriptive Names → Metadata Details
```

### 4. Monthly Analysis
```
Monthly Stats → Activity Breakdown → Progress Insights
```

## 📊 Data Flow

### Activity Creation
```
User Action → Controller → Event Trigger → UserActivityEvent → LogUserActivity Listener → Database Insert → API Response
```

### Data Retrieval
```
Flutter Request → SakinahTrackerService → Laravel API → UserActivityLog Query → JSON Response → Model Parsing → UI Update
```

## 🔧 Error Handling

### Backend
- **Validation**: Input validation untuk semua endpoints
- **Authentication**: Middleware protection
- **Database**: Try-catch dengan rollback
- **Logging**: Comprehensive error logging

### Frontend
- **Network**: Timeout dan retry mechanisms
- **Null Safety**: Safe handling untuk empty data
- **Mock Data**: Fallback data untuk testing
- **User Feedback**: Loading states dan error messages

## 📈 Performance Optimizations

### Database
- **Indexing**: Pada `user_id`, `activity_date`, `activity_type`
- **Pagination**: Untuk large datasets
- **Query Optimization**: Efficient queries dengan proper joins

### Frontend
- **Lazy Loading**: Data dimuat sesuai kebutuhan
- **Caching**: SharedPreferences untuk auth token
- **State Management**: Efficient setState usage
- **Image Optimization**: Compressed assets

## 🧪 Testing

### Mock Data Features
- **Date-based Generation**: Mock activities untuk 7 hari terakhir
- **Realistic Metadata**: Sample data yang realistis
- **Fallback System**: Otomatis aktif jika server tidak tersedia

### Testing Scenarios
1. **Empty State**: Hari tanpa aktivitas
2. **Normal Day**: 2-5 aktivitas per hari
3. **Busy Day**: 6+ aktivitas per hari
4. **Month Navigation**: Perpindahan bulan/tahun
5. **Refresh Functionality**: Manual data reload

## 🔮 Future Enhancements

### Planned Features
- 📈 **Streak Tracking**: Consecutive activity days
- 🏆 **Achievement System**: Badges untuk milestones
- 📊 **Advanced Analytics**: Trend analysis dan insights
- 🔔 **Smart Notifications**: Reminder untuk aktivitas
- 📤 **Export Features**: PDF/CSV export untuk data
- 👥 **Social Features**: Share progress dengan friends
- 🎯 **Goal Setting**: Target aktivitas harian/bulanan

### Technical Improvements
- **Offline Support**: Local database sync
- **Push Notifications**: Background activity reminders
- **Data Visualization**: Charts dan graphs
- **Machine Learning**: Personalized recommendations
- **API Optimization**: GraphQL implementation
- **Real-time Updates**: WebSocket integration

## 🎯 Success Metrics

### User Engagement
- Daily active users yang mengakses Sakinah Tracker
- Average session duration di screen
- Monthly retention rate
- Feature adoption rate per activity type

### Spiritual Growth
- Increase in daily spiritual activities
- Consistency in religious practices
- User self-reported mood improvements
- Long-term engagement trends

---

## 📝 Installation & Setup

### Prerequisites
- Laravel 8+ dengan Sanctum
- Flutter 3+ dengan http package
- MySQL/PostgreSQL database
- PHP 8+ dengan required extensions

### Quick Start
```bash
# Backend setup
cd quranicare_be
php artisan migrate
php artisan db:seed --class=SakinahTrackerSeeder
php artisan serve

# Frontend setup  
cd quranicare
flutter pub get
flutter run
```

### Configuration
```dart
// Update base URL di SakinahTrackerService
static const String baseUrl = 'http://your-api-url.com/api';
```

---

**🎉 Sakinah Tracker siap digunakan untuk membantu pengguna memantau journey spiritual mereka!**