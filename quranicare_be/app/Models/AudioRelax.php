<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class AudioRelax extends Model
{
    use HasFactory;

    protected $table = 'audio_relax';

    protected $fillable = [
        'audio_category_id',
        'title',
        'description',
        'audio_path',
        'duration_seconds',
        'thumbnail_path',
        'artist',
        'download_count',
        'play_count',
        'rating',
        'rating_count',
        'is_premium',
        'is_active'
    ];

    protected $casts = [
        'is_premium' => 'boolean',
        'is_active' => 'boolean',
        'duration_seconds' => 'integer',
        'download_count' => 'integer',
        'play_count' => 'integer',
        'rating_count' => 'integer',
        'rating' => 'decimal:2'
    ];

    public function category()
    {
        return $this->belongsTo(AudioCategory::class, 'audio_category_id');
    }

    public function incrementPlayCount()
    {
        $this->increment('play_count');
    }
}
