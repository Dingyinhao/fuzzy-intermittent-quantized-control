function [rho_values, rho_max] = simple_rho_calculation()
    % 简化版本：快速计算假设2中的rho^(k)值
    % 返回值：rho_values - 各层的rho值向量，rho_max - 最大rho值
    
    %% 参数设置（与您的主代码保持一致）
    M = 3;              % 层数
    sjxs = 0.7;         % 噪声强度系数
    
    %% 理论计算
    % 对于线性噪声强度函数 φ^(k)(x) = sjxs * x
    % rho^(k) = sjxs^2
    rho_theoretical = sjxs^2;
    
    %% 所有层的rho值相同（因为噪声函数相同）
    rho_values = repmat(rho_theoretical, M, 1);
    rho_max = rho_theoretical;
    
    %% 显示结果
    fprintf('=== 假设2 rho^(k) 计算结果 ===\n');
    fprintf('噪声强度系数 sjxs = %.2f\n', sjxs);
    fprintf('噪声强度函数: φ^(k)(x) = %.2f * x\n', sjxs);
    fprintf('\n各层rho^(k)值:\n');
    for k = 1:M
        fprintf('ρ^(%d) = %.6f\n', k, rho_values(k));
    end
    fprintf('\n最大rho值: max{ρ^(k)} = %.6f\n', rho_max);
    fprintf('\n理论公式: ρ^(k) = sjxs² = (%.2f)² = %.6f\n', sjxs, rho_theoretical);
    
    %% 可选：数值验证（简化版）
    if nargout == 0  % 如果没有输出参数，进行验证
        fprintf('\n=== 数值验证 ===\n');
        
        % 随机测试验证
        n_dim = 3;
        num_tests = 100;
        
        for k = 1:M
            max_ratio = 0;
            for test = 1:num_tests
                mu1 = randn(n_dim, 1) * 2;
                mu2 = randn(n_dim, 1) * 2;
                
                phi_diff = sjxs * (mu1 - mu2);  % φ^(k)(μ₁) - φ^(k)(μ₂)
                trace_val = phi_diff' * phi_diff;
                mu_diff_norm_sq = norm(mu1 - mu2)^2;
                
                if mu_diff_norm_sq > 1e-12
                    ratio = trace_val / mu_diff_norm_sq;
                    max_ratio = max(max_ratio, ratio);
                end
            end
            
            fprintf('第%d层验证: 数值ratio = %.6f, 理论值 = %.6f, 误差 = %.2e\n', ...
                    k, max_ratio, rho_theoretical, abs(max_ratio - rho_theoretical));
        end
    end
    
    fprintf('\n建议在主代码中使用: rhoi = %.6f\n', rho_max);
end

%% 快速调用函数（如果需要直接获取值）
function rho = get_rho_for_main_code()
    % 直接返回用于主代码的rho值
    sjxs = 0.7;  % 与主代码保持一致
    rho = sjxs^2;
end