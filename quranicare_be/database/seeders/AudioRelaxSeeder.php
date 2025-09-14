<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\AudioCategory;
use App\Models\AudioRelax;

class AudioRelaxSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create audio categories
        $categories = [
            [
                'name' => 'Tilawah Al-Quran',
                'description' => 'Bacaan Al-Quran dengan suara merdu untuk ketenangan jiwa',
                'icon' => 'quran_audio.png',
                'color_code' => '#2ECC71',
                'is_active' => true
            ],
            [
                'name' => 'Dzikir dan Doa',
                'description' => 'Audio dzikir dan doa-doa pilihan untuk ketenangan hati',
                'icon' => 'dzikir_audio.png',
                'color_code' => '#3498DB',
                'is_active' => true
            ],
            [
                'name' => 'Suara Alam',
                'description' => 'Suara alam yang menenangkan untuk relaksasi',
                'icon' => 'nature_audio.png',
                'color_code' => '#1ABC9C',
                'is_active' => true
            ],
            [
                'name' => 'Musik Islami',
                'description' => 'Musik dan nasyid Islami yang menyejukkan hati',
                'icon' => 'islamic_music.png',
                'color_code' => '#9B59B6',
                'is_active' => true
            ],
            [
                'name' => 'Murottal',
                'description' => 'Murottal Al-Quran dari berbagai qari terkenal',
                'icon' => 'murottal.png',
                'color_code' => '#E74C3C',
                'is_active' => true
            ]
        ];

        foreach ($categories as $categoryData) {
            $category = AudioCategory::create($categoryData);
            $this->createAudioForCategory($category);
        }
    }

    private function createAudioForCategory(AudioCategory $category)
    {
        $audios = [];

        switch ($category->name) {
            case 'Tilawah Al-Quran':
                $audios = [
                    [
                        'title' => 'Surah Al-Fatihah - Sheikh Abdul Rahman Al-Sudais',
                        'description' => 'Bacaan Surah Al-Fatihah dengan suara merdu Sheikh Abdul Rahman Al-Sudais',
                        'audio_path' => 'audio/tilawah/al_fatiha_sudais.mp3',
                        'duration_seconds' => 120,
                        'thumbnail_path' => 'thumbnails/al_fatiha.jpg',
                        'artist' => 'Sheikh Abdul Rahman Al-Sudais',
                        'download_count' => 0,
                        'play_count' => 0,
                        'rating' => 0,
                        'rating_count' => 0,
                        'is_premium' => false,
                        'is_active' => true
                    ],
                    [
                        'title' => 'Surah Al-Ikhlas - Sheikh Saad Al-Ghamdi',
                        'description' => 'Bacaan Surah Al-Ikhlas dengan suara Sheikh Saad Al-Ghamdi',
                        'audio_path' => 'audio/tilawah/al_ikhlas_ghamdi.mp3',
                        'duration_seconds' => 60,
                        'thumbnail_path' => 'thumbnails/al_ikhlas.jpg',
                        'artist' => 'Sheikh Saad Al-Ghamdi',
                        'download_count' => 0,
                        'play_count' => 0,
                        'rating' => 0,
                        'rating_count' => 0,
                        'is_premium' => false,
                        'is_active' => true
                    ]
                ];
                break;

            case 'Dzikir dan Doa':
                $audios = [
                    [
                        'title' => 'Dzikir Subhanallah 100x',
                        'description' => 'Dzikir Subhanallah diulang 100 kali dengan irama yang menenangkan',
                        'audio_path' => 'audio/dzikir/subhanallah_100x.mp3',
                        'duration_seconds' => 300,
                        'thumbnail_path' => 'thumbnails/subhanallah.jpg',
                        'artist' => 'Ustadz Abdullah',
                        'download_count' => 0,
                        'play_count' => 0,
                        'rating' => 0,
                        'rating_count' => 0,
                        'is_premium' => false,
                        'is_active' => true
                    ]
                ];
                break;

            case 'Suara Alam':
                $audios = [
                    [
                        'title' => 'Suara Hujan Gerimis',
                        'description' => 'Suara hujan gerimis yang menenangkan untuk relaksasi',
                        'audio_path' => 'audio/nature/rain_light.mp3',
                        'duration_seconds' => 1800,
                        'thumbnail_path' => 'thumbnails/rain.jpg',
                        'artist' => null,
                        'download_count' => 0,
                        'play_count' => 0,
                        'rating' => 0,
                        'rating_count' => 0,
                        'is_premium' => false,
                        'is_active' => true
                    ]
                ];
                break;

            case 'Musik Islami':
                $audios = [
                    [
                        'title' => 'Shalawat Badar',
                        'description' => 'Shalawat Badar dengan melodi yang menyentuh hati',
                        'audio_path' => 'audio/islamic_music/shalawat_badar.mp3',
                        'duration_seconds' => 480,
                        'thumbnail_path' => 'thumbnails/shalawat_badar.jpg',
                        'artist' => 'Habib Syech bin Abdul Qodir Assegaf',
                        'download_count' => 0,
                        'play_count' => 0,
                        'rating' => 0,
                        'rating_count' => 0,
                        'is_premium' => false,
                        'is_active' => true
                    ]
                ];
                break;

            case 'Murottal':
                $audios = [
                    [
                        'title' => 'Murottal Surah Ar-Rahman - Sheikh Abdul Basit',
                        'description' => 'Murottal Surah Ar-Rahman dengan bacaan yang sangat merdu',
                        'audio_path' => 'audio/murottal/ar_rahman_abdul_basit.mp3',
                        'duration_seconds' => 900,
                        'thumbnail_path' => 'thumbnails/ar_rahman.jpg',
                        'artist' => 'Sheikh Abdul Basit Abdul Samad',
                        'download_count' => 0,
                        'play_count' => 0,
                        'rating' => 0,
                        'rating_count' => 0,
                        'is_premium' => false,
                        'is_active' => true
                    ]
                ];
                break;
        }

        foreach ($audios as $audioData) {
            AudioRelax::create([
                'audio_category_id' => $category->id,
                ...$audioData
            ]);
        }
    }
}