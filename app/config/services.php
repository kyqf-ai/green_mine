<?php

use Phalcon\Mvc\View;
use Phalcon\Mvc\View\Engine\Volt;
use Phalcon\Mvc\Url as UrlProvider;
use Phalcon\Db\Adapter\Pdo\Sqlite;
use Phalcon\Session\Manager as SessionManager;
use Phalcon\Session\Adapter\Stream as SessionAdapter;
use Phalcon\Mvc\Dispatcher;

// 1. Shared Configuration
$di->setShared('config', function () {
    return include APP_PATH . '/config/config.php';
});

// 2. Database Connection
$di->setShared('db', function () {
    $config = $this->get('config');
    
    $dbPath = $config->database->dbname;
    $dbDir = dirname($dbPath);
    if (!is_dir($dbDir)) {
        mkdir($dbDir, 0755, true);
    }

    return new Sqlite([
        'dbname' => $dbPath,
    ]);
});

// 3. View Setup (Volt Engine)
$di->setShared('view', function () {
    $config = $this->get('config');

    $view = new View();
    $view->setViewsDir($config->application->viewsDir);

// ...
    $view->registerEngines([
        '.volt' => function ($view) {
            $config = $this->get('config');

            $volt = new Volt($view, $this);
            $volt->setOptions([
                'path' => $config->application->cacheDir,
                'separator' => '_'
            ]);
            
            // 获取编译器对象
            $compiler = $volt->getCompiler();
            
            // 注册必要的 PHP 函数供模板使用
            $compiler->addFunction('php_version', 'phpversion'); // 映射 php_version -> phpversion
            $compiler->addFunction('extension_loaded', 'extension_loaded');
            $compiler->addFunction('date', 'date');
            $compiler->addFunction('is_writable', 'is_writable');

            return $volt;
        },
        '.phtml' => \Phalcon\Mvc\View\Engine\Php::class
    ]);
// ...

    return $view;
});

// 4. URL Provider
$di->setShared('url', function () {
    $config = $this->get('config');
    $url = new UrlProvider();
    $url->setBaseUri($config->application->baseUri);
    return $url;
});

// 5. Session
$di->setShared('session', function () {
    $session = new SessionManager();
    $files = new SessionAdapter([
        'savePath' => sys_get_temp_dir(),
    ]);
    $session->setAdapter($files);
    $session->start();
    return $session;
});

// 6. Dispatcher (Fix for "IndexController handler class cannot be loaded")
$di->setShared('dispatcher', function () {
    $dispatcher = new Dispatcher();
    $dispatcher->setDefaultNamespace('App\Controllers');
    return $dispatcher;
});
