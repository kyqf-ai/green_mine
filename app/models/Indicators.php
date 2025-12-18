<?php

namespace App\Models;

use Phalcon\Mvc\Model;

class Indicators extends Model
{
    public $id;
    public $code;
    public $parent_code;
    public $name;
    public $full_name;
    public $level;
    public $standard_score;
    public $self_score;
    public $requirements; // JSON 存储
    public $is_critical;

    public function initialize()
    {
        $this->setSource('indicators');
    }
}
