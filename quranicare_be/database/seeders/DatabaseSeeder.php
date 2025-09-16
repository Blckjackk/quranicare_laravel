<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->command->info('🌟 Starting QuraniCare Database Seeding...');
        
        // Seeding order is important due to foreign key constraints
        $seeders = [
            // Core authentication and user data
            AdminSeeder::class,
            UserSeeder::class,
            
            // Breathing exercises data
            BreathingExerciseSeeder::class,
            
            // Dzikir and Islamic prayers
            DzikirSeeder::class,
            
            // Psychology and learning materials
            PsychologyMaterialSeeder::class,
            
            // Audio relaxation content
            AudioRelaxSeeder::class,
            
            // Notifications system
            NotificationSeeder::class,
            
            // Complete Quran data (this might take some time due to API calls)
            QuranSeeder::class,
        ];

        foreach ($seeders as $seeder) {
            $seederName = class_basename($seeder);
            $this->command->info("📄 Running {$seederName}...");
            
            try {
                $this->call($seeder);
                $this->command->info("✅ {$seederName} completed successfully!");
            } catch (\Exception $e) {
                $this->command->error("❌ {$seederName} failed: " . $e->getMessage());
                $this->command->warn("Continuing with next seeder...");
            }
        }
        
        $this->command->info('');
        $this->command->info('🎉 QuraniCare Database Seeding Completed!');
        $this->command->info('');
        $this->command->info('📋 Summary of seeded data:');
        $this->command->info('👨‍💼 Admin Users: 5 accounts created');
        $this->command->info('👥 Sample Users: 10 accounts created');
        $this->command->info('🫁 Breathing Exercises: 4 categories with multiple exercises');
        $this->command->info('🤲 Dzikir Collections: 6 categories with authentic Islamic prayers');
        $this->command->info('📚 Psychology Materials: 6 categories with Islamic psychology content');
        $this->command->info('🎵 Audio Relaxation: 5 categories with Islamic audio content');
        $this->command->info('� Notifications: 8 sample notifications created');
        $this->command->info('�📖 Quran Data: Complete 114 surahs with verses (from API)');
        $this->command->info('');
        $this->command->info('🔑 Admin Login Credentials:');
        $this->command->info('   Email: superadmin@quranicare.com');
        $this->command->info('   Password: admin123');
        $this->command->info('');
        $this->command->info('👤 Sample User Login:');
        $this->command->info('   Email: abdullah.rahman@email.com');
        $this->command->info('   Password: password123');
    }
}
