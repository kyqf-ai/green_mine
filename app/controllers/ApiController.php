<?php

namespace App\Controllers;

use App\Models\Indicators;
use App\Models\Materials;

class ApiController extends ControllerBase
{
    public function initialize()
    {
        // 继承父类初始化 (确保 Session 启动)
        parent::initialize();
        
        $this->view->disable();
        $this->response->setContentType('application/json', 'UTF-8');
    }

    /**
     * 统一返回 JSON 格式
     * 同时兼容 {data: ...} 和平铺结构，防止前端 JS 取值失败
     */
    private function jsonResponse($success, $data = [], $msg = '')
    {
        $response = [
            'success' => $success,
            'message' => $msg,
            'data'    => $data
        ];

        // 兼容性平铺：将 data 中的关键字段提到第一层
        if (is_array($data)) {
            $response = array_merge($response, $data);
        }

        return $this->response->setJsonContent($response);
    }

    /**
     * 统一 CSRF 检查拦截器
     */
    public function beforeExecuteRoute($dispatcher)
    {
        // 继承父类检查 (如数据库是否存在)
        if (!parent::beforeExecuteRoute($dispatcher)) {
            return false;
        }

        // 仅对 POST 请求进行 CSRF 验证
        if ($this->request->isPost()) {
            $token = $this->request->getPost('csrf_token');
            $sessionToken = $this->session->get('csrf_token');

            if (!$token || $token !== $sessionToken) {
                // 返回 JSON 错误并终止执行
                $this->jsonResponse(false, [], '安全验证(CSRF)失败，请刷新页面重试')->send();
                return false; 
            }
        }
        return true;
    }

    // === 1. 获取指标详情 ===
    public function getDetailsAction()
    {
        $code = $this->request->getPost('code', 'string');
        if (!$code) return $this->jsonResponse(false, [], '缺少指标代码参数');

        $indicator = Indicators::findFirstByCode($code);
        if (!$indicator) return $this->jsonResponse(false, [], '未找到该指标');

        // 格式化 requirements (JSON -> Array)
        $indData = $indicator->toArray();
        $indData['requirements'] = json_decode($indData['requirements'] ?? '[]', true);

        // 获取关联文件
        $materials = Materials::find([
            'conditions' => 'indicator_code = :code:',
            'bind' => ['code' => $code],
            'order' => 'upload_date DESC'
        ])->toArray();

        // 补充文件 URL (供前端下载/预览)
        foreach ($materials as &$file) {
            // 假设文件存储在 public/uploads/CODE/FILENAME
            $file['file_path'] = '/uploads/' . $file['indicator_code'] . '/' . $file['file_name'];
            $file['file_url']  = $file['file_path']; // 兼容字段
        }

        return $this->jsonResponse(true, [
            'indicator' => $indData,
            'materials' => $materials,
            // 核心逻辑：Level 0 和 3 允许上传
            'is_leaf'   => ($indData['level'] == 0 || $indData['level'] == 3)
        ]);
    }

    // === 2. 获取首页统计 ===
    public function getStatsAction()
    {
        $db = $this->getDi()->get('db');
        
        // 统计末级指标 (Level 3)
        $totalIndicators = Indicators::count("level = 3");
        $totalFiles = Materials::count();
        
        // 完成度: 有文件的末级指标数量
        $completedRes = $db->fetchOne("SELECT COUNT(DISTINCT indicator_code) as c FROM materials");
        $completedCount = $completedRes['c'] ?? 0;

        // 分数统计
        $scoreRes = $db->fetchOne("SELECT SUM(self_score) as self, SUM(standard_score) as std FROM indicators WHERE level=3");
        $selfTotal = round($scoreRes['self'] ?? 0, 1);
        $stdTotal  = round($scoreRes['std'] ?? 0, 1);

        return $this->jsonResponse(true, [
            'stats' => [
                'total_indicators' => $totalIndicators,
                'total_files' => $totalFiles,
                'completion_rate' => $totalIndicators > 0 ? round(($completedCount / $totalIndicators) * 100, 1) : 0,
                'total_self_score' => $selfTotal,
                'total_standard_score' => $stdTotal,
                'score_ratio' => "{$selfTotal} / {$stdTotal}"
            ]
        ]);
    }

