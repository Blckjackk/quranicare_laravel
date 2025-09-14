<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create Super Admin
        User::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@quranicare.com',
            'email_verified_at' => Carbon::now(),
            'password' => Hash::make('admin123'),
            'birth_date' => Carbon::parse('1990-01-01'),
            'gender' => 'male',
            'phone' => '+6281234567890',
            'profile_picture' => null,
            'bio' => 'Super Administrator untuk aplikasi QuraniCare',
            'preferred_language' => 'id',
            'is_active' => true,
            'last_login_at' => Carbon::now(),
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now()
        ]);

        // Create Content Manager
        User::create([
            'name' => 'Ahmad Fauzi',
            'email' => 'ahmad.fauzi@quranicare.com',
            'email_verified_at' => Carbon::now(),
            'password' => Hash::make('contentmanager123'),
            'birth_date' => Carbon::parse('1985-03-15'),
            'gender' => 'male',
            'phone' => '+6281234567891',
            'profile_picture' => null,
            'bio' => 'Content Manager untuk materi psikologi Islam dan konten edukatif',
            'preferred_language' => 'id',
            'is_active' => true,
            'last_login_at' => Carbon::now()->subDays(1),
            'created_at' => Carbon::now()->subMonths(2),
            'updated_at' => Carbon::now()->subDays(1)
        ]);

        // Create Moderator
        User::create([
            'name' => 'Siti Nurhaliza',
            'email' => 'siti.nurhaliza@quranicare.com',
            'email_verified_at' => Carbon::now(),
            'password' => Hash::make('moderator123'),
            'birth_date' => Carbon::parse('1988-07-22'),
            'gender' => 'female',
            'phone' => '+6281234567892',
            'profile_picture' => null,
            'bio' => 'Moderator komunitas dan pengawas interaksi user dalam aplikasi',
            'preferred_language' => 'id',
            'is_active' => true,
            'last_login_at' => Carbon::now()->subHours(5),
            'created_at' => Carbon::now()->subMonths(1),
            'updated_at' => Carbon::now()->subHours(5)
        ]);

        // Create Technical Admin
        User::create([
            'name' => 'Muhammad Ridwan',
            'email' => 'muhammad.ridwan@quranicare.com',
            'email_verified_at' => Carbon::now(),
            'password' => Hash::make('techadmin123'),
            'birth_date' => Carbon::parse('1992-11-10'),
            'gender' => 'male',
            'phone' => '+6281234567893',
            'profile_picture' => null,
            'bio' => 'Technical Administrator untuk maintenance sistem dan database',
            'preferred_language' => 'id',
            'is_active' => true,
            'last_login_at' => Carbon::now()->subHours(2),
            'created_at' => Carbon::now()->subWeeks(3),
            'updated_at' => Carbon::now()->subHours(2)
        ]);

        // Create Psychology Specialist
        User::create([
            'name' => 'Dr. Fatimah Al-Zahra',
            'email' => 'fatimah.alzahra@quranicare.com',
            'email_verified_at' => Carbon::now(),
            'password' => Hash::make('psychologist123'),
            'birth_date' => Carbon::parse('1980-05-18'),
            'gender' => 'female',
            'phone' => '+6281234567894',
            'profile_picture' => null,
            'bio' => 'Dokter Psikologi Islam, spesialis dalam konseling dan terapi berbasis nilai-nilai Islam',
            'preferred_language' => 'id',
            'is_active' => true,
            'last_login_at' => Carbon::now()->subDays(2),
            'created_at' => Carbon::now()->subMonths(3),
            'updated_at' => Carbon::now()->subDays(2)
        ]);

        $this->command->info('Admin users seeded successfully!');
        $this->command->info('Admin accounts created:');
        $this->command->info('1. Super Admin: superadmin@quranicare.com (admin123)');
        $this->command->info('2. Content Manager: ahmad.fauzi@quranicare.com (contentmanager123)');
        $this->command->info('3. Moderator: siti.nurhaliza@quranicare.com (moderator123)');
        $this->command->info('4. Technical Admin: muhammad.ridwan@quranicare.com (techadmin123)');
        $this->command->info('5. Psychology Specialist: fatimah.alzahra@quranicare.com (psychologist123)');
    }
}
