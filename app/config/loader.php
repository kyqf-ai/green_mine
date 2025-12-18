<?php

// Phalcon 5.0+ 使用 Phalcon\Autoload\Loader
$loader = new \Phalcon\Autoload\Loader();

$loader->setNamespaces([
    'App\Controllers' => $config->application->controllersDir,
    'App\Models'      => $config->application->modelsDir,
    'App\Library'     => $config->application->libraryDir,
]);

$loader->register();
