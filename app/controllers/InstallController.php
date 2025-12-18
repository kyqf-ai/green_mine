<?php

namespace App\Controllers;

use App\Library\IndicatorData; // 将大数据量移至 Library 防止控制器过大

class InstallController extends ControllerBase
{
    public function indexAction()
    {
        $config = $this->getDi()->get('config');
        if (file_exists($config->database->dbname)) {
            $this->view->message = "系统已安装。如需重装，请手动删除 data/green_mine.db 文件。";
            $this->view->installed = true;
        } else {
            $this->view->installed = false;
        }
    }

    public function runAction()
    {
        if ($this->request->isPost()) {
            try {
                $db = $this->getDi()->get('db');

                // 1. 创建表结构
                $db->execute("
                    CREATE TABLE IF NOT EXISTS indicators (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        code TEXT,
                        parent_code TEXT,
                        name TEXT,
                        full_name TEXT,
                        level INTEGER,
                        standard_score REAL DEFAULT 0,
                        self_score REAL DEFAULT 0,
                        is_critical INTEGER DEFAULT 0,
                        description TEXT,
                        requirement TEXT,
                        scoring_criteria TEXT,
                        requirements TEXT, -- JSON
                        sort_order INTEGER,
                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
                    );
                ");

                $db->execute("
                    CREATE TABLE IF NOT EXISTS materials (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        indicator_code TEXT,
                        requirement_name TEXT,
                        file_name TEXT,
                        original_name TEXT,
                        file_path TEXT,
                        file_type TEXT,
                        file_size INTEGER,
                        upload_user TEXT,
                        upload_date DATETIME DEFAULT CURRENT_TIMESTAMP
                    );
                ");

                // 2. 导入数据 (从 Library 获取)
                $data = IndicatorData::getData();
                
                $db->begin();
                foreach ($data as $item) {
                    $sql = "INSERT INTO indicators (code, parent_code, level, name, full_name, description, requirement, scoring_criteria, standard_score, is_critical, sort_order, requirements) 
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    
                    $db->execute($sql, [
                        $item['code'],
                        $item['parent_code'],
                        $item['level'],
                        $item['name'],
                        $item['full_name'],
                        $item['description'] ?? '',
                        $item['requirement'] ?? '',
                        $item['scoring_criteria'] ?? '',
                        $item['standard_score'] ?? 0,
                        $item['is_critical'] ?? 0,
                        $item['sort_order'] ?? 0,
                        json_encode($item['requirements'] ?? [], JSON_UNESCAPED_UNICODE)
                    ]);
                }
                $db->commit();

                return $this->response->setJsonContent(['success' => true]);

            } catch (\Exception $e) {
                $db->rollback();
                return $this->response->setJsonContent(['success' => false, 'message' => $e->getMessage()]);
            }
        }
    }
}
