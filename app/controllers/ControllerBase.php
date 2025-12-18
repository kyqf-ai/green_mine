<?php

namespace App\Controllers;

use Phalcon\Mvc\Controller;

class ControllerBase extends Controller
{
    public function initialize()
    {
        // 1. Session 在服务容器注册时已自动启动，无需手动检查 isStarted
        
        // 2. 生成 CSRF Token (如果不存在)
        if (!$this->session->has('csrf_token')) {
            $this->session->set('csrf_token', bin2hex(random_bytes(32)));
        }

        // 3. 将 Token 传给所有视图
        // 这样在 Volt 模板中就可以直接使用 {{ csrf_token }} 变量了
        $this->view->setVar('csrf_token', $this->session->get('csrf_token'));
    }

    public function beforeExecuteRoute($dispatcher)
    {
        // 1. 检查数据库是否存在，不存在则跳转安装
        $config = $this->getDi()->get('config');
        $controller = $dispatcher->getControllerName();

        // 避免安装页面死循环
        if ($controller === 'install') {
            return true;
        }

        if (!file_exists($config->database->dbname)) {
            $this->response->redirect('install');
            return false;
        }

        // 2. 检查登录状态 (排除登录页)
        if ($controller !== 'index' && !$this->session->has('auth')) {
            $this->response->redirect('index');
            return false;
        }
        
        return true;
    }
}
