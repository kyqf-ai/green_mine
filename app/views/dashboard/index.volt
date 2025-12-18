<!DOCTYPE html>
<html lang="zh-CN" data-theme="default">
<head>
    <meta charset="UTF-8">
	<meta name="csrf-token" content="{{ session.get('csrf_token') }}">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>绿色矿山资料管理系统</title>
    <!-- 引入 Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- 引入 FontAwesome 6 -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- 引入自定义样式 -->
    <link href="{{ url('css/style.css') }}" rel="stylesheet">
</head>
<body>
    <div id="app">
        <!-- 顶部导航栏 -->
        <nav class="navbar shadow-sm">
            <div class="container-fluid">
                <div class="d-flex align-items-center">
                    <button class="btn btn-link text-muted me-2 d-lg-none p-1" onclick="toggleSidebar()">
                        <i class="fas fa-bars fa-lg"></i>
                    </button>
                    <a class="navbar-brand d-flex align-items-center" href="#" onclick="loadDashboard()">
                        <i class="fas fa-mountain me-2"></i>
                        <span class="d-none d-sm-inline">绿色矿山资料管理系统</span>
                        <span class="d-inline d-sm-none">绿色矿山</span>
                    </a>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <div class="dropdown">
                        <button class="btn btn-sm btn-outline-secondary rounded-pill px-3 dropdown-toggle" type="button" data-bs-toggle="dropdown">
                            <i class="fas fa-palette me-1"></i> <span class="d-none d-md-inline">主题</span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                            <li><button class="dropdown-item" onclick="setTheme('default')">🎨 青山绿水 (默认)</button></li>
                            <li><button class="dropdown-item" onclick="setTheme('cyan')">🎋 竹叶青 (护眼)</button></li>
                            <li><button class="dropdown-item" onclick="setTheme('teagreen')">🍃 薄荷绿 (经典)</button></li>
                            <li><button class="dropdown-item" onclick="setTheme('autumn')">🍂 杏仁黄 (柔和)</button></li>
                            <li><button class="dropdown-item" onclick="setTheme('warm')">📖 纸墨书香 (阅读)</button></li>
                            <li><button class="dropdown-item" onclick="setTheme('dark')">🌙 静谧暗夜 (深色)</button></li>
                        </ul>
                    </div>
                    <a href="{{ url('index/logout') }}" class="btn btn-sm btn-light text-muted border px-3" title="退出系统">
                        <i class="fas fa-sign-out-alt"></i>
                    </a>
                </div>
            </div>
        </nav>

        <!-- 主体区域 -->
        <div class="main-wrapper">
            <!-- 左侧侧边栏 -->
            <div class="sidebar" id="sidebar">
                <div class="p-3 border-bottom bg-light">
                    <!-- 若有后台管理入口可放此处 -->
                    <div class="d-grid">
                        <a href="{{ url('admin') }}" class="btn btn-primary btn-sm shadow-sm fw-bold">
                            <i class="fas fa-database me-1"></i>指标配置管理
                        </a>
                    </div>
                </div>
                <div class="sidebar-content">
                    <!-- 定义递归渲染树的宏 -->
                    {%- macro render_tree(nodes) -%}
                        {% for node in nodes %}
                            {% set hasChild = node['children'] is defined and node['children']|length > 0 %}
                            <div class="tree-wrapper">
                                <div class="tree-item" data-code="{{ node['code'] }}" onclick="handleNodeClick(this, event)">
                                    <span class="tree-toggle" onclick="toggleNode(this, event)">
                                        {% if hasChild %}
                                            <i class="fas fa-caret-right"></i>
                                        {% endif %}
                                    </span>
                                    
                                    <span class="tree-icon-type">
                                        {% if hasChild %}
                                            <i class="fas fa-folder text-warning"></i>
                                        {% else %}
                                            <i class="fas fa-file-contract text-secondary"></i>
                                        {% endif %}
                                    </span>
                                    
                                    <span class="tree-code">{{ node['code'] }}</span>
                                    <span class="text-truncate flex-grow-1" title="{{ node['full_name'] }}">
                                        {{ node['name'] }}
                                        {% if node['is_critical'] %}
                                            <i class="fas fa-star text-warning small ms-2" title="关键项 (一票否决)"></i>
                                        {% endif %}
                                    </span>
                                    
                                    {% if (node['level'] == 0 or node['level'] == 3) and node['has_file'] %}
                                        <span class="status-dot"></span>
                                    {% endif %}
                                </div>
                                
                                {% if hasChild %}
                                    <div class="tree-children">
                                        {{ render_tree(node['children']) }}
                                    </div>
                                {% endif %}
                            </div>
                        {% endfor %}
                    {%- endmacro -%}

                    <!-- 调用宏渲染树 -->
                    {{ render_tree(tree) }}
                </div>
            </div>

            <div class="content-overlay" id="overlay" onclick="toggleSidebar()"></div>

            <!-- 右侧内容区域 -->
            <div class="content-area" id="mainContent">
                <!-- 内容由 JS 动态加载 -->
            </div>
        </div>

        <!-- 底部版权信息 -->
        <footer class="app-footer">
            <span>绿色矿山资料管理系统 &copy; {{ date('Y') }} 四川商舟实业有限公司 | 建议使用 Chrome/Edge 浏览器访问</span>
        </footer>
    </div>

    <!-- 提示框容器 -->
    <div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1060"></div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- 全局配置供 JS 使用 -->
    <script>
        const APP_CONFIG = {
            baseUrl: "{{ url() }}"
        };
    </script>
    <!-- 引入应用脚本 -->
    <script src="{{ url('js/app.js') }}"></script>
</body>
</html>
