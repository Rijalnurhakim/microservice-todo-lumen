<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Todo extends Model
{
    protected $fillable = [
        'title',
        'description',
        'completed',
        'user_id',
    ];

    protected $casts = [
        'completed' => 'boolean',
    ];
}
