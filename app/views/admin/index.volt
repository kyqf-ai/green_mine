<!DOCTYPE html>
<html lang="zh-CN" data-theme="default">
<head>
    <meta charset="UTF-8">
    <title>指标配置 - 绿色矿山系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="{{ url('css/style.css') }}" rel="stylesheet">
    <style>
        /* 后台特定样式微调 */
        .admin-sidebar { width: 300px; background: white; border-right: 1px solid #dee2e6; display: flex; flex-direction: column; }
        .node-item { padding: 8px 12px; cursor: pointer; font-size: 0.9rem; border-bottom: 1px solid #f8f9fa; }
        .node-item:hover { background-color: #f1f5f9; color: var(--c-p); }
        .node-item.active { background-color: #e0f2fe; color: #0284c7; font-weight: bold; border-left: 3px solid #0284c7; }
        .badge-level { font-size: 0.75rem; background: #e2e8f0; color: #64748b; padding: 2px 6px; border-radius: 4px; margin-right: 8px; }
    </style>
</head>
<body>
    <div id="app" style="height: 100vh; display: flex; flex-direction: column;">
        <!-- 顶部导航 -->
        <nav class="navbar shadow-sm bg-dark" style="background: #1e293b !important; color: white;">
            <div class="container-fluid">
                <span class="navbar-brand text-white mb-0 h1"><i class="fas fa-cogs me-2"></i>指标配置管理</span>
                <div>
                    <a href="{{ url('dashboard') }}" class="btn btn-sm btn-outline-light"><i class="fas fa-arrow-left me-1"></i>返回前台</a>
                </div>
            </div>
        </nav>

        <!-- 主体内容 -->
        <div style="flex: 1; display: flex; overflow: hidden;">
            <!-- 左侧列表 -->
            <div class="admin-sidebar">
                <div class="p-2 border-bottom d-flex gap-2">
                    <button class="btn btn-primary btn-sm w-100" onclick="createNode()"><i class="fas fa-plus"></i> 新增指标</button>
                    <button class="btn btn-light btn-sm border" onclick="loadTree()" title="刷新"><i class="fas fa-sync-alt"></i></button>
                </div>
                <div style="flex: 1; overflow-y: auto;" id="treeRoot">
                    <!-- JS 渲染列表 -->
                    <div class="text-center mt-5 text-muted"><div class="spinner-border spinner-border-sm"></div> 加载中...</div>
                </div>
            </div>

            <!-- 右侧编辑区 -->
            <div style="flex: 1; background: #f8fafc; padding: 20px; overflow-y: auto;">
                <div class="card shadow-sm" id="editorCard" style="display:none; max-width: 900px; margin: 0 auto;">
                    <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                        <h5 class="mb-0 fw-bold text-primary" id="editorTitle">编辑指标</h5>
                        <button class="btn btn-outline-danger btn-sm" onclick="deleteNode()" id="btnDelete"><i class="fas fa-trash"></i> 删除此指标</button>
                    </div>
                    <div class="card-body p-4">
                        <form id="editForm" onsubmit="saveData(event)">
                            <input type="hidden" name="id">
                            
                            <div class="row g-3 mb-3">
                                <div class="col-md-3">
                                    <label class="form-label small fw-bold">指标代码 *</label>
                                    <input type="text" name="code" class="form-control" required placeholder="如 A1.1">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label small fw-bold">父级代码</label>
                                    <input type="text" name="parent_code" class="form-control" placeholder="顶级留空">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label small fw-bold">层级 (Level)</label>
                                    <input type="number" name="level" class="form-control" value="0">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label small fw-bold">类型</label>
                                    <select name="type" class="form-select">
                                        <option value="improvement">提升型</option>
                                        <option value="constraint">约束性</option>
                                        <option value="prerequisite">先决条件</option>
                                    </select>
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-4">
                                    <label class="form-label small fw-bold">短名称 *</label>
                                    <input type="text" name="name" class="form-control" required>
                                </div>
                                <div class="col-md-8">
                                    <label class="form-label small fw-bold">完整名称</label>
                                    <input type="text" name="full_name" class="form-control">
                                </div>
                            </div>

                            <div class="p-3 bg-light rounded border mb-3">
                                <div class="row g-3">
                                    <div class="col-md-3">
                                        <label class="form-label small">标准分</label>
                                        <input type="number" step="0.1" name="standard_score" class="form-control form-control-sm">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label small">排序值</label>
                                        <input type="number" name="sort_order" class="form-control form-control-sm" value="0">
                                    </div>
                                    <div class="col-md-6 d-flex align-items-center mt-4">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" name="is_critical" value="1" id="chkCritical">
                                            <label class="form-check-label" for="chkCritical">一票否决项 (关键指标)</label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-muted">描述 (Description)</label>
                                <textarea name="description" class="form-control" rows="2"></textarea>
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold text-muted">要求 (Requirement)</label>
                                    <textarea name="requirement" class="form-control" rows="3"></textarea>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold text-muted">评分标准 (Scoring)</label>
                                    <textarea name="scoring_criteria" class="form-control" rows="3"></textarea>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-muted font-monospace">资料清单配置 (JSON格式)</label>
                                <textarea name="requirements" class="form-control font-monospace small bg-light" rows="3" placeholder='例如: [{"type":"文件","name":"采矿许可证"}]'></textarea>
                                <div class="form-text">请严格遵守 JSON 格式，用于前台生成上传选项。</div>
                            </div>

                            <div class="text-end border-top pt-3">
                                <button type="submit" class="btn btn-primary px-4"><i class="fas fa-save me-1"></i> 保存配置</button>
                            </div>
                        </form>
                    </div>
                </div>
                
                <div id="emptyTip" class="text-center text-muted mt-5 pt-5">
                    <i class="fas fa-mouse-pointer fa-3x mb-3 opacity-25"></i>
                    <p>请点击左侧列表选择指标，或点击新增按钮</p>
                </div>
            </div>
        </div>
    </div>

    <!-- JS 逻辑 -->
    <script>
        const API = {
            list: "{{ url('admin/list') }}",
            get: "{{ url('admin/get') }}",
            save: "{{ url('admin/save') }}",
            del: "{{ url('admin/delete') }}"
        };

        document.addEventListener('DOMContentLoaded', loadTree);

        async function loadTree() {
            const res = await fetch(API.list).then(r=>r.json());
            const div = document.getElementById('treeRoot');
            div.innerHTML = '';
            
            if(res.success) {
                res.data.forEach(item => {
                    const el = document.createElement('div');
                    el.className = 'node-item';
                    el.innerHTML = `<span class="badge-level">L${item.level}</span> <span class="font-monospace fw-bold me-2">${item.code}</span> ${item.name}`;
                    el.onclick = () => loadDetail(item.id, el);
                    div.appendChild(el);
                });
            }
        }

        async function loadDetail(id, el) {
            // 高亮处理
            document.querySelectorAll('.node-item').forEach(e=>e.classList.remove('active'));
            if(el) el.classList.add('active');

            const fd = new FormData();
            fd.append('id', id);
            
            const res = await fetch(API.get, { method:'POST', body:fd }).then(r=>r.json());
            
            if(res.success) {
                showEditor(res.data);
            } else {
                alert(res.message);
            }
        }

        function createNode() {
            document.querySelectorAll('.node-item').forEach(e=>e.classList.remove('active'));
            showEditor({}); // 空对象触发新增模式
        }

        function showEditor(data) {
            document.getElementById('emptyTip').style.display = 'none';
            document.getElementById('editorCard').style.display = 'block';
            
            const isEdit = !!data.id;
            document.getElementById('editorTitle').innerText = isEdit ? '编辑指标' : '新增指标';
            document.getElementById('btnDelete').style.display = isEdit ? 'block' : 'none';

            const f = document.getElementById('editForm');
            f.reset();
            f.id.value = data.id || '';
            
            // 自动填充字段
            ['code','parent_code','level','type','name','full_name','standard_score','sort_order','description','requirement','scoring_criteria'].forEach(key => {
                if(f[key]) f[key].value = data[key] || '';
            });
            
            // 特殊字段处理
            if(f.is_critical) f.is_critical.checked = (data.is_critical == 1);
            if(f.requirements) {
                // 如果是对象/数组转字符串
                let reqStr = data.requirements;
                if(typeof reqStr === 'object') reqStr = JSON.stringify(reqStr);
                f.requirements.value = reqStr || '[]';
            }
        }

        async function saveData(e) {
            e.preventDefault();
            const fd = new FormData(e.target);
            
            // 简单的 JSON 校验
            try {
                JSON.parse(fd.get('requirements'));
            } catch(e) {
                alert('资料清单 JSON 格式有误，请检查！');
                return;
            }

            const res = await fetch(API.save, { method:'POST', body:fd }).then(r=>r.json());
            if(res.success) {
                alert('保存成功');
                loadTree(); // 刷新列表
                if(!fd.get('id')) f.reset(); // 如果是新增，重置表单
            } else {
                alert('保存失败: ' + res.message);
            }
        }

        async function deleteNode() {
            const id = document.getElementById('editForm').id.value;
            if(!id) return;
            
            if(!confirm('确定要删除此指标吗？此操作不可恢复。')) return;
            
            const fd = new FormData();
            fd.append('id', id);
            const res = await fetch(API.del, { method:'POST', body:fd }).then(r=>r.json());
            
            if(res.success) {
                alert('删除成功');
                document.getElementById('editorCard').style.display = 'none';
                document.getElementById('emptyTip').style.display = 'block';
                loadTree();
            } else {
                alert('删除失败: ' + res.message);
            }
        }
    </script>
</body>
</html>
