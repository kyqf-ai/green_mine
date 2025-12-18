# 绿色矿山资料管理系统 V2.1 (Phalcon 重构版)

## 📖 项目简介

**绿色矿山资料管理系统** 是一款专为矿山企业设计的 B/S 架构资料管理平台。本版本在原 V2.0 单文件 PHP 系统的基础上，基于 **Phalcon 5.9.3** 框架进行了全栈重构，采用标准的 **MVC 设计模式**，极大地提升了系统的性能、安全性和可维护性。

系统核心功能包括：
*   **指标体系管理**：支持多层级指标树的增删改查。
*   **资料档案管理**：按指标归档文件，支持拖拽上传、预览和下载。
*   **量化自评系统**：支持对末级指标进行在线自评分。
*   **可视化仪表盘**：实时展示资料完成度、得分情况等核心数据。
*   **多主题切换**：内置青山绿水、暗夜模式等多种 UI 主题。

---

## 🛠️ 技术栈

*   **后端框架**: Phalcon 5.9.3 (C 扩展的高性能 PHP 框架)
*   **编程语言**: PHP 8.0+
*   **数据库**: SQLite 3 (无需独立数据库服务，轻量级文件存储)
*   **前端技术**: HTML5, CSS3, JavaScript (ES6)
*   **UI 框架**: Bootstrap 5.3, Font Awesome 6.4
*   **模板引擎**: Volt (Phalcon 内置的高性能模板引擎)

---

## 📂 目录结构

```text
/项目根目录/
│
├── app/                        # 核心应用代码
│   ├── config/                 # 配置文件
│   │   ├── config.php          # 数据库、路径配置
│   │   ├── loader.php          # 自动加载器
│   │   └── services.php        # DI 服务注册 (Session, DB, View)
│   ├── controllers/            # 控制器
│   │   ├── AdminController.php # 后台管理
│   │   ├── ApiController.php   # AJAX 接口
│   │   ├── ControllerBase.php  # 父类 (CSRF, Session)
│   │   ├── DashboardController.php # 仪表盘
│   │   ├── IndexController.php # 登录
│   │   └── InstallController.php # 安装
│   ├── library/                # 辅助类库
│   │   └── IndicatorData.php   # 初始化指标数据源
│   ├── models/                 # 数据模型
│   │   ├── Indicators.php
│   │   └── Materials.php
│   └── views/                  # 视图模板
│       ├── admin/
│       │   └── index.volt      # 后台管理页
│       ├── dashboard/
│       │   └── index.volt      # 前台仪表盘
│       ├── index/
│       │   └── index.volt      # 登录页
│       └── install/
│           └── index.volt      # 安装页
├── cache/                      # ⚡ 必须保留且可写
│   └── (这里是 volt 编译后的 php 文件，可以定期清空)
├── data/                       # ⚡ 必须保留且可写
│   └── green_mine.db           # SQLite 数据库文件 (安装后生成)
├── public/                     # Web 根目录
│   ├── css/
│   │   └── style.css           # 核心样式表
│   ├── js/
│   │   └── app.js              # 核心前端逻辑
│   ├── uploads/                # ⚡ 必须保留且可写 (上传文件存储)
│   ├── .htaccess               # Apache 重写规则
│   ├── favicon.ico             # 图标 (可选)
│   └── index.php               # 统一入口文件
└── README.md                   # 本说明文档
🚀 安装与部署
1. 环境要求
操作系统: Linux (推荐) / Windows
Web 服务器: Nginx 或 Apache
PHP 版本: PHP 8.0 或更高版本
PHP 扩展:phalcon (v5.0+),sqlite3,json,mbstring

2. 部署步骤
上传代码：将项目文件上传至服务器目录。
配置 Web 服务器：将 Web 根目录指向项目的 /public 文件夹。
配置 URL 重写规则 (Rewrite)，确保所有请求转发给 index.php。

(Nginx 配置示例可见下文)

设置权限：
确保以下目录对 Web 服务器用户 (如 www-data) 具有读写权限：
cache/
data/
public/uploads/
chmod -R 777 cache data public/uploads

初始化系统：
在浏览器访问网站首页。
系统会自动检测 data/green_mine.db 是否存在。
若不存在，将自动跳转至安装向导，点击“开始初始化”即可自动创建数据库并导入指标数据。

3. 默认账号
账号: admin
密码: greenmine2025
(建议登录后在 app/config/config.php 中修改默认密码)

⚙️ Nginx 配置示例
nginx
server {
    listen 80;
    server_name your-domain.com;
    root /path/to/project/public;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?_url=$uri&$args;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.2-fpm.sock; # 根据实际情况调整
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}

❓ 常见问题 (FAQ)
Q: 访问页面显示 "Phalcon Exception: Macro 'php_version' does not exist"？
A: 请检查 app/config/services.php，确保 Volt 引擎注册部分已添加 addFunction('php_version', 'phpversion') 等函数映射。修改后请清空 cache/ 目录。

Q: 点击指标一直转圈，无法加载详情？
A: 这通常是 CSRF 验证失败或 API 路径问题。

检查浏览器控制台 (F12) 的 Network 请求返回值。

确保 app/controllers/ControllerBase.php 中 Session 已正确配置且 CSRF Token 已注入视图。

确保 public/js/app.js 中的 apiCall 函数能正确拼接项目路径。

Q: 上传文件提示“目录不可写”？
A: 请检查 public/uploads/ 目录及其子目录的权限。Linux 下建议设为 755 或 777，且属主为 Web 服务器运行用户。

📄 版权信息
Copyright © 2025 四川商舟实业有限公司. All Rights Reserved.
