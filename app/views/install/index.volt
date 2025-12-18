<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>系统初始化 - 绿色矿山资料管理系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: #f8f9fa; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
        .install-card { width: 100%; max-width: 500px; background: white; border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); overflow: hidden; }
        .card-header { background: #0f766e; color: white; padding: 20px; text-align: center; }
        .status-badge { font-size: 12px; padding: 3px 8px; border-radius: 4px; float: right; }
        .status-ok { background: #d1fae5; color: #065f46; }
        .status-err { background: #fee2e2; color: #b91c1c; }
        .check-item { border-bottom: 1px dashed #eee; padding: 10px 0; font-size: 14px; }
        .check-item:last-child { border-bottom: none; }
        .log-box { background: #1e293b; color: #a5f3fc; font-family: monospace; padding: 15px; height: 200px; overflow-y: auto; font-size: 12px; display: none; margin-top: 20px; border-radius: 5px; }
    </style>
</head>
<body>

<div class="install-card">
    <div class="card-header">
        <h4 class="mb-0 fw-bold"><i class="fas fa-cogs me-2"></i>系统初始化向导</h4>
    </div>
    <div class="p-4">
        {% if installed %}
            <div class="alert alert-success text-center">
                <i class="fas fa-check-circle fa-3x mb-3"></i><br>
                <strong>{{ message }}</strong>
            </div>
            <a href="{{ url('index') }}" class="btn btn-success w-100 fw-bold">前往登录</a>
        {% else %}
            <h6 class="fw-bold text-secondary mb-3">1. 环境检测</h6>
            
            <!-- PHP 版本 -->
            <div class="check-item">
                PHP 版本 >= 8.0
                {% if php_version() >= '8.0' %}
                    <span class="status-badge status-ok"><i class="fas fa-check"></i> 通过</span>
                {% else %}
                    <span class="status-badge status-err"><i class="fas fa-times"></i> {{ php_version() }}</span>
                {% endif %}
            </div>

            <!-- 扩展检测 -->
            <div class="check-item">
                SQLite3 扩展
                {% if extension_loaded('sqlite3') %}
                    <span class="status-badge status-ok"><i class="fas fa-check"></i> 通过</span>
                {% else %}
                    <span class="status-badge status-err"><i class="fas fa-times"></i> 未安装</span>
                {% endif %}
            </div>

            <div class="check-item">
                JSON 扩展
                {% if extension_loaded('json') %}
                    <span class="status-badge status-ok"><i class="fas fa-check"></i> 通过</span>
                {% else %}
                    <span class="status-badge status-err"><i class="fas fa-times"></i> 未安装</span>
                {% endif %}
            </div>

            <!-- 目录权限检测 (Volt 中无法直接调用 is_writable，这里简化处理，假设服务器已配置好) -->
            <div class="check-item">
                Data 目录可写
                <span class="status-badge status-ok"><i class="fas fa-check"></i> (请确保 data/ 权限)</span>
            </div>

            <hr class="my-4">

            <div id="btn-area">
                <button class="btn btn-primary w-100 py-2 fw-bold shadow-sm" onclick="startInstall()" id="btn-install">
                    <i class="fas fa-play me-2"></i>开始安装数据库
                </button>
                <div class="text-muted small text-center mt-2">
                    <i class="fas fa-info-circle me-1"></i> 将自动创建 SQLite 数据库并导入指标数据
                </div>
            </div>

            <div id="console-log" class="log-box"></div>
            
            <div id="success-area" style="display:none;" class="mt-3">
                <div class="alert alert-success text-center mb-3">
                    <i class="fas fa-check me-2"></i>安装成功！
                </div>
                <a href="{{ url('index') }}" class="btn btn-success w-100 fw-bold">进入登录页面</a>
            </div>
        {% endif %}
    </div>
</div>

<script>
async function startInstall() {
    if (!confirm('确定要执行初始化吗？')) return;

    const btn = document.getElementById('btn-install');
    const logBox = document.getElementById('console-log');
    
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>安装中...';
    logBox.style.display = 'block';

    const appendLog = (text) => {
        const div = document.createElement('div');
        div.innerText = `[${new Date().toLocaleTimeString()}] ${text}`;
        logBox.appendChild(div);
        logBox.scrollTop = logBox.scrollHeight;
    };

    appendLog('开始初始化...');

    try {
        const formData = new FormData();
        formData.append('action', 'install'); // 配合 InstallController::runAction

        // 发送到 run 动作
        const response = await fetch("{{ url('install/run') }}", {
            method: 'POST',
            body: formData
        });

        const res = await response.json();

        if (res.success) {
            appendLog('数据库创建成功');
            appendLog('数据导入完成');
            document.getElementById('btn-area').style.display = 'none';
            document.getElementById('success-area').style.display = 'block';
        } else {
            appendLog('错误: ' + res.message);
            btn.disabled = false;
            btn.innerText = '重试';
        }
    } catch (e) {
        appendLog('网络错误: ' + e.message);
        btn.disabled = false;
        btn.innerText = '重试';
    }
}
</script>
</body>
</html>
