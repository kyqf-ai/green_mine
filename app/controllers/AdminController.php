<?php

namespace App\Controllers;

use App\Models\Indicators;

class AdminController extends ControllerBase
{
    public function initialize()
    {
        parent::initialize();
        // 确保只有登录用户能访问
        if (!$this->session->has('auth')) {
            $this->response->redirect('index');
        }
    }

    // 显示管理主页 (加载视图)
    public function indexAction()
    {
        // 传递数据给视图，用于初始化 jsTree 或表格
        $this->view->setVar('title', '指标配置管理');
    }

    // === API 接口部分 (返回 JSON) ===

    // 获取指标列表 (用于左侧树)
    public function listAction()
    {
        $this->view->disable();
        $indicators = Indicators::find([
            'order' => 'sort_order ASC, code ASC'
        ])->toArray();
        
        return $this->response->setJsonContent(['success' => true, 'data' => $indicators]);
    }

    // 获取单个指标详情
    public function getAction()
    {
        $this->view->disable();
        $id = $this->request->getPost('id', 'int');
        $indicator = Indicators::findFirstById($id);
        
        if ($indicator) {
            return $this->response->setJsonContent(['success' => true, 'data' => $indicator]);
        }
        return $this->response->setJsonContent(['success' => false, 'message' => '指标不存在']);
    }

    // 保存指标 (新增或修改)
    public function saveAction()
    {
        $this->view->disable();
        
        // 简单的 CSRF 检查
        if ($this->request->isPost()) {
             // 建议复用 ApiController 的检查逻辑，或在此处添加
        }

        $id = $this->request->getPost('id', 'int');
        
        if ($id) {
            $indicator = Indicators::findFirstById($id);
            if (!$indicator) {
                return $this->response->setJsonContent(['success' => false, 'message' => '编辑的指标不存在']);
            }
        } else {
            $indicator = new Indicators();
            // 新增时检查 code 是否重复
            $code = $this->request->getPost('code', 'string');
            if (Indicators::count(['code = ?0', 'bind' => [$code]]) > 0) {
                return $this->response->setJsonContent(['success' => false, 'message' => '指标代码已存在']);
            }
        }

        // 批量赋值
        $indicator->code = $this->request->getPost('code', 'string');
        $indicator->parent_code = $this->request->getPost('parent_code', 'string') ?: null;
        $indicator->name = $this->request->getPost('name', 'string');
        $indicator->full_name = $this->request->getPost('full_name', 'string');
        $indicator->level = $this->request->getPost('level', 'int');
        $indicator->type = $this->request->getPost('type', 'string') ?: 'improvement';
        $indicator->description = $this->request->getPost('description', 'string');
        $indicator->requirement = $this->request->getPost('requirement', 'string');
        $indicator->scoring_criteria = $this->request->getPost('scoring_criteria', 'string');
        $indicator->standard_score = $this->request->getPost('standard_score', 'float');
        $indicator->is_critical = $this->request->getPost('is_critical', 'int') ? 1 : 0;
        $indicator->requirements = $this->request->getPost('requirements', 'string') ?: '[]'; // JSON 字符串

        if ($indicator->save()) {
            return $this->response->setJsonContent(['success' => true]);
        }
        
        return $this->response->setJsonContent([
            'success' => false, 
            'message' => implode('; ', $indicator->getMessages())
        ]);
    }

    // 删除指标
    public function deleteAction()
    {
        $this->view->disable();
        $id = $this->request->getPost('id', 'int');
        $indicator = Indicators::findFirstById($id);

        if ($indicator) {
            // 检查是否有子指标
            $count = Indicators::count([
                'parent_code = ?0',
                'bind' => [$indicator->code]
            ]);
            if ($count > 0) {
                return $this->response->setJsonContent(['success' => false, 'message' => '请先删除下级子指标']);
            }

            if ($indicator->delete()) {
                return $this->response->setJsonContent(['success' => true]);
            }
        }
        return $this->response->setJsonContent(['success' => false, 'message' => '删除失败']);
    }
}
