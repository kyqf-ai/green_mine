<?php

use Phalcon\Di\FactoryDefault;
use Phalcon\Mvc\Application;

error_reporting(E_ALL);

define('BASE_PATH', dirname(__DIR__));
define('APP_PATH', BASE_PATH . '/app');

try {
    // 1. 初始化 DI 容器
    $di = new FactoryDefault();

    // 2. 加载服务 (Loader, Config, Db, View, etc.)
    // 注意：services.php 只是注册服务，不会自动返回 $config 变量
    include APP_PATH . '/config/services.php';

    // 【修正】主动从容器中获取 config，供 loader.php 使用
    $config = $di->get('config');

    // 3. 加载自动加载器 (现在 $config 可用了)
    include APP_PATH . '/config/loader.php';

    // 4. 处理请求
    $application = new Application($di);
    
    // 处理路由
    $response = $application->handle($_SERVER['REQUEST_URI']);
    $response->send();

} catch (\Exception $e) {
    echo "Phalcon Exception: ", $e->getMessage();
    echo "<br><pre>" . $e->getTraceAsString() . "</pre>";
}
