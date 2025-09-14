<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class AudioCategory extends Model
{
    use HasFactory;

    protected $table = 'audio_categories';

    protected $fillable = [
        'name',
        'description',
        'icon',
        'color_code',
        'is_active'
    ];

    protected $casts = [
        'is_active' => 'boolean'
    ];

    public function audioRelax()
    {
        return $this->hasMany(AudioRelax::class, 'audio_category_id');
    }
}
