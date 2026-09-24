%% ==================== 修正calculate_Xi函数调用 ====================
% 创建正确的calculate_Xi函数（如果需要内嵌）
function Xi = calculate_Xi(L, L_B, F, L_A, C, E, d, c, n, M, N)
    % 严格按照论文公式计算 Xi
    % Xi = [(L ⊗ I_{nMN}) - d(I_N ⊗ (L_B ⊗ F)) - c((L_A + C) ⊗ E)]^{sym}
    
    % 第一项: L ⊗ I_{nMN}（L是标量）
    I_nMN = eye(n * M * N);
    term1 = L * I_nMN;
    
    % 第二项: d * (I_N ⊗ (L_B ⊗ F))
    I_N = eye(N);
    LB_F = kron(L_B, F);
    term2 = d * kron(I_N, LB_F);
    
    % 第三项: c * ((L_A + C) ⊗ E)
    % 注意：L_A和C应该是整个多层网络的块对角矩阵
    % 如果L_A已经是18×18的块对角矩阵，直接使用
    if size(L_A, 1) == N * M && size(L_A, 2) == N * M
        LA_C = L_A + C;
        term3 = c * kron(LA_C, E);
    else
        % 如果L_A是单层的，需要扩展到多层
        LA_expanded = kron(eye(M), L_A(1:N, 1:N));
        C_expanded = kron(eye(M), C(1:N, 1:N));
        LA_C = LA_expanded + C_expanded;
        term3 = c * kron(LA_C, E);
    end
    
    % 计算 Xi
    Xi_temp = term1 - term2 - term3;
    
    % 对称化
    Xi = (Xi_temp' + Xi_temp) / 2;
end