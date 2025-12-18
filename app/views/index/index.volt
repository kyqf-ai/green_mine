<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 - 绿色矿山资料管理系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #f0fdfa 0%, #ccfbf1 100%);
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            background: white;
            width: 100%;
            max-width: 400px;
            padding: 2.5rem;
            border-radius: 1rem;
            box-shadow: 0 20px 40px rgba(0,0,0,0.08);
        }
        .btn-login {
            background: #0f766e;
            color: white;
            padding: 12px;
        }
        .btn-login:hover {
            background: #0d9488;
            color: white;
        }
    </style>
</head>
<body>

<div class="d-flex flex-column align-items-center w-100">
    <div class="login-card text-center">
        <i class="fas fa-mountain fa-3x mb-3" style="color:#0f766e"></i>
        <h4 class="fw-bold text-secondary">绿色矿山</h4>
        <p class="text-muted small mb-4">资料管理系统 V2.0 (Phalcon版)</p>

        {% if error is defined %}
            <div class="alert alert-danger small py-2">{{ error }}</div>
        {% endif %}

        <form method="POST" action="{{ url('index/index') }}" class="text-start">
            <div class="mb-3">
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0"><i class="fas fa-user text-muted"></i></span>
                    <input type="text" name="username" class="form-control border-start-0 bg-light" placeholder="账号" required>
                </div>
            </div>
            <div class="mb-4">
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0"><i class="fas fa-lock text-muted"></i></span>
                    <input type="password" name="password" class="form-control border-start-0 bg-light" placeholder="密码" required>
                </div>
            </div>
            <button class="btn btn-login w-100 fw-bold shadow-sm" type="submit">立即登录</button>
        </form>
    </div>
    
    <div class="mt-4 text-center text-secondary small">
        <div>默认用户: admin / 密码: greenmine2025</div>
        <div class="mt-2 opacity-75">&copy; {{ date('Y') }} 四川商舟实业有限公司</div>
    </div>
</div>

</body>
</html>