    // === 3. 更新自评分 ===
    public function updateScoreAction()
    {
        $code = $this->request->getPost('code', 'string');
        $score = $this->request->getPost('score', 'float');

        $indicator = Indicators::findFirstByCode($code);
        if (!$indicator) return $this->jsonResponse(false, [], '指标不存在');

        if ($score < 0) return $this->jsonResponse(false, [], '分数不能为负');
        if ($score > $indicator->standard_score) return $this->jsonResponse(false, [], '不能超过标准分');

        $indicator->self_score = $score;
        if ($indicator->save()) {
            return $this->jsonResponse(true, [], '评分已保存');
        }
        return $this->jsonResponse(false, [], '数据库保存失败');
    }

    // === 4. 文件上传 ===
    public function uploadAction()
    {
        if (!$this->request->hasFiles()) {
            return $this->jsonResponse(false, [], '未接收到文件');
        }

        $code = $this->request->getPost('indicator_code', 'string');
        $reqName = $this->request->getPost('requirement_name', 'string');
        $desc = $this->request->getPost('description', 'string');
        
        $config = $this->getDi()->get('config');
        // 物理路径: /path/to/project/public/uploads/CODE/
        $uploadBaseDir = BASE_PATH . '/public/uploads/';
        $targetDir = $uploadBaseDir . $code . '/';

        if (!is_dir($targetDir)) {
            if (!mkdir($targetDir, 0755, true)) {
                return $this->jsonResponse(false, [], '无法创建上传目录，请检查权限');
            }
        }

        $files = $this->request->getUploadedFiles();
        foreach ($files as $file) {
            $ext = strtolower($file->getExtension());
            // 简单校验类型
            $allowed = ['jpg','jpeg','png','gif','pdf','doc','docx','xls','xlsx','ppt','pptx','zip','rar'];
            if (!in_array($ext, $allowed)) {
                return $this->jsonResponse(false, [], "不支持的文件类型: .$ext");
            }

            // 生成唯一文件名
            $newFileName = date('YmdHis') . '_' . preg_replace('/[^\w\-\.]/u', '_', $file->getName());
            $targetPath = $targetDir . $newFileName;

            if ($file->moveTo($targetPath)) {
                $material = new Materials();
                $material->indicator_code = $code;
                $material->requirement_name = $reqName;
                $material->file_name = $newFileName;
                $material->original_name = $file->getName();
                // 数据库存相对路径或文件名均可，这里存相对 URL
                $material->file_path = $newFileName; 
                $material->file_size = $file->getSize();
                $material->file_type = $ext;
                $material->description = $desc;
                $material->upload_user = $this->session->get('auth')['user'] ?? 'admin';
                $material->save();
            } else {
                return $this->jsonResponse(false, [], '文件移动失败');
            }
        }

        return $this->jsonResponse(true, [], '上传成功');
    }

    // === 5. 删除文件 ===
    public function deleteFileAction()
    {
        $id = $this->request->getPost('file_id', 'int'); // 注意前端传参名
        if (!$id) $id = $this->request->getPost('id', 'int'); // 兼容

        $material = Materials::findFirstById($id);
        
        if ($material) {
            $code = $material->indicator_code;
            $name = $material->file_name;
            $filePath = BASE_PATH . '/public/uploads/' . $code . '/' . $name;
            
            if (file_exists($filePath)) {
                @unlink($filePath);
            }
            if ($material->delete()) {
                return $this->jsonResponse(true, [], '删除成功');
            }
        }
        return $this->jsonResponse(false, [], '文件不存在或删除失败');
    }
}
