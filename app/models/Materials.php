<?php

namespace App\Models;

use Phalcon\Mvc\Model;

class Materials extends Model
{
    public $id;
    public $indicator_code;
    public $file_name;
    public $file_path;
    public $upload_date;

    public function initialize()
    {
        $this->setSource('materials');
        // 自动设置上传时间
        $this->skipAttributesOnCreate(['upload_date']);
    }
}
