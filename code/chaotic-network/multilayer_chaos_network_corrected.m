function multilayer_chaos_network_corrected()
    % 三层多层网络混沌图模拟（修正版）
    % 第一层：Lü系统，第二层：Lorenz系统，第三层：Rossler系统
    % 布朗运动在各层之间统一（与k无关）
    
    % 参数设置
    n = 480;     % 时间细分参数
    h = 1/n;     % 步长 = 0.00208333...
    Tmax = 400; % 总时间4000秒
    N = Tmax/h;  % 步数
    
    % 混沌图绘制参数
    transient_time = 500;  % 瞬态时间，去掉前500秒的瞬态过程
    transient_steps = transient_time/h;  % 瞬态步数
    
    % 网络参数
    M = 3;       % 层数
    N_nodes = 6; % 每层节点数
    
    % 耦合参数
    d_theta = [0.3, 0.25];
    
    % 连接权重矩阵 H (3x3)
    H = [-2  1  1;
          1 -2  1;
          1  1 -2];
    
    % 层间函数矩阵 F (3x3单位矩阵)
    F = eye(3);
    
    % 初始化状态变量 - 3层，每层3个状态变量
    S = zeros(3, 3, N+1);  % S(状态维度, 层数, 时间步) - 带耦合和噪声
    S_pure = zeros(3, 3, N+1);  % 纯系统（无耦合无噪声）
    
    % 设置初始条件
    S(:, 1, 1) = [2.2; -2.3; 0.2];    % 第一层初始条件
    S(:, 2, 1) = [2.2; -2.2; 0.1];    % 第二层初始条件
    S(:, 3, 1) = [2.2; -2.3; -0.2];   % 第三层初始条件
    
    S_pure(:, 1, 1) = [2.2; -2.3; 0.2];
    S_pure(:, 2, 1) = [2.2; -2.2; 0.1];
    S_pure(:, 3, 1) = [2.2; -2.3; -0.2];
    
    % 初始化统一的Wiener过程（与论文一致，W(t)与k无关）
    randn('state', 300);  % 设置随机种子
    dWiener = zeros(3, N+1);  % dWiener(状态维度, 时间步) - 统一的布朗运动
    Wiener = zeros(3, N+1);   % Wiener(状态维度, 时间步)
    
    % 生成统一的Wiener过程
    for i = 1:N
        for state = 1:3
            dWiener(state, i+1) = sqrt(h) * randn;
            Wiener(state, i+1) = Wiener(state, i) + dWiener(state, i+1);
        end
    end
    
    % 噪声强度系数
    sjxs = 0.7;
    
    % 模糊隶属函数 R1 和 R2
    R1 = @(x) 0.2 + 0.2 * sin(x).^2;
    R2 = @(x) 0.6 + 0.2 * cos(x).^2;
    
    % 定义系统动力学函数
    function f = get_system_dynamics(layer, s)
        if layer == 1  % Lü系统
            a = 36; b = 3; c = 20;
            f = 0.01*[a*(s(2) - s(1));
                     -s(1)*s(3) + c*s(2);
                     s(1)*s(2) - b*s(3)];
        elseif layer == 2  % Lorenz系统
            f = 0.01*[10*(s(2) - s(1));
                     28*s(1) - s(2) - s(1)*s(3);
                     s(1)*s(2) - (8/3)*s(3)];
        else  % layer == 3, Rossler系统
            f = 0.01*[-(s(2) + s(3));
                     s(1) + 0.2*s(2);
                     s(1)*s(3) - 18*s(3) + 0.2];
        end
    end
    
    % 主循环：数值积分
    for i = 1:N
        % ===== 计算带耦合和噪声的多层网络 =====
        for layer = 1:3
            % 当前状态
            s_current = S(:, layer, i);
            
            % 计算确定性部分 f^(k)(s^(k)(t))
            f_det = get_system_dynamics(layer, s_current);
            
            % 计算层间耦合项
            coupling_term = zeros(3, 1);
            for other_layer = 1:3
                if other_layer ~= layer
                    s_other = S(:, other_layer, i);
                    % 耦合强度
                    h_weight = H(layer, other_layer);
                    % 耦合项贡献
                    coupling_diff = F * (s_other - s_current);
                    coupling_term = coupling_term + h_weight * coupling_diff;
                end
            end
            
            % 计算随机项（使用统一的布朗运动）
            noise_term = zeros(3, 1);
            for dim = 1:3
                noise_increment = Wiener(dim, i+1) - Wiener(dim, i);
                noise_term(dim) = sjxs * s_current(dim) * noise_increment;
            end
            
            % 确定性部分
            deterministic_part = h * (f_det + R1(s_current(1))*d_theta(1)*coupling_term + R2(s_current(1))*d_theta(2)*coupling_term);
            
            % 更新状态
            S(:, layer, i+1) = s_current + deterministic_part + noise_term;
        end
        
        % ===== 计算纯系统（无耦合无噪声）=====
        for layer = 1:3
            % 当前状态
            s_pure_current = S_pure(:, layer, i);
            
            % 只考虑确定性部分
            f_det_pure = get_system_dynamics(layer, s_pure_current);
            
            % 四阶Runge-Kutta积分（提高精度）
            k1 = h * f_det_pure;
            k2 = h * get_system_dynamics(layer, s_pure_current + k1/2);
            k3 = h * get_system_dynamics(layer, s_pure_current + k2/2);
            k4 = h * get_system_dynamics(layer, s_pure_current + k3);
            
            % 更新状态
            S_pure(:, layer, i+1) = s_pure_current + (k1 + 2*k2 + 2*k3 + k4)/6;
        end
    end
    
    % 提取时间序列用于绘图
    t = linspace(0, Tmax, N+1);
    
    % ===== 1. 绘制统一的布朗运动轨迹图 =====
    figure('Position', [50, 50, 800, 600]);
    plot(t, Wiener(1, :), 'r-', 'LineWidth', 0.8); hold on;
    plot(t, Wiener(2, :), 'g-', 'LineWidth', 0.8);
    plot(t, Wiener(3, :), 'b-', 'LineWidth', 0.8);
    xlabel('Time t (s)', 'FontSize', 12);
    ylabel('W(t)', 'FontSize', 12);
    legend('W_1(t)', 'W_2(t)', 'W_3(t)', 'Location', 'best', 'FontSize', 11);
    grid on;
    xlim([0, 50]); % 只显示前50秒以便观察细节
end