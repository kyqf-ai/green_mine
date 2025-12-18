/**
 * Green Mine System Frontend Logic
 * Version: 2.0 (Phalcon Fix)
 * Description: 修复 API 通信与参数传递
 */

let currentCode = null;
// 获取布局中的 CSRF Token
const csrfTokenMeta = document.querySelector('meta[name="csrf-token"]');
const csrfToken = csrfTokenMeta ? csrfTokenMeta.getAttribute('content') : '';

document.addEventListener('DOMContentLoaded', () => {
    setTheme(localStorage.getItem('app_theme') || 'default');
    loadDashboard();
});

// 主题设置
function setTheme(t) {
    document.documentElement.setAttribute('data-theme', t);
    localStorage.setItem('app_theme', t);
}

// 侧边栏切换
function toggleSidebar() {
    document.getElementById('sidebar').classList.toggle('show');
    document.getElementById('overlay').classList.toggle('show');
}

// 树形菜单折叠
function toggleNode(toggleIcon, e) {
    e.stopPropagation();
    const wrapper = toggleIcon.closest('.tree-wrapper');
    const children = wrapper.querySelector('.tree-children');
    const typeIcon = wrapper.querySelector('.tree-icon-type i');
    
    if (children) {
        children.classList.toggle('show');
        toggleIcon.classList.toggle('expanded');
        if (typeIcon && typeIcon.classList.contains('fa-folder')) {
            if (children.classList.contains('show')) {
                typeIcon.classList.replace('fa-folder', 'fa-folder-open');
            } else {
                typeIcon.classList.replace('fa-folder-open', 'fa-folder');
            }
        }
    }
}

// 树节点点击
function handleNodeClick(el, e) {
    if (e.target.closest('.tree-toggle')) return;
    
    document.querySelectorAll('.tree-item').forEach(i => i.classList.remove('active'));
    el.classList.add('active');
    
    const children = el.nextElementSibling;
    const toggle = el.querySelector('.tree-toggle');
    if (children && !children.classList.contains('show') && toggle) {
        toggleNode(toggle, e);
    }
    if (window.innerWidth < 992) toggleSidebar();
    
    loadIndicator(el.dataset.code);
}

// API 通信核心函数
async function apiCall(action, data = {}) {
    const baseUrl = (typeof APP_CONFIG !== 'undefined' && APP_CONFIG.baseUrl) ? APP_CONFIG.baseUrl : '/';
    // 路由映射表
    const actionMap = {
        'get_dashboard_stats': 'getStats',
        'get_indicator_details': 'getDetails',
        'upload': 'upload',
        'delete': 'deleteFile',
        'update_self_score': 'updateScore'
    };
    
    const realAction = actionMap[action] || action;
    const url = baseUrl + 'api/' + realAction;

    let body;
    if (data instanceof FormData) {
        body = data;
        body.append('csrf_token', csrfToken); // FormData 追加 Token
    } else {
        body = new FormData();
        body.append('csrf_token', csrfToken); // 常规对象转 FormData 并追加 Token
        for (let k in data) body.append(k, data[k]);
    }

    try {
        const r = await fetch(url, {
            method: 'POST',
            body: body,
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        });
        
        // 解析响应
        const json = await r.json();
        
        // 统一返回处理：
        // 无论后端是否平铺，我们都统一结构返回给调用者
        if (json.success) {
            // 如果请求的是 stats，返回 stats 对象
            if (action === 'get_dashboard_stats') {
                return { success: true, stats: json.stats || json.data.stats || json.data };
            }
            // 默认合并 data 到结果中
            return { success: true, ...json.data, ...json }; 
        } else {
            return { success: false, message: json.message || '操作失败' };
        }
    } catch (e) {
        console.error("API Error:", e);
        showToast('error', '网络请求失败或服务器错误');
        return { success: false, message: 'Network Error' };
    }
}

