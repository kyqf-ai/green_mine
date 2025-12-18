<?php

namespace App\Controllers;

class IndexController extends ControllerBase
{
    public function indexAction()
    {
        // 如果已登录，跳转 Dashboard
        if ($this->session->has('auth')) {
            return $this->response->redirect('dashboard');
        }

        // 处理登录 POST
        if ($this->request->isPost()) {
            $username = $this->request->getPost('username', 'string');
            $password = $this->request->getPost('password', 'string');

            $config = $this->getDi()->get('config');

            if ($username === $config->application->admin_user && 
                $password === $config->application->admin_pass) {
                
                $this->session->set('auth', ['user' => $username]);
                return $this->response->redirect('dashboard');
            } else {
                $this->view->error = "账号或密码错误";
            }
        }
    }

    public function logoutAction()
    {
        $this->session->destroy();
        return $this->response->redirect('index');
    }
}
