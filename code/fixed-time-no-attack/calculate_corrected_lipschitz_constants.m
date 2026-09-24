function [L, L1, L2, L3, alpha] = calculate_corrected_lipschitz_constants()
    % 计算并修正三层T-S模糊网络系统的Lipschitz常数
    % 目标：使最大Lipschitz常数 < 4
    
    fprintf('=== 修正前的Lipschitz常数计算 ===\n');
    
    %% 原始系统的Jacobian矩阵函数
    function J1 = jacobian_liu_original(s)
        J1 = [-10,    12,     0;
               17.5-s(3), 0,  -s(1);
               8*s(1),    0,    -3];
    end
    
    function J2 = jacobian_lorenz_original(s)
        J2 = [-10,      10,     0;
               28-s(3),  -1,   -s(1);
               s(2),    s(1),  -8/3];
    end
    
    function J3 = jacobian_rossler_original(s)
        J3 = [0,      -1,        -1;
              1,      0.2,        0;
              s(3),    0,    s(1)-18];
    end
    
    %% 计算原始系统的Lipschitz常数
    s1_range = -20:4:20;  % 粗略搜索以节省时间
    s2_range = -30:6:30;
    s3_range = -25:5:25;
    
    L1_max_orig = 0;
    L2_max_orig = 0;
    L3_max_orig = 0;
    
    for s1 = s1_range
        for s2 = s2_range
            for s3 = s3_range
                s = [s1; s2; s3];
                
                J1 = jacobian_liu_original(s);
                J2 = jacobian_lorenz_original(s);
                J3 = jacobian_rossler_original(s);
                
                L1_max_orig = max(L1_max_orig, norm(J1, 2));
                L2_max_orig = max(L2_max_orig, norm(J2, 2));
                L3_max_orig = max(L3_max_orig, norm(J3, 2));
            end
        end
    end
    
    L_max_orig = max([L1_max_orig, L2_max_orig, L3_max_orig]);
    
    fprintf('原始系统Lipschitz常数:\n');
    fprintf('L1_orig = %.4f\n', L1_max_orig);
    fprintf('L2_orig = %.4f\n', L2_max_orig);
    fprintf('L3_orig = %.4f\n', L3_max_orig);
    fprintf('L_max_orig = %.4f\n', L_max_orig);
    
    %% 计算缩放因子
    target_L = 1.66;  % 设置目标值略小于4，留有余量
    alpha = target_L / L_max_orig;
    
    fprintf('\n=== 缩放参数计算 ===\n');
    fprintf('目标Lipschitz常数: %.2f\n', target_L);
    fprintf('需要的缩放因子: α = %.6f\n', alpha);
    
    %% 修正后的系统动力学函数
    function f = get_corrected_system_dynamics(layer, s)
        if layer == 1  % 修正后的Liu系统
            f_orig = [12*s(2) - 10*s(1);
                     20*s(1) - 2.5*s(1) - s(1)*s(3);
                     4*s(1)*s(1) - 3*s(3)];
            f = alpha * f_orig;
        elseif layer == 2  % 修正后的Lorenz系统
            f_orig = [10*(s(2) - s(1));
                     28*s(1) - s(2) - s(1)*s(3);
                     s(1)*s(2) - (8/3)*s(3)];
            f = alpha * f_orig;
        else  % layer == 3, 修正后的Rossler系统
            f_orig = [-(s(2) + s(3));
                     s(1) + 0.2*s(2);
                     s(1)*s(3) - 18*s(3) + 0.2];
            f = alpha * f_orig;
        end
    end
    
    %% 修正后的Jacobian矩阵函数
    function J1 = jacobian_liu_corrected(s)
        J1_orig = [-10,    12,     0;
                   17.5-s(3), 0,  -s(1);
                   8*s(1),    0,    -3];
        J1 = alpha * J1_orig;
    end
    
    function J2 = jacobian_lorenz_corrected(s)
        J2_orig = [-10,      10,     0;
                   28-s(3),  -1,   -s(1);
                   s(2),    s(1),  -8/3];
        J2 = alpha * J2_orig;
    end
    
    function J3 = jacobian_rossler_corrected(s)
        J3_orig = [0,      -1,        -1;
                   1,      0.2,        0;
                   s(3),    0,    s(1)-18];
        J3 = alpha * J3_orig;
    end
    
    %% 验证修正后的Lipschitz常数
    fprintf('\n=== 修正后的Lipschitz常数验证 ===\n');
    
    L1_max = 0;
    L2_max = 0;
    L3_max = 0;
    
    for s1 = s1_range
        for s2 = s2_range
            for s3 = s3_range
                s = [s1; s2; s3];
                
                J1 = jacobian_liu_corrected(s);
                J2 = jacobian_lorenz_corrected(s);
                J3 = jacobian_rossler_corrected(s);
                
                L1_max = max(L1_max, norm(J1, 2));
                L2_max = max(L2_max, norm(J2, 2));
                L3_max = max(L3_max, norm(J3, 2));
            end
        end
    end
    
    L = max([L1_max, L2_max, L3_max]);
    
    fprintf('修正后系统Lipschitz常数:\n');
    fprintf('L1 = %.4f\n', L1_max);
    fprintf('L2 = %.4f\n', L2_max);
    fprintf('L3 = %.4f\n', L3_max);
    fprintf('L_max = %.4f\n', L);
    
    %% 输出修正后的系统方程
    fprintf('\n=== 修正后的系统方程 ===\n');
    fprintf('缩放因子 α = %.6f\n\n', alpha);
    
    fprintf('修正后的Liu系统:\n');
    fprintf('f1(s) = %.6f * [12*s2 - 10*s1; 20*s1 - 2.5*s1 - s1*s3; 4*s1^2 - 3*s3]\n', alpha);
    fprintf('    = [%.6f*s2 - %.6f*s1; %.6f*s1 - %.6f*s1 - %.6f*s1*s3; %.6f*s1^2 - %.6f*s3]\n', ...
            12*alpha, 10*alpha, 20*alpha, 2.5*alpha, alpha, 4*alpha, 3*alpha);
    
    fprintf('\n修正后的Lorenz系统:\n');
    fprintf('f2(s) = %.6f * [10*(s2-s1); 28*s1-s2-s1*s3; s1*s2-(8/3)*s3]\n', alpha);
    fprintf('    = [%.6f*(s2-s1); %.6f*s1-%.6f*s2-%.6f*s1*s3; %.6f*s1*s2-%.6f*s3]\n', ...
            10*alpha, 28*alpha, alpha, alpha, alpha, 8*alpha/3);
    
    fprintf('\n修正后的Rossler系统:\n');
    fprintf('f3(s) = %.6f * [-(s2+s3); s1+0.2*s2; s1*s3-18*s3+0.2]\n', alpha);
    fprintf('    = [-%.6f*(s2+s3); %.6f*s1+%.6f*s2; %.6f*s1*s3-%.6f*s3+%.6f]\n', ...
            alpha, alpha, 0.2*alpha, alpha, 18*alpha, 0.2*alpha);
    
    %% 性能验证
    fprintf('\n=== 性能验证 ===\n');
    if L < 4
        fprintf('✓ 目标达成: L = %.4f < 4\n', L);
    else
        fprintf('✗ 目标未达成: L = %.4f >= 4\n', L);
    end
    
    fprintf('理论验证: α * L_max_orig = %.6f * %.4f = %.4f\n', alpha, L_max_orig, alpha * L_max_orig);
    
    %% 随机验证Lipschitz条件
    fprintf('\n=== 随机验证 ===\n');
    num_samples = 500;
    max_violation_1 = 0;
    max_violation_2 = 0;
    max_violation_3 = 0;
    
    for i = 1:num_samples
        x = (rand(3,1) - 0.5) * 40;
        y = (rand(3,1) - 0.5) * 40;
        
        fx = get_corrected_system_dynamics(1, x);
        fy = get_corrected_system_dynamics(1, y);
        f_diff_1 = norm(fx - fy);
        state_diff = norm(x - y);
        if state_diff > 1e-10
            violation_1 = f_diff_1 / state_diff;
            max_violation_1 = max(max_violation_1, violation_1);
        end
        
        fx = get_corrected_system_dynamics(2, x);
        fy = get_corrected_system_dynamics(2, y);
        f_diff_2 = norm(fx - fy);
        if state_diff > 1e-10
            violation_2 = f_diff_2 / state_diff;
            max_violation_2 = max(max_violation_2, violation_2);
        end
        
        fx = get_corrected_system_dynamics(3, x);
        fy = get_corrected_system_dynamics(3, y);
        f_diff_3 = norm(fx - fy);
        if state_diff > 1e-10
            violation_3 = f_diff_3 / state_diff;
            max_violation_3 = max(max_violation_3, violation_3);
        end
    end
    
    fprintf('经验验证 - 最大||f(x)-f(y)||/||x-y||:\n');
    fprintf('第一层: %.4f (上界: %.4f)\n', max_violation_1, L1_max);
    fprintf('第二层: %.4f (上界: %.4f)\n', max_violation_2, L2_max);
    fprintf('第三层: %.4f (上界: %.4f)\n', max_violation_3, L3_max);
    
    L1 = L1_max;
    L2 = L2_max;
    L3 = L3_max;
end