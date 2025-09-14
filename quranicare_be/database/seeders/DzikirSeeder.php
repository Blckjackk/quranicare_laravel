<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\DzikirCategory;
use App\Models\DzikirDoa;

class DzikirSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create dzikir categories
        $categories = [
            [
                'name' => 'Dzikir Pagi',
                'description' => 'Dzikir dan doa untuk memulai hari',
                'icon' => 'morning.png',
                'color_code' => '#FFD700',
                'is_active' => true
            ],
            [
                'name' => 'Dzikir Sore',
                'description' => 'Dzikir dan doa untuk sore hari',
                'icon' => 'evening.png', 
                'color_code' => '#FF6B35',
                'is_active' => true
            ],
            [
                'name' => 'Doa Ketenangan',
                'description' => 'Doa untuk menenangkan hati dan pikiran',
                'icon' => 'peace.png',
                'color_code' => '#4ECDC4',
                'is_active' => true
            ],
            [
                'name' => 'Doa Perlindungan',
                'description' => 'Doa untuk memohon perlindungan Allah',
                'icon' => 'protection.png',
                'color_code' => '#45B7D1',
                'is_active' => true
            ],
            [
                'name' => 'Doa Rezeki',
                'description' => 'Doa untuk memohon rezeki yang halal',
                'icon' => 'prosperity.png',
                'color_code' => '#96CEB4',
                'is_active' => true
            ],
            [
                'name' => 'Doa Maaf',
                'description' => 'Doa untuk memohon ampunan Allah',
                'icon' => 'forgiveness.png',
                'color_code' => '#FFEAA7',
                'is_active' => true
            ]
        ];

        foreach ($categories as $categoryData) {
            $category = DzikirCategory::create($categoryData);
            $this->createDzikirForCategory($category);
        }
    }

    private function createDzikirForCategory(DzikirCategory $category)
    {
        $dzikirItems = [];

        switch ($category->name) {
            case 'Dzikir Pagi':
                $dzikirItems = [
                    [
                        'title' => 'Subhanallah',
                        'arabic_text' => 'سُبْحَانَ اللَّهِ',
                        'latin_text' => 'Subhaanallah',
                        'indonesian_translation' => 'Maha Suci Allah',
                        'benefits' => 'Membersihkan hati dan jiwa, mendekatkan diri kepada Allah',
                        'context' => 'Dibaca 33 kali setelah shalat atau kapan saja',
                        'source' => 'HR. Muslim',
                        'repeat_count' => 33,
                        'emotional_tags' => ['ketenangan', 'kesucian', 'kedekatan'],
                        'is_featured' => true
                    ],
                    [
                        'title' => 'Alhamdulillah',
                        'arabic_text' => 'الْحَمْدُ لِلَّهِ',
                        'latin_text' => 'Alhamdulillah',
                        'indonesian_translation' => 'Segala puji bagi Allah',
                        'benefits' => 'Menumbuhkan rasa syukur dan kebahagiaan',
                        'context' => 'Dibaca 33 kali setelah shalat atau saat bersyukur',
                        'source' => 'HR. Muslim',
                        'repeat_count' => 33,
                        'emotional_tags' => ['syukur', 'kebahagiaan', 'positif'],
                        'is_featured' => true
                    ],
                    [
                        'title' => 'Allahu Akbar',
                        'arabic_text' => 'اللَّهُ أَكْبَرُ',
                        'latin_text' => 'Allahu Akbar',
                        'indonesian_translation' => 'Allah Maha Besar',
                        'benefits' => 'Menguatkan iman dan keyakinan kepada Allah',
                        'context' => 'Dibaca 34 kali setelah shalat atau saat takjub',
                        'source' => 'HR. Muslim',
                        'repeat_count' => 34,
                        'emotional_tags' => ['kekuatan', 'keyakinan', 'takjub'],
                        'is_featured' => true
                    ]
                ];
                break;

            case 'Dzikir Sore':
                $dzikirItems = [
                    [
                        'title' => 'Astaghfirullah',
                        'arabic_text' => 'أَسْتَغْفِرُ اللَّهَ',
                        'latin_text' => 'Astaghfirullah',
                        'indonesian_translation' => 'Aku memohon ampun kepada Allah',
                        'benefits' => 'Membersihkan dosa dan membuka pintu rezeki',
                        'context' => 'Dibaca kapan saja, terutama saat merasa bersalah',
                        'source' => 'HR. Ahmad',
                        'repeat_count' => 100,
                        'emotional_tags' => ['penyesalan', 'pembersihan', 'harapan'],
                        'is_featured' => true
                    ],
                    [
                        'title' => 'La Hawla Wa La Quwwata Illa Billah',
                        'arabic_text' => 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
                        'latin_text' => 'La hawla wa la quwwata illa billah',
                        'indonesian_translation' => 'Tidak ada daya dan kekuatan kecuali dari Allah',
                        'benefits' => 'Memberikan kekuatan dalam menghadapi kesulitan',
                        'context' => 'Dibaca saat menghadapi masalah atau kesulitan',
                        'source' => 'HR. Bukhari',
                        'repeat_count' => 10,
                        'emotional_tags' => ['pasrah', 'kekuatan', 'keteguhan'],
                        'is_featured' => true
                    ]
                ];
                break;

            case 'Doa Ketenangan':
                $dzikirItems = [
                    [
                        'title' => 'Doa Ketenangan Hati',
                        'arabic_text' => 'اللَّهُمَّ أَصْلِحْ لِي دِينِي الَّذِي هُوَ عِصْمَةُ أَمْرِي',
                        'latin_text' => 'Allahumma ashlih li diiniy alladzii huwa \'ishmatu amrii',
                        'indonesian_translation' => 'Ya Allah, perbaikilah agamaku yang menjadi benteng urusanku',
                        'benefits' => 'Menenangkan hati dan memperbaiki hubungan dengan Allah',
                        'context' => 'Dibaca saat merasa gelisah atau cemas',
                        'source' => 'HR. Muslim',
                        'repeat_count' => 3,
                        'emotional_tags' => ['ketenangan', 'perbaikan', 'kedamaian'],
                        'is_featured' => true
                    ],
                    [
                        'title' => 'Doa Menghilangkan Kesedihan',
                        'arabic_text' => 'اللَّهُمَّ إِنِّي عَبْدُكَ ابْنُ عَبْدِكَ ابْنُ أَمَتِكَ',
                        'latin_text' => 'Allahumma innii \'abduka ibnu \'abdika ibnu amatika',
                        'indonesian_translation' => 'Ya Allah, sesungguhnya aku adalah hamba-Mu, anak dari hamba-Mu',
                        'benefits' => 'Menghilangkan kesedihan dan kecemasan',
                        'context' => 'Dibaca saat merasa sedih atau tertekan',
                        'source' => 'HR. Ahmad',
                        'repeat_count' => 1,
                        'emotional_tags' => ['kesedihan', 'kelegaan', 'harapan'],
                        'is_featured' => true
                    ]
                ];
                break;

            case 'Doa Perlindungan':
                $dzikirItems = [
                    [
                        'title' => 'Ayat Kursi',
                        'arabic_text' => 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
                        'latin_text' => 'Allahu laa ilaaha illa huwal hayyul qayyuum',
                        'indonesian_translation' => 'Allah, tidak ada Tuhan selain Dia, Yang Maha Hidup dan Maha Berdiri Sendiri',
                        'benefits' => 'Perlindungan terbaik dari segala gangguan',
                        'context' => 'Dibaca setelah shalat dan sebelum tidur',
                        'source' => 'QS. Al-Baqarah: 255',
                        'repeat_count' => 1,
                        'emotional_tags' => ['perlindungan', 'keamanan', 'kekuatan'],
                        'is_featured' => true
                    ],
                    [
                        'title' => 'Surah Al-Ikhlas',
                        'arabic_text' => 'قُلْ هُوَ اللَّهُ أَحَدٌ، اللَّهُ الصَّمَدُ',
                        'latin_text' => 'Qul huwallaahu ahad, Allaahush-shamad',
                        'indonesian_translation' => 'Katakanlah: Dialah Allah Yang Maha Esa, Allah tempat bergantung segala sesuatu',
                        'benefits' => 'Bernilai seperti sepertiga Al-Quran, memberikan perlindungan',
                        'context' => 'Dibaca 3 kali setelah shalat Maghrib dan Subuh',
                        'source' => 'QS. Al-Ikhlas',
                        'repeat_count' => 3,
                        'emotional_tags' => ['perlindungan', 'tauhid', 'kedamaian'],
                        'is_featured' => true
                    ]
                ];
                break;

            case 'Doa Rezeki':
                $dzikirItems = [
                    [
                        'title' => 'Doa Memohon Rezeki Halal',
                        'arabic_text' => 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ',
                        'latin_text' => 'Allahumma ikfinii bi halaalika \'an haraamika',
                        'indonesian_translation' => 'Ya Allah, cukupkanlah aku dengan rezeki halal-Mu dari yang haram',
                        'benefits' => 'Membuka pintu rezeki yang halal dan berkah',
                        'context' => 'Dibaca saat memohon rezeki atau pekerjaan',
                        'source' => 'HR. Tirmidzi',
                        'repeat_count' => 7,
                        'emotional_tags' => ['rezeki', 'keberkahan', 'halal'],
                        'is_featured' => true
                    ]
                ];
                break;

            case 'Doa Maaf':
                $dzikirItems = [
                    [
                        'title' => 'Sayyidul Istighfar',
                        'arabic_text' => 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ خَلَقْتَنِي',
                        'latin_text' => 'Allahumma anta rabbii laa ilaaha illa anta khalaqtanii',
                        'indonesian_translation' => 'Ya Allah, Engkau Tuhanku, tidak ada Tuhan selain Engkau, Engkau yang menciptakanku',
                        'benefits' => 'Doa istighfar terbaik, menghapus dosa-dosa',
                        'context' => 'Dibaca di pagi dan sore hari',
                        'source' => 'HR. Bukhari',
                        'repeat_count' => 1,
                        'emotional_tags' => ['ampunan', 'penyesalan', 'harapan'],
                        'is_featured' => true
                    ]
                ];
                break;
        }

        foreach ($dzikirItems as $dzikirData) {
            DzikirDoa::create([
                'dzikir_category_id' => $category->id,
                ...$dzikirData
            ]);
        }
    }
}
