<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class DzikirDoa extends Model
{
    use HasFactory;

    protected $table = 'dzikir_doa';
    
    protected $fillable = [
        'dzikir_category_id',
        'title',
        'arabic_text',
        'latin_text',
        'indonesian_translation',
        'benefits',
        'context',
        'source',
        'repeat_count',
        'emotional_tags',
        'is_featured'
    ];

    protected $casts = [
        'emotional_tags' => 'array',
        'is_featured' => 'boolean',
        'repeat_count' => 'integer'
    ];

    public function category()
    {
        return $this->belongsTo(DzikirCategory::class, 'dzikir_category_id');
    }
}