// 图标样式映射
function getFileIcon(filename) {
    const ext = filename.split('.').pop().toLowerCase();
    const map = {
        'pdf': { icon: 'fa-file-pdf', color: '#ef4444', bg: '#fee2e2' },
        'doc': { icon: 'fa-file-word', color: '#3b82f6', bg: '#dbeafe' },
        'docx': { icon: 'fa-file-word', color: '#3b82f6', bg: '#dbeafe' },
        'xls': { icon: 'fa-file-excel', color: '#10b981', bg: '#d1fae5' },
        'xlsx': { icon: 'fa-file-excel', color: '#10b981', bg: '#d1fae5' },
        'ppt': { icon: 'fa-file-powerpoint', color: '#f97316', bg: '#ffedd5' },
        'pptx': { icon: 'fa-file-powerpoint', color: '#f97316', bg: '#ffedd5' },
        'jpg': { icon: 'fa-file-image', color: '#8b5cf6', bg: '#ede9fe' },
        'png': { icon: 'fa-file-image', color: '#8b5cf6', bg: '#ede9fe' },
        'zip': { icon: 'fa-file-archive', color: '#64748b', bg: '#f1f5f9' },
        'rar': { icon: 'fa-file-archive', color: '#64748b', bg: '#f1f5f9' }
    };
    return map[ext] || { icon: 'fa-file-alt', color: '#94a3b8', bg: '#f8fafc' };
}

// 加载仪表盘
async function loadDashboard() {
    currentCode = null;
    document.querySelectorAll('.tree-item').forEach(i => i.classList.remove('active'));
    
    const res = await apiCall('get_dashboard_stats');
    const div = document.getElementById('mainContent');
    
    if (!res.success) {
        div.innerHTML = `<div class="alert alert-danger">${res.message}</div>`;
        return;
    }
    
    const s = res.stats;
    div.innerHTML = `
        <div class="fade-in container-fluid px-0">
            <h4 class="mb-4 fw-bold text-primary"><i class="fas fa-chart-line me-2"></i>系统概览</h4>
            <div class="row g-4 mb-4">
                <div class="col-6 col-lg-3"><div class="card stat-card"><div class="icon-box"><i class="fas fa-list"></i></div><h3 class="fw-bold mb-1">${s.total_indicators}</h3><div class="text-muted small">指标总数</div></div></div>
                <div class="col-6 col-lg-3"><div class="card stat-card"><div class="icon-box" style="color:#10b981;background:#d1fae5"><i class="fas fa-file-invoice"></i></div><h3 class="fw-bold mb-1">${s.total_files}</h3><div class="text-muted small">已上传资料</div></div></div>
                <div class="col-6 col-lg-3"><div class="card stat-card"><div class="icon-box" style="color:#f59e0b;background:#fef3c7"><i class="fas fa-chart-pie"></i></div><h3 class="fw-bold mb-1">${s.completion_rate}%</h3><div class="text-muted small">资料完成度</div></div></div>
                <div class="col-6 col-lg-3"><div class="card stat-card"><div class="icon-box" style="color:#3b82f6;background:#dbeafe"><i class="fas fa-clipboard-check"></i></div><h3 class="fw-bold mb-1">${s.score_ratio}</h3><div class="text-muted small">自评/标准分</div></div></div>
            </div>
            <div class="card p-5 text-center border-0 bg-transparent opacity-50"><i class="fas fa-hand-point-left fa-3x mb-3 text-muted"></i><h5 class="text-muted">请从左侧选择指标查看详情</h5></div>
        </div>`;
}

// 加载指标详情
async function loadIndicator(code) {
    currentCode = code;
    const div = document.getElementById('mainContent');
    div.innerHTML = '<div class="text-center py-5"><div class="spinner-border text-primary"></div></div>';
    
    const res = await apiCall('get_indicator_details', { code });
    if (!res.success) {
        div.innerHTML = `<div class="alert alert-danger">${res.message}</div>`;
        return;
    }
    
    const d = res.indicator;
    const files = res.materials;
    const canUpload = (d.level == 0 || d.level == 3); // L0和L3可操作
    
    // 解析 requirements
    let requirements = [];
    try {
        requirements = typeof d.requirements === 'string' ? JSON.parse(d.requirements) : d.requirements;
    } catch(e) { requirements = []; }

    // 文件列表 HTML
    let fileListHtml = files.length ? files.map(f => {
        const style = getFileIcon(f.original_name);
        const safePath = encodeURI(f.file_url || f.file_path); 
        return `
        <div class="file-card">
            <div class="file-icon-wrapper" style="background:${style.bg}; color:${style.color}">
                <i class="fas ${style.icon}"></i>
            </div>
            <div class="flex-grow-1 overflow-hidden">
                <div class="fw-bold text-truncate" title="${f.original_name}">${f.original_name}</div>
                <div class="small text-muted text-truncate mt-1">
                    <i class="fas fa-tag me-1"></i>${f.requirement_name || '未分类'} 
                    <span class="mx-2">|</span> ${(f.file_size/1024).toFixed(1)} KB
                </div>
            </div>
            <div class="ms-3 d-flex gap-2">
                <a href="${safePath}" target="_blank" class="btn btn-sm btn-outline-primary" title="预览/下载"><i class="fas fa-eye"></i></a>
                <button onclick="deleteFile(${f.id})" class="btn btn-sm btn-outline-danger" title="删除"><i class="fas fa-trash"></i></button>
            </div>
        </div>`;
    }).join('') : '<div class="text-center py-5 text-muted bg-light border rounded dashed-border"><i class="fas fa-folder-open fa-2x mb-3 opacity-25"></i><br>暂无资料</div>';

    // 右侧上传栏
    let rightCol = canUpload ? `
        <div class="card shadow-sm border-0" style="position:sticky; top:1rem">
            <div class="card-header card-header-theme fw-bold text-white" style="background:var(--c-p)"><i class="fas fa-cloud-upload-alt me-2"></i>上传资料</div>
            <div class="card-body">
                <form onsubmit="handleUpload(event)">
                    <input type="hidden" name="indicator_code" value="${d.code}">
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-muted">资料类型</label>
                        <input class="form-control" name="requirement_name" list="reqList" placeholder="选择或输入..." required autocomplete="off">
                        <datalist id="reqList">${requirements.map(r => `<option value="${r.name}">`).join('')}</datalist>
                    </div>
                    <div class="mb-3">
                        <div class="upload-dropzone" onclick="document.getElementById('fileInput').click()">
                            <i class="fas fa-cloud-upload-alt fa-3x text-muted mb-3 opacity-50"></i>
                            <div class="fw-bold text-muted">点击或拖拽文件到此处</div>
                            <div id="fnDisplay" class="small text-primary mt-2 text-truncate"></div>
                            <input type="file" name="file" id="fileInput" class="d-none" onchange="document.getElementById('fnDisplay').innerText=this.files[0].name">
                        </div>
                    </div>
                    <div class="mb-3"><input class="form-control" name="description" placeholder="备注 (可选)"></div>
                    <button type="submit" class="btn btn-primary w-100 py-2"><i class="fas fa-upload me-2"></i>开始上传</button>
                </form>
            </div>
        </div>` : 
        '<div class="alert alert-light text-center small text-muted border"><i class="fas fa-info-circle me-1"></i>此节点无需上传资料</div>';

    // 自评分 Badge
    let scoreBadge = '';
    if (canUpload && d.standard_score > 0) {
        scoreBadge = `
        <span class="badge bg-success ms-2 shadow-sm py-2 px-3" style="cursor:pointer" 
              onclick="enableScoreEdit(this, '${d.code}', ${d.standard_score}, ${d.self_score})" title="双击修改">
            自评: ${d.self_score} <i class="fas fa-pencil-alt small ms-1 opacity-50"></i>
        </span>`;
    }

    div.innerHTML = `
    <div class="fade-in container-fluid px-0">
        <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
            <div class="d-flex align-items-center flex-wrap gap-2">
                <span class="badge bg-primary fs-6">${d.code}</span>
                <h5 class="fw-bold mb-0">${d.full_name}</h5>
                ${d.is_critical ? '<span class="badge bg-warning text-dark"><i class="fas fa-star me-1"></i>关键项</span>' : ''}
            </div>
            <div class="d-flex align-items-center">
                <span class="badge bg-secondary me-2 py-2">标准分 ${d.standard_score}</span>
                ${scoreBadge}
            </div>
        </div>
        <div class="row g-4">
            <div class="col-lg-8">
                <div class="card mb-4 shadow-sm border-0">
                    <div class="card-body">
                        <div class="detail-section mb-4">
                            <h6 class="fw-bold text-secondary mb-2"><i class="fas fa-align-left text-primary me-2"></i>描述 / Description</h6>
                            <div class="p-3 bg-light rounded border-start border-4 border-primary">${(d.description||'无').replace(/\n/g,'<br>')}</div>
                        </div>
                        <div class="detail-section mb-4">
                            <h6 class="fw-bold text-secondary mb-2"><i class="fas fa-tasks text-success me-2"></i>要求 / Requirements</h6>
                            <div class="p-3 bg-light rounded border-start border-4 border-success">${(d.requirement||'无').replace(/\n/g,'<br>')}</div>
                        </div>
                        <div class="detail-section">
                            <h6 class="fw-bold text-secondary mb-2"><i class="fas fa-ruler-combined text-warning me-2"></i>评分 / Scoring</h6>
                            <div class="p-3 bg-light rounded border-start border-4 border-warning">${(d.scoring_criteria||'无').replace(/\n/g,'<br>')}</div>
                        </div>
                    </div>
                </div>
                <h6 class="fw-bold mb-3 d-flex align-items-center">
                    <i class="fas fa-folder-open me-2 text-primary"></i>已上传资料 
                    <span class="badge bg-light text-dark border ms-2 rounded-pill">${files.length}</span>
                </h6>
                <div class="d-flex flex-column gap-2">${fileListHtml}</div>
            </div>
            <div class="col-lg-4">${rightCol}</div>
        </div>
    </div>`;
}

