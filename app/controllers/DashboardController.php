<?php

namespace App\Controllers;

use App\Models\Indicators;
use App\Models\Materials;

class DashboardController extends ControllerBase
{
    public function indexAction()
    {
        // 1. 获取所有指标构建树形结构
        $indicators = Indicators::find([
            'order' => 'sort_order ASC, code ASC'
        ])->toArray();

        // 2. 获取哪些指标有文件（用于前端显示红点或图标）
        $files = Materials::find([
            'columns' => 'DISTINCT indicator_code'
        ])->toArray();
        
        $hasFilesMap = array_column($files, 'indicator_code');

        // 构建 Tree
        $tree = $this->buildTree($indicators, $hasFilesMap);
        $this->view->tree = $tree;
    }

    private function buildTree(array $elements, array $hasFiles, $parentId = null)
    {
        $branch = [];
        foreach ($elements as $element) {
            // 注意：数据库中 parent_code 可能是 NULL 或空字符串
            if ($element['parent_code'] == $parentId) {
                $element['has_file'] = in_array($element['code'], $hasFiles);
                
                $children = $this->buildTree($elements, $hasFiles, $element['code']);
                if ($children) {
                    $element['children'] = $children;
                }
                $branch[] = $element;
            }
        }
        return $branch;
    }
}
