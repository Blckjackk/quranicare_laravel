<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('journals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('quran_ayah_id')->nullable()->constrained()->onDelete('set null');
            $table->string('title');
            $table->text('content');
            $table->text('reflection')->nullable(); // Personal reflection on the ayah
            $table->enum('mood_after', ['senang', 'sedih', 'biasa_saja', 'marah', 'murung', 'tenang', 'bersyukur'])->nullable();
            $table->json('tags')->nullable(); // Array of tags for categorization
            $table->boolean('is_private')->default(true);
            $table->boolean('is_favorite')->default(false);
            $table->date('journal_date');
            $table->timestamps();
            
            $table->index(['user_id', 'journal_date']);
            $table->index(['user_id', 'quran_ayah_id']);
            // Fulltext index removed - can be added separately if needed
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('journals');
    }
};