// 开启评分编辑
function enableScoreEdit(el, code, max, current) {
    el.removeAttribute('onclick');
    el.innerHTML = `<input type="number" step="0.1" min="0" max="${max}" value="${current}" 
                    class="form-control form-control-sm text-center fw-bold text-success border-success" 
                    style="width:80px;display:inline-block">`;
    const input = el.querySelector('input');
    input.focus();
    
    const save = async () => {
        let val = parseFloat(input.value);
        if (isNaN(val) || val < 0) val = 0;
        if (val > max) { showToast('error', `不能超过 ${max} 分`); val = max; }
        
        if (val !== parseFloat(current)) {
            const res = await apiCall('update_self_score', { code, score: val });
            if (res.success) {
                showToast('success', '评分已保存');
            } else {
                showToast('error', res.message);
                val = current;
            }
        }
        el.outerHTML = `
        <span class="badge bg-success ms-2 shadow-sm py-2 px-3" style="cursor:pointer" 
              onclick="enableScoreEdit(this, '${code}', ${max}, ${val})" title="双击修改">
            自评: ${val} <i class="fas fa-pencil-alt small ms-1 opacity-50"></i>
        </span>`;
    };
    
    input.addEventListener('blur', save);
    input.addEventListener('keydown', e => { if(e.key === 'Enter') input.blur(); });
}

// 处理上传
async function handleUpload(e) {
    e.preventDefault();
    const btn = e.target.querySelector('button');
    const originalText = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>上传中...';
    
    const fd = new FormData(e.target);
    const res = await apiCall('upload', fd);
    
    if (res.success) {
        showToast('success', '上传成功');
        loadIndicator(currentCode);
        // 更新左侧树小红点
        const treeNode = document.querySelector(`.tree-item[data-code="${currentCode}"]`);
        if (treeNode && !treeNode.querySelector('.status-dot')) {
            treeNode.innerHTML += '<span class="status-dot"></span>';
        }
    } else {
        showToast('error', res.message || '上传失败');
    }
    btn.disabled = false;
    btn.innerHTML = originalText;
}

// 删除文件
async function deleteFile(id) {
    if (!confirm('确定要删除此文件吗？无法撤销。')) return;
    const res = await apiCall('delete', { file_id: id }); // 注意参数名 file_id
    if (res.success) {
        showToast('success', '已删除');
        loadIndicator(currentCode);
    } else {
        showToast('error', res.message);
    }
}

// Toast 提示
function showToast(type, msg) {
    const container = document.querySelector('.toast-container');
    const id = 'toast-' + Date.now();
    const icon = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
    const bg = type === 'success' ? 'bg-success' : 'bg-danger';
    
    const html = `
    <div id="${id}" class="toast align-items-center text-white ${bg} border-0 shadow" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="d-flex">
            <div class="toast-body fs-6"><i class="fas ${icon} me-2"></i>${msg}</div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
    </div>`;
    
    container.insertAdjacentHTML('beforeend', html);
    const el = document.getElementById(id);
    const toast = new bootstrap.Toast(el, { delay: 3000 });
    toast.show();
    el.addEventListener('hidden.bs.toast', () => el.remove());
}
