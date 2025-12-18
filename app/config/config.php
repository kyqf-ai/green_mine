
<?php

return new \Phalcon\Config\Config([
    'database' => [
        'adapter' => 'Sqlite',
        'dbname'  => BASE_PATH . '/data/green_mine.db',
    ],
    'application' => [
        'appDir'         => APP_PATH . '/',
        'controllersDir' => APP_PATH . '/controllers/',
        'modelsDir'      => APP_PATH . '/models/',
        'migrationsDir'  => APP_PATH . '/migrations/',
        'viewsDir'       => APP_PATH . '/views/',
        'libraryDir'     => APP_PATH . '/library/',
        'cacheDir'       => BASE_PATH . '/cache/',
        'baseUri'        => '/',
        // 管理员账号配置
        'admin_user'     => 'admin',
        'admin_pass'     => 'greenmine2025',
    ],
    'upload' => [
        'dir' => BASE_PATH . '/public/uploads/',
        'max_size' => 50 * 1024 * 1024, // 50MB
        'allowed_types' => ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'zip', 'rar']
    ]
]);
