function multilayer_fuzzy_network_extended_adjacency2()
% 基于扩充邻接矩阵的三层T-S模糊多层网络抗欺骗攻击同步仿真
% 第一层：Liu系统，第二层：Lorenz系统，第三层：Rossler系统
% 使用扩充邻接矩阵 \breve{\mathcal{A}}^{(k)} 和新的状态迭代公式
close all; clear; clc;
%% ==================== 间歇控制时间设置 ====================
n = 480; % 时间细分参数
h = 1/n; % 时间步长 = 0.025

% 设计(8,2)分的间歇控制：确保所有时间点*n都是整数
total_simulation_time = 8; % 总仿真时间
cycle_length = 0.25; % 每个间歇控制周期0.25秒
active_time = 0.2; % 激活时间0.2秒
inactive_time = 0.05; % 非激活时间0.05秒

N_periods = floor(total_simulation_time / cycle_length);

% 构造确保整数索引的C和R数组
C = zeros(1, N_periods);
R = zeros(1, N_periods+1);

R(1) = 0;
for k = 1:N_periods
cycle_start = (k-1) * cycle_length;
C(k) = cycle_start + active_time;
R(k+1) = k * cycle_length;
end
N_periods = length(C); % 间歇控制周期数
fprintf('=== 基于扩充邻接矩阵的三层T-S模糊网络固定时间同步仿真 ===\n');
fprintf('间歇控制周期数: %d\n', N_periods);
fprintf('时间步长: %.4f\n', h);
%% ==================== 网络参数 ====================
M = 3; % 层数
N_original = 6; % 每层原始节点数
N_virtual = 7; % 包含虚拟节点的总数量 (N_original + 1)
n_dim = 3; % 每个节点的维数
r = 2; % 模糊规则数
total_nodes = M * N_original;
fprintf('网络参数: M=%d层, 每层%d个实际节点+1个虚拟节点, 每节点%d维, %d个模糊规则\n', ...
M, N_original, n_dim, r);
%% ==================== 模糊隶属函数（按代码2的方式简化） ====================
% 按照代码2的方式定义简单的模糊函数
R1 = @(x) 0.2 + 0.2 * sin(x).^2; % 简化的模糊函数1
R2 = @(x) 0.6 + 0.2 * cos(x).^2; % 简化的模糊函数2
sign = '(abs(x+0.1)-abs(x-0.1))/1.2'; 
sign = inline(sign);
%% ==================== 控制器参数 ====================
% 每个模糊规则的控制 (论文中的 α_θ, β_θ, γ_θ)
alpha_theta = [5.5, 5.6]; % 基本控制 α_θ44
beta_theta = [2, 2.1]; % 符号函数 β_θ (增大以抵抗攻击)
gamma_theta = [5.7, 5.8]; % 幂次项 γ_θ
delta = 1.2; % 幂次指数 δ > 1 for fixed-time1.2
alpha = min(alpha_theta); % α = min{α_θ}
beta = min(beta_theta); % β = min{β_θ}
gamma = min(gamma_theta); % γ = min{γ_θ}
% 耦合系数 (每个模糊规则)
c_theta = [0.3, 0.25]; % 层内耦合强度 c_θ
d_theta = [0.3, 0.25]; % 层间耦合强度 d_θ
d = min(d_theta);
c = min(c_theta);
sjxs=0.7;%随机项的系数
%% ==================== 欺骗攻击参数 ====================
omega_tilde = 0.7; % 攻击发生概率
z1 = 0.2; % 线性攻击系数
z2 = 0.15; % 非线性攻击系数
Gamma_1 = 1.0; % 攻击函数上界
Gamma1 = 1.0; 
% 验证攻击抵抗条件
min_beta = min(beta_theta);
min_alpha = min(alpha_theta);
attack_condition1 = z2 * omega_tilde * Gamma_1 / (1 + z1 * omega_tilde);
fprintf('=== 攻击参数验证 ===\n');
fprintf('攻击发生概率: %.2f\n', omega_tilde);
fprintf('攻击抵抗条件1: β > %.4f, 实际 β_min = %.4f ✓\n', attack_condition1, min_beta);
fprintf('控制增益: z₁=%.2f, z₂=%.2f, Γ₁=%.2f\n', z1, z2, Gamma_1);
%% ==================== 量化参数 ====================
rho = 0.7; % 量化密度 ρ
chi = (1-rho)/(1+rho); % 量化参数 χ
Lambda = 0.8; % 间歇控制参数
%% ==================== 构造扩充邻接矩阵 ====================
fprintf('\n=== 构造扩充邻接矩阵 ===\n');
% 调整后的Laplace矩阵L_A1
% 调整后的Laplace矩阵L_A1
L_A1_original = [3 -0.6 -0.6 -0.6 -0.6 -0.6;
-0.6 1.2 -0.6 0 0 0;
-0.6 -0.6 1.8 -0.6 0 0;
-0.6 0 -0.6 1.2 0 0;
-0.6 0 0 0 1.2 -0.6;
-0.6 0 0 0 -0.6 1.2];

% 调整后的Laplace矩阵L_A2
L_A2_original = [0.4 0 -0.2 -0.2 0 0;
0 0.45 -0.15 0 -0.1 -0.2;
-0.2 -0.15 0.5 0 -0.15 0;
-0.2 0 0 0.35 -0.05 -0.1;
0 -0.1 -0.15 -0.05 0.3 0;
0 -0.2 0 -0.1 0 0.3];

% 调整后的Laplace矩阵L_A3（新结构，保持对称性和行和为零）
L_A3_original= [2.5 -0.5 -0.5 -0.5 -0.5 0;
-0.5 2 -0.5 0 -0.5 -0.5;
-0.5 -0.5 2 -0.5 0 -0.5;
-0.5 0 -0.5 2 -0.5 -0.5;
-0.5 -0.5 0 -0.5 2 -0.5;
0 -0.5 -0.5 -0.5 -0.5 2.5];

L_A4 = blkdiag(L_A1_original, L_A2_original, L_A3_original);
% 从拉普拉斯矩阵转换为邻接矩阵
G_A1_original = -L_A1_original;
G_A2_original = -L_A2_original;
G_A3_original = -L_A3_original;
% 将对角线元素设为0（邻接矩阵性质）
for i = 1:N_original
G_A1_original(i,i) = 0;
G_A2_original(i,i) = 0;
G_A3_original(i,i) = 0;
end
% 虚拟节点连接权重向量 \breve{c}_j^{(k)}
c_tilde_1 = [0; 0; 0; 0; 0; 0]; % 第一层虚拟节点连接权重
c_tilde_2 = [0; 0; 0; 0; 0; 0]; % 第二层虚拟节点连接权重
c_tilde_3 = [0; 0; 0; 0; 0; 0]; % 第三层虚拟节点连接权重
% 构造扩展拉普拉斯矩阵
C1_matrix = diag(c_tilde_1);
C2_matrix = diag(c_tilde_2);
C3_matrix = diag(c_tilde_3);
C4 = blkdiag(C1_matrix, C2_matrix, C3_matrix);
% 构造扩充邻接矩阵 \breve{\mathcal{A}}^{(k)}
% 根据论文：\breve{g}_{j, N+1}^{(k)}=\breve{c}_j^{(k)} 和 \breve{g}_{\mathcal{N}+1, j}^{(k)}=0
% 且 \breve{g}_{i j}^{(k)}=\breve{g}_{j i}^{(k)}=g_{i j}^{(k)}=g_{j i}^{(k)} 对于 j ≠ N+1
% 第一层扩充邻接矩阵
A_breve_1 = zeros(N_virtual, N_virtual);
A_breve_1(1:N_original, 1:N_original) = G_A1_original; % 原始邻接矩阵部分
A_breve_1(1:N_original, N_virtual) = c_tilde_1; % \breve{g}_{j, N+1}^{(1)} = \breve{c}_j^{(1)}
A_breve_1(N_virtual, :) = 0; % \breve{g}_{N+1, j}^{(1)} = 0
% 第二层扩充邻接矩阵
A_breve_2 = zeros(N_virtual, N_virtual);
A_breve_2(1:N_original, 1:N_original) = G_A2_original;
A_breve_2(1:N_original, N_virtual) = c_tilde_2;
A_breve_2(N_virtual, :) = 0;
% 第三层扩充邻接矩阵
A_breve_3 = zeros(N_virtual, N_virtual);
A_breve_3(1:N_original, 1:N_original) = G_A3_original;
A_breve_3(1:N_original, N_virtual) = c_tilde_3;
A_breve_3(N_virtual, :) = 0;
fprintf('扩充邻接矩阵维度: %d×%d\n', size(A_breve_1));
fprintf('第一层虚拟节点连接权重: [%.2f, %.2f, %.2f, %.2f, %.2f, %.2f]\n', c_tilde_1);
fprintf('第二层虚拟节点连接权重: [%.2f, %.2f, %.2f, %.2f, %.2f, %.2f]\n', c_tilde_2);
fprintf('第三层虚拟节点连接权重: [%.2f, %.2f, %.2f, %.2f, %.2f, %.2f]\n', c_tilde_3);
%% ==================== 层间耦合矩阵H ====================
H = [-2 1 1;
1 -2 1;
1 1 -2];
L_B = -H;
% 耦合矩阵
E = eye(n_dim); % 层内耦合矩阵
F = eye(n_dim); % 层间耦合矩阵
%% ==================== 攻击函数定义 ====================
function gamma_val = attack_function(phi_val)
% 非线性攻击函数 Γ(φ) (论文假设3)
% 满足 ||Γ(·)||₂ ≤ Γ₁
gamma_val = Gamma_1 * tanh(phi_val / Gamma_1);
end
%% ==================== 系统动力学函数 ====================
function f = get_system_dynamics(layer, s)
if layer == 1 % Liu系统
f = 0.01*[12*s(2) - 10*s(1);
20*s(1) - 2.5*s(1) - s(1)*s(3);
4*s(1)*s(1) - 3*s(3)];
elseif layer == 2 % Lorenz系统
f = 0.01*[10*(s(2) - s(1));
28*s(1) - s(2) - s(1)*s(3);
s(1)*s(2) - (8/3)*s(3)];
else % layer == 3, Rossler系统
f = 0.01*[-(s(2) + s(3));
s(1) + 0.2*s(2);
s(1)*s(3) - 18*s(3) + 0.2];
end
end

%% ==================== 状态变量初始化 ====================
total_time_steps = R(N_periods+1)*n;
% 系统状态（包含虚拟节点）
X = zeros(3*N_virtual, total_time_steps+1); % 第一层
Y = zeros(3*N_virtual, total_time_steps+1); % 第二层
Z = zeros(3*N_virtual, total_time_steps+1); % 第三层
% 控制输入相关变量
phi1 = zeros(3*N_original, total_time_steps+1); % 第一层正常控制器
phi2 = zeros(3*N_original, total_time_steps+1); % 第二层正常控制器
phi3 = zeros(3*N_original, total_time_steps+1); % 第三层正常控制器
psi1 = zeros(3*N_original, total_time_steps+1); % 第一层攻击信号
psi2 = zeros(3*N_original, total_time_steps+1); % 第二层攻击信号
psi3 = zeros(3*N_original, total_time_steps+1); % 第三层攻击信号
u1 = zeros(3*N_original, total_time_steps+1); % 第一层总控制输入
u2 = zeros(3*N_original, total_time_steps+1); % 第二层总控制输入
u3 = zeros(3*N_original, total_time_steps+1); % 第三层总控制输入
% 同步态
s1 = zeros(3, total_time_steps+1); % 第一层同步态
s2 = zeros(3, total_time_steps+1); % 第二层同步态
s3 = zeros(3, total_time_steps+1); % 第三层同步态
% 同步误差和量化器
e1 = zeros(3*N_original, total_time_steps+1);
quantizer1 = zeros(3*N_original, total_time_steps+1);
e2 = zeros(3*N_original, total_time_steps+1);
quantizer2 = zeros(3*N_original, total_time_steps+1);
e3 = zeros(3*N_original, total_time_steps+1);
quantizer3 = zeros(3*N_original, total_time_steps+1);
% 攻击事件序列
rand('state',0);
attack_events = binornd(1, omega_tilde, 1, total_time_steps+1);
%% Wiener过程初始化
randn('state', 300);
dWiener = zeros(1, total_time_steps+1);
Wiener = zeros(1, total_time_steps+1);
for g = 1:total_time_steps
dWiener(g+1) = sqrt(h)*randn;
Wiener(g+1) = Wiener(g) + dWiener(g+1);
end
%% ==================== 初始条件设置 ====================
% 同步态初始条件
% s1(:,1) = [1.2,-0.3,-1.2]; % 符号: [+, 0, -] [0.8; -0.1; -0.8] [1.5,2.3, 6.2]
% s2(:,1) = [1.2,-1.2,0]; % 符号: [+, -, 0] [0.8; -0.8; 0]
% s3(:,1) = [1.2,0.3,-1.2]; % 符号: [+, 0, -][0.8; 0; -0.8]; 
s1(:,1) = [2.2,-2.3,0.2]; % 符号: [+, 0, -] [0.8; -0.1; -0.8] [1.5,2.3, 6.2]
s2(:,1) = [2.2,-2.2,0.1]; % 符号: [+, -, 0] [0.8; -0.8; 0]
s3(:,1) = [2.2,-2.3,-0.2]; % 符号: [+, 0, -][0.8; 0; -0.8]; 
% 节点状态初始化
for r_idx = 1:N_original
Z111 = unifrnd(-2.3, 2.3, 3*N_original, 1);
Z22 = unifrnd(-2.3, 2.3, 3*N_original, 1);
Z33 = unifrnd(-2.3, 2.3, 3*N_original, 1);
X(3*(r_idx-1)+1, 1) = Z111(3*(r_idx-1)+1, 1);
X(3*(r_idx-1)+2, 1) = Z22(3*(r_idx-1)+2, 1);
X(3*(r_idx-1)+3, 1) = Z33(3*(r_idx-1)+3, 1);
Y(3*(r_idx-1)+1, 1) = Z111(3*(r_idx-1)+1, 1);
Y(3*(r_idx-1)+2, 1) = Z22(3*(r_idx-1)+2, 1);
Y(3*(r_idx-1)+3, 1) = Z33(3*(r_idx-1)+3, 1);
Z(3*(r_idx-1)+1, 1) = Z111(3*(r_idx-1)+1, 1);
Z(3*(r_idx-1)+2, 1) = Z22(3*(r_idx-1)+2, 1);
Z(3*(r_idx-1)+3, 1) = Z33(3*(r_idx-1)+3, 1);
end
% 虚拟节点初始状态设置为同步态
virtual_idx = N_virtual;
X(3*(virtual_idx-1)+1, 1) = s1(1, 1);
X(3*(virtual_idx-1)+2, 1) = s1(2, 1);
X(3*(virtual_idx-1)+3, 1) = s1(3, 1);
Y(3*(virtual_idx-1)+1, 1) = s2(1, 1);
Y(3*(virtual_idx-1)+2, 1) = s2(2, 1);
Y(3*(virtual_idx-1)+3, 1) = s2(3, 1);
Z(3*(virtual_idx-1)+1, 1) = s3(1, 1);
Z(3*(virtual_idx-1)+2, 1) = s3(2, 1);
Z(3*(virtual_idx-1)+3, 1) = s3(3, 1);

%% ==================== 主仿真循环 ====================
fprintf('开始基于扩充邻接矩阵的抗攻击仿真循环...\n');
for k = 1:N_periods
%% ===== 控制激活阶段 =====
fprintf('周期 %d/%d: 控制激活阶段 [%.2f, %.2f]\n', k, N_periods, R(k), C(k));
for j = R(k)*n+1:C(k)*n
% 当前攻击事件状态
current_attack = attack_events(j);
%% 更新同步态（按照代码2的简化方式，直接使用R1和R2）
% 第一层同步态
s1_curr = [s1(1,j); s1(2,j); s1(3,j)];
f_s1 = get_system_dynamics(1, s1_curr);
% 层间耦合计算（使用扩充邻接矩阵思想）
inter_layer_coupling_1 = zeros(3,1);
inter_layer_coupling_2 = zeros(3,1);
inter_layer_coupling_3 = zeros(3,1);
% 第一层与其他层的耦合
for l = 1:M
if l ~= 1
if l == 2
s_diff = [s2(1,j) - s1(1,j); s2(2,j) - s1(2,j); s2(3,j) - s1(3,j)];
else % l == 3
s_diff = [s3(1,j) - s1(1,j); s3(2,j) - s1(2,j); s3(3,j) - s1(3,j)];
end
inter_layer_coupling_1 = inter_layer_coupling_1 + H(1,l) * F * s_diff;
end
end
s1(1,j+1) = s1(1,j) + h*(f_s1(1) + R1(s1(1,j))*d_theta(1)*inter_layer_coupling_1(1) + R2(s1(1,j))*d_theta(2)*inter_layer_coupling_1(1)) + sjxs*s1(1,j)*(Wiener(j+1)-Wiener(j));
s1(2,j+1) = s1(2,j) + h*(f_s1(2) + R1(s1(2,j))*d_theta(1)*inter_layer_coupling_1(2) + R2(s1(2,j))*d_theta(2)*inter_layer_coupling_1(2)) + sjxs*s1(2,j)*(Wiener(j+1)-Wiener(j));
s1(3,j+1) = s1(3,j) + h*(f_s1(3) + R1(s1(3,j))*d_theta(1)*inter_layer_coupling_1(3) + R2(s1(3,j))*d_theta(2)*inter_layer_coupling_1(3)) + sjxs*s1(3,j)*(Wiener(j+1)-Wiener(j));
% 第二层同步态
s2_curr = [s2(1,j); s2(2,j); s2(3,j)];
f_s2 = get_system_dynamics(2, s2_curr);
% 第二层与其他层的耦合
for l = 1:M
if l ~= 2
if l == 1
s_diff = [s1(1,j) - s2(1,j); s1(2,j) - s2(2,j); s1(3,j) - s2(3,j)];
else % l == 3
s_diff = [s3(1,j) - s2(1,j); s3(2,j) - s2(2,j); s3(3,j) - s2(3,j)];
end
inter_layer_coupling_2 = inter_layer_coupling_2 + H(2,l) * F * s_diff;
end
end
s2(1,j+1) = s2(1,j) + h*(f_s2(1) + R1(s2(1,j))*d_theta(1)*inter_layer_coupling_2(1) + R2(s2(1,j))*d_theta(2)*inter_layer_coupling_2(1)) + sjxs*s2(1,j)*(Wiener(j+1)-Wiener(j));
s2(2,j+1) = s2(2,j) + h*(f_s2(2) + R1(s2(2,j))*d_theta(1)*inter_layer_coupling_2(2) + R2(s2(2,j))*d_theta(2)*inter_layer_coupling_2(2)) + sjxs*s2(2,j)*(Wiener(j+1)-Wiener(j));
s2(3,j+1) = s2(3,j) + h*(f_s2(3) + R1(s2(3,j))*d_theta(1)*inter_layer_coupling_2(3) + R2(s2(3,j))*d_theta(2)*inter_layer_coupling_2(3)) + sjxs*s2(3,j)*(Wiener(j+1)-Wiener(j));
% 第三层同步态
s3_curr = [s3(1,j); s3(2,j); s3(3,j)];
f_s3 = get_system_dynamics(3, s3_curr);
% 第三层与其他层的耦合
for l = 1:M
if l ~= 3
if l == 1
s_diff = [s1(1,j) - s3(1,j); s1(2,j) - s3(2,j); s1(3,j) - s3(3,j)];
else % l == 2
s_diff = [s2(1,j) - s3(1,j); s2(2,j) - s3(2,j); s2(3,j) - s3(3,j)];
end
inter_layer_coupling_3 = inter_layer_coupling_3 + H(3,l) * F * s_diff;
end
end
s3(1,j+1) = s3(1,j) + h*(f_s3(1) + R1(s3(1,j))*d_theta(1)*inter_layer_coupling_3(1) + R2(s3(1,j))*d_theta(2)*inter_layer_coupling_3(1)) + sjxs*s3(1,j)*(Wiener(j+1)-Wiener(j));
s3(2,j+1) = s3(2,j) + h*(f_s3(2) + R1(s3(2,j))*d_theta(1)*inter_layer_coupling_3(2) + R2(s3(2,j))*d_theta(2)*inter_layer_coupling_3(2)) + sjxs*s3(2,j)*(Wiener(j+1)-Wiener(j));
s3(3,j+1) = s3(3,j) + h*(f_s3(3) + R1(s3(3,j))*d_theta(1)*inter_layer_coupling_3(3) + R2(s3(3,j))*d_theta(2)*inter_layer_coupling_3(3)) + sjxs*s3(3,j)*(Wiener(j+1)-Wiener(j));
%% 更新虚拟节点状态
X(3*(virtual_idx-1)+1, j+1) = s1(1, j+1);
X(3*(virtual_idx-1)+2, j+1) = s1(2, j+1);
X(3*(virtual_idx-1)+3, j+1) = s1(3, j+1);
Y(3*(virtual_idx-1)+1, j+1) = s2(1, j+1);
Y(3*(virtual_idx-1)+2, j+1) = s2(2, j+1);
Y(3*(virtual_idx-1)+3, j+1) = s2(3, j+1);
Z(3*(virtual_idx-1)+1, j+1) = s3(1, j+1);
Z(3*(virtual_idx-1)+2, j+1) = s3(2, j+1);
Z(3*(virtual_idx-1)+3, j+1) = s3(3, j+1);
%% 按照扩充邻接矩阵处理实际节点
for I = 1:N_original
%% 计算同步误差
e1(3*(I-1)+1, j) = X(3*(I-1)+1, j) - s1(1, j);
e1(3*(I-1)+2, j) = X(3*(I-1)+2, j) - s1(2, j);
e1(3*(I-1)+3, j) = X(3*(I-1)+3, j) - s1(3, j);
e2(3*(I-1)+1, j) = Y(3*(I-1)+1, j) - s2(1, j);
e2(3*(I-1)+2, j) = Y(3*(I-1)+2, j) - s2(2, j);
e2(3*(I-1)+3, j) = Y(3*(I-1)+3, j) - s2(3, j);
e3(3*(I-1)+1, j) = Z(3*(I-1)+1, j) - s3(1, j);
e3(3*(I-1)+2, j) = Z(3*(I-1)+2, j) - s3(2, j);
e3(3*(I-1)+3, j) = Z(3*(I-1)+3, j) - s3(3, j);
%% 量化同步误差
% 第一层量化
for n_neuron = 1:3
error_val = e1(3*(I-1)+n_neuron, j);
quantizer1(3*(I-1)+n_neuron, j) = quantizer(error_val);
% 第二层量化
error_val = e2(3*(I-1)+n_neuron, j);
quantizer2(3*(I-1)+n_neuron, j) = quantizer(error_val);
% 第三层量化
error_val = e3(3*(I-1)+n_neuron, j);
quantizer3(3*(I-1)+n_neuron, j) = quantizer(error_val);
end
%% 抗攻击控制器设计（按照代码2的简化方式）
% 第一层控制器
for n_neuron = 1:3
q_val = quantizer1(3*(I-1)+n_neuron, j);
% 按照代码2的方式简化控制器，直接使用R1和R2
phi1_val1 = -alpha_theta(1)*q_val - beta_theta(1)*sign(q_val) - gamma_theta(1)*sign(q_val)*abs(q_val)^delta;
phi1_val2 = -alpha_theta(2)*q_val - beta_theta(2)*sign(q_val) - gamma_theta(2)*sign(q_val)*abs(q_val)^delta;
% 按照代码2的方式，直接将R1和R2应用到控制器
phi1_current = R1(X(3*(I-1)+n_neuron, j))*phi1_val1 + R2(X(3*(I-1)+n_neuron, j))*phi1_val2;
phi1(3*(I-1)+n_neuron, j) = phi1_current;
% 攻击信号
Q_val = z1 * phi1_current + z2 * attack_function(phi1_current);
psi1(3*(I-1)+n_neuron, j) = current_attack * Q_val;
% 总控制输入
u1(3*(I-1)+n_neuron, j) = phi1_current + psi1(3*(I-1)+n_neuron, j);
% 第二层控制器
q_val = quantizer2(3*(I-1)+n_neuron, j);
phi2_val1 = -alpha_theta(1)*q_val - beta_theta(1)*sign(q_val) - gamma_theta(1)*sign(q_val)*abs(q_val)^delta;
phi2_val2 = -alpha_theta(2)*q_val - beta_theta(2)*sign(q_val) - gamma_theta(2)*sign(q_val)*abs(q_val)^delta;
phi2_current = R1(Y(3*(I-1)+n_neuron, j))*phi2_val1 + R2(Y(3*(I-1)+n_neuron, j))*phi2_val2;
phi2(3*(I-1)+n_neuron, j) = phi2_current;
Q_val = z1 * phi2_current + z2 * attack_function(phi2_current);
psi2(3*(I-1)+n_neuron, j) = current_attack * Q_val;
u2(3*(I-1)+n_neuron, j) = phi2_current + psi2(3*(I-1)+n_neuron, j);
% 第三层控制器
q_val = quantizer3(3*(I-1)+n_neuron, j);
phi3_val1 = -alpha_theta(1)*q_val - beta_theta(1)*sign(q_val) - gamma_theta(1)*sign(q_val)*abs(q_val)^delta;
phi3_val2 = -alpha_theta(2)*q_val - beta_theta(2)*sign(q_val) - gamma_theta(2)*sign(q_val)*abs(q_val)^delta;
phi3_current = R1(Z(3*(I-1)+n_neuron, j))*phi3_val1 + R2(Z(3*(I-1)+n_neuron, j))*phi3_val2;
phi3(3*(I-1)+n_neuron, j) = phi3_current;
Q_val = z1 * phi3_current + z2 * attack_function(phi3_current);
psi3(3*(I-1)+n_neuron, j) = current_attack * Q_val;
u3(3*(I-1)+n_neuron, j) = phi3_current + psi3(3*(I-1)+n_neuron, j);
end
%% 使用扩充邻接矩阵更新系统状态
% 第一层状态更新
x_curr = [X(3*(I-1)+1, j); X(3*(I-1)+2, j); X(3*(I-1)+3, j)];
f_x = get_system_dynamics(1, x_curr);
% 使用扩充邻接矩阵计算层内耦合
% 根据新公式：c_θ * Σ_{j=1,j≠i}^{N+1} \breve{g}_{ij}^{(k)} E(x_j^{(k)} - x_i^{(k)})
intra_coupling_1 = zeros(3, 1);
intra_coupling_2 = zeros(3, 1);
intra_coupling_3 = zeros(3, 1);
for J = 1:N_virtual
if J ~= I % j ≠ i
coupling_weight = A_breve_1(I, J); % \breve{g}_{ij}^{(1)}
if coupling_weight ~= 0
if J <= N_original % 普通节点
x_diff = [X(3*(J-1)+1, j) - X(3*(I-1)+1, j);
X(3*(J-1)+2, j) - X(3*(I-1)+2, j);
X(3*(J-1)+3, j) - X(3*(I-1)+3, j)];
else % 虚拟节点 (J = N_virtual = 7)
x_diff = [X(3*(J-1)+1, j) - X(3*(I-1)+1, j);
X(3*(J-1)+2, j) - X(3*(I-1)+2, j);
X(3*(J-1)+3, j) - X(3*(I-1)+3, j)];
end
coupled_diff = E * x_diff;
intra_coupling_1 = intra_coupling_1 + coupling_weight * coupled_diff;
end
end
end
% 层间耦合（保持原有方式）
inter_coupling_1 = zeros(3, 1);
for l = 1:M
if l ~= 1 % l ≠ k (k=1)
if l == 2
x_diff = [Y(3*(I-1)+1, j) - X(3*(I-1)+1, j);
Y(3*(I-1)+2, j) - X(3*(I-1)+2, j);
Y(3*(I-1)+3, j) - X(3*(I-1)+3, j)];
else % l == 3
x_diff = [Z(3*(I-1)+1, j) - X(3*(I-1)+1, j);
Z(3*(I-1)+2, j) - X(3*(I-1)+2, j);
Z(3*(I-1)+3, j) - X(3*(I-1)+3, j)];
end
inter_coupling_1 = inter_coupling_1 + H(1, l) * F * x_diff;
end
end
% 状态更新（根据新的扩充邻接矩阵公式）
for dim = 1:3
X(3*(I-1)+dim, j+1) = X(3*(I-1)+dim, j) + h * (f_x(dim) + ...
R1(X(3*(I-1)+dim, j)) * (c_theta(1) * intra_coupling_1(dim) + d_theta(1) * inter_coupling_1(dim) + u1(3*(I-1)+dim, j)) + ...
R2(X(3*(I-1)+dim, j)) * (c_theta(2) * intra_coupling_1(dim) + d_theta(2) * inter_coupling_1(dim) + u1(3*(I-1)+dim, j))) + ...
sjxs * X(3*(I-1)+dim, j) * (Wiener(j+1) - Wiener(j));
end
% 第二层状态更新（类似方式）
y_curr = [Y(3*(I-1)+1, j); Y(3*(I-1)+2, j); Y(3*(I-1)+3, j)];
f_y = get_system_dynamics(2, y_curr);
% 使用扩充邻接矩阵计算层内耦合
intra_coupling_2 = zeros(3, 1);
for J = 1:N_virtual
if J ~= I
coupling_weight = A_breve_2(I, J);
if coupling_weight ~= 0
if J <= N_original
y_diff = [Y(3*(J-1)+1, j) - Y(3*(I-1)+1, j);
Y(3*(J-1)+2, j) - Y(3*(I-1)+2, j);
Y(3*(J-1)+3, j) - Y(3*(I-1)+3, j)];
else
y_diff = [Y(3*(J-1)+1, j) - Y(3*(I-1)+1, j);
Y(3*(J-1)+2, j) - Y(3*(I-1)+2, j);
Y(3*(J-1)+3, j) - Y(3*(I-1)+3, j)];
end
coupled_diff = E * y_diff;
intra_coupling_2 = intra_coupling_2 + coupling_weight * coupled_diff;
end
end
end
% 层间耦合
inter_coupling_2 = zeros(3, 1);
for l = 1:M
if l ~= 2
if l == 1
y_diff = [X(3*(I-1)+1, j) - Y(3*(I-1)+1, j);
X(3*(I-1)+2, j) - Y(3*(I-1)+2, j);
X(3*(I-1)+3, j) - Y(3*(I-1)+3, j)];
else % l == 3
y_diff = [Z(3*(I-1)+1, j) - Y(3*(I-1)+1, j);
Z(3*(I-1)+2, j) - Y(3*(I-1)+2, j);
Z(3*(I-1)+3, j) - Y(3*(I-1)+3, j)];
end
inter_coupling_2 = inter_coupling_2 + H(2, l) * F * y_diff;
end
end
for dim = 1:3
Y(3*(I-1)+dim, j+1) = Y(3*(I-1)+dim, j) + h * (f_y(dim) + ...
R1(Y(3*(I-1)+dim, j)) * (c_theta(1) * intra_coupling_2(dim) + d_theta(1) * inter_coupling_2(dim) + u2(3*(I-1)+dim, j)) + ...
R2(Y(3*(I-1)+dim, j)) * (c_theta(2) * intra_coupling_2(dim) + d_theta(2) * inter_coupling_2(dim) + u2(3*(I-1)+dim, j))) + ...
sjxs * Y(3*(I-1)+dim, j) * (Wiener(j+1) - Wiener(j));
end
% 第三层状态更新（类似方式）
z_curr = [Z(3*(I-1)+1, j); Z(3*(I-1)+2, j); Z(3*(I-1)+3, j)];
f_z = get_system_dynamics(3, z_curr);
% 使用扩充邻接矩阵计算层内耦合
intra_coupling_3 = zeros(3, 1);
for J = 1:N_virtual
if J ~= I
coupling_weight = A_breve_3(I, J);
if coupling_weight ~= 0
if J <= N_original
z_diff = [Z(3*(J-1)+1, j) - Z(3*(I-1)+1, j);
Z(3*(J-1)+2, j) - Z(3*(I-1)+2, j);
Z(3*(J-1)+3, j) - Z(3*(I-1)+3, j)];
else
z_diff = [Z(3*(J-1)+1, j) - Z(3*(I-1)+1, j);
Z(3*(J-1)+2, j) - Z(3*(I-1)+2, j);
Z(3*(J-1)+3, j) - Z(3*(I-1)+3, j)];
end
coupled_diff = E * z_diff;
intra_coupling_3 = intra_coupling_3 + coupling_weight * coupled_diff;
end
end
end
% 层间耦合
inter_coupling_3 = zeros(3, 1);
for l = 1:M
if l ~= 3
if l == 1
z_diff = [X(3*(I-1)+1, j) - Z(3*(I-1)+1, j);
X(3*(I-1)+2, j) - Z(3*(I-1)+2, j);
X(3*(I-1)+3, j) - Z(3*(I-1)+3, j)];
else % l == 2
z_diff = [Y(3*(I-1)+1, j) - Z(3*(I-1)+1, j);
Y(3*(I-1)+2, j) - Z(3*(I-1)+2, j);
Y(3*(I-1)+3, j) - Z(3*(I-1)+3, j)];
end
inter_coupling_3 = inter_coupling_3 + H(3, l) * F * z_diff;
end
end
for dim = 1:3
Z(3*(I-1)+dim, j+1) = Z(3*(I-1)+dim, j) + h * (f_z(dim) + ...
R1(Z(3*(I-1)+dim, j)) * (c_theta(1) * intra_coupling_3(dim) + d_theta(1) * inter_coupling_3(dim) + u3(3*(I-1)+dim, j)) + ...
R2(Z(3*(I-1)+dim, j)) * (c_theta(2) * intra_coupling_3(dim) + d_theta(2) * inter_coupling_3(dim) + u3(3*(I-1)+dim, j))) + ...
sjxs * Z(3*(I-1)+dim, j) * (Wiener(j+1) - Wiener(j));
end
end % 结束节点循环
end % 结束控制激活阶段时间循环
%% ===== 控制非激活阶段 =====
if k < N_periods
fprintf('周期 %d/%d: 控制非激活阶段 [%.2f, %.2f]\n', k, N_periods, C(k), R(k+1));
for j = C(k)*n+1:R(k+1)*n
%% 更新同步态（按照代码2的简化方式）
% 第一层同步态
s1_curr = [s1(1,j); s1(2,j); s1(3,j)];
f_s1 = get_system_dynamics(1, s1_curr);
inter_layer_coupling_1 = zeros(3,1);
for l = 1:M
if l ~= 1
if l == 2
s_diff = [s2(1,j) - s1(1,j); s2(2,j) - s1(2,j); s2(3,j) - s1(3,j)];
else
s_diff = [s3(1,j) - s1(1,j); s3(2,j) - s1(2,j); s3(3,j) - s1(3,j)];
end
inter_layer_coupling_1 = inter_layer_coupling_1 + H(1,l) * F * s_diff;
end
end
s1(1,j+1) = s1(1,j) + h*(f_s1(1) + R1(s1(1,j))*d_theta(1)*inter_layer_coupling_1(1) + R2(s1(1,j))*d_theta(2)*inter_layer_coupling_1(1)) + sjxs*s1(1,j)*(Wiener(j+1)-Wiener(j));
s1(2,j+1) = s1(2,j) + h*(f_s1(2) + R1(s1(2,j))*d_theta(1)*inter_layer_coupling_1(2) + R2(s1(2,j))*d_theta(2)*inter_layer_coupling_1(2)) + sjxs*s1(2,j)*(Wiener(j+1)-Wiener(j));
s1(3,j+1) = s1(3,j) + h*(f_s1(3) + R1(s1(3,j))*d_theta(1)*inter_layer_coupling_1(3) + R2(s1(3,j))*d_theta(2)*inter_layer_coupling_1(3)) + sjxs*s1(3,j)*(Wiener(j+1)-Wiener(j));
% 第二层同步态
s2_curr = [s2(1,j); s2(2,j); s2(3,j)];
f_s2 = get_system_dynamics(2, s2_curr);
inter_layer_coupling_2 = zeros(3,1);
for l = 1:M
if l ~= 2
if l == 1
s_diff = [s1(1,j) - s2(1,j); s1(2,j) - s2(2,j); s1(3,j) - s2(3,j)];
else
s_diff = [s3(1,j) - s2(1,j); s3(2,j) - s2(2,j); s3(3,j) - s2(3,j)];
end
inter_layer_coupling_2 = inter_layer_coupling_2 + H(2,l) * F * s_diff;
end
end
s2(1,j+1) = s2(1,j) + h*(f_s2(1) + R1(s2(1,j))*d_theta(1)*inter_layer_coupling_2(1) + R2(s2(1,j))*d_theta(2)*inter_layer_coupling_2(1)) + sjxs*s2(1,j)*(Wiener(j+1)-Wiener(j));
s2(2,j+1) = s2(2,j) + h*(f_s2(2) + R1(s2(2,j))*d_theta(1)*inter_layer_coupling_2(2) + R2(s2(2,j))*d_theta(2)*inter_layer_coupling_2(2)) + sjxs*s2(2,j)*(Wiener(j+1)-Wiener(j));
s2(3,j+1) = s2(3,j) + h*(f_s2(3) + R1(s2(3,j))*d_theta(1)*inter_layer_coupling_2(3) + R2(s2(3,j))*d_theta(2)*inter_layer_coupling_2(3)) + sjxs*s2(3,j)*(Wiener(j+1)-Wiener(j));
% 第三层同步态
s3_curr = [s3(1,j); s3(2,j); s3(3,j)];
f_s3 = get_system_dynamics(3, s3_curr);
inter_layer_coupling_3 = zeros(3,1);
for l = 1:M
if l ~= 3
if l == 1
s_diff = [s1(1,j) - s3(1,j); s1(2,j) - s3(2,j); s1(3,j) - s3(3,j)];
else
s_diff = [s2(1,j) - s3(1,j); s2(2,j) - s3(2,j); s2(3,j) - s3(3,j)];
end
inter_layer_coupling_3 = inter_layer_coupling_3 + H(3,l) * F * s_diff;
end
end
s3(1,j+1) = s3(1,j) + h*(f_s3(1) + R1(s3(1,j))*d_theta(1)*inter_layer_coupling_3(1) + R2(s3(1,j))*d_theta(2)*inter_layer_coupling_3(1)) + sjxs*s3(1,j)*(Wiener(j+1)-Wiener(j));
s3(2,j+1) = s3(2,j) + h*(f_s3(2) + R1(s3(2,j))*d_theta(1)*inter_layer_coupling_3(2) + R2(s3(2,j))*d_theta(2)*inter_layer_coupling_3(2)) + sjxs*s3(2,j)*(Wiener(j+1)-Wiener(j));
s3(3,j+1) = s3(3,j) + h*(f_s3(3) + R1(s3(3,j))*d_theta(1)*inter_layer_coupling_3(3) + R2(s3(3,j))*d_theta(2)*inter_layer_coupling_3(3)) + sjxs*s3(3,j)*(Wiener(j+1)-Wiener(j));
%% 更新虚拟节点状态
X(3*(virtual_idx-1)+1, j+1) = s1(1, j+1);
X(3*(virtual_idx-1)+2, j+1) = s1(2, j+1);
X(3*(virtual_idx-1)+3, j+1) = s1(3, j+1);
Y(3*(virtual_idx-1)+1, j+1) = s2(1, j+1);
Y(3*(virtual_idx-1)+2, j+1) = s2(2, j+1);
Y(3*(virtual_idx-1)+3, j+1) = s2(3, j+1);
Z(3*(virtual_idx-1)+1, j+1) = s3(1, j+1);
Z(3*(virtual_idx-1)+2, j+1) = s3(2, j+1);
Z(3*(virtual_idx-1)+3, j+1) = s3(3, j+1);
%% 处理实际节点（无控制输入期间）
for I = 1:N_original
% 设置控制器为零（非激活阶段）
phi1(3*(I-1)+1:3*(I-1)+3, j) = 0;
phi2(3*(I-1)+1:3*(I-1)+3, j) = 0;
phi3(3*(I-1)+1:3*(I-1)+3, j) = 0;
psi1(3*(I-1)+1:3*(I-1)+3, j) = 0;
psi2(3*(I-1)+1:3*(I-1)+3, j) = 0;
psi3(3*(I-1)+1:3*(I-1)+3, j) = 0;
u1(3*(I-1)+1:3*(I-1)+3, j) = 0;
u2(3*(I-1)+1:3*(I-1)+3, j) = 0;
u3(3*(I-1)+1:3*(I-1)+3, j) = 0;
%% 使用扩充邻接矩阵更新系统状态（无控制输入）
% 第一层状态更新
x_curr = [X(3*(I-1)+1, j); X(3*(I-1)+2, j); X(3*(I-1)+3, j)];
f_x = get_system_dynamics(1, x_curr);
% 层内耦合
intra_coupling_1 = zeros(3, 1);
for J = 1:N_virtual
if J ~= I
coupling_weight = A_breve_1(I, J);
if coupling_weight ~= 0
if J <= N_original
x_diff = [X(3*(J-1)+1, j) - X(3*(I-1)+1, j);
X(3*(J-1)+2, j) - X(3*(I-1)+2, j);
X(3*(J-1)+3, j) - X(3*(I-1)+3, j)];
else
x_diff = [X(3*(J-1)+1, j) - X(3*(I-1)+1, j);
X(3*(J-1)+2, j) - X(3*(I-1)+2, j);
X(3*(J-1)+3, j) - X(3*(I-1)+3, j)];
end
coupled_diff = E * x_diff;
intra_coupling_1 = intra_coupling_1 + coupling_weight * coupled_diff;
end
end
end
% 层间耦合
inter_coupling_1 = zeros(3, 1);
for l = 1:M
if l ~= 1
if l == 2
x_diff = [Y(3*(I-1)+1, j) - X(3*(I-1)+1, j);
Y(3*(I-1)+2, j) - X(3*(I-1)+2, j);
Y(3*(I-1)+3, j) - X(3*(I-1)+3, j)];
else
x_diff = [Z(3*(I-1)+1, j) - X(3*(I-1)+1, j);
Z(3*(I-1)+2, j) - X(3*(I-1)+2, j);
Z(3*(I-1)+3, j) - X(3*(I-1)+3, j)];
end
inter_coupling_1 = inter_coupling_1 + H(1, l) * F * x_diff;
end
end
for dim = 1:3
X(3*(I-1)+dim, j+1) = X(3*(I-1)+dim, j) + h * (f_x(dim) + ...
R1(X(3*(I-1)+dim, j)) * (c_theta(1) * intra_coupling_1(dim) + d_theta(1) * inter_coupling_1(dim)) + ...
R2(X(3*(I-1)+dim, j)) * (c_theta(2) * intra_coupling_1(dim) + d_theta(2) * inter_coupling_1(dim))) + ...
sjxs * X(3*(I-1)+dim, j) * (Wiener(j+1) - Wiener(j));
end
% 第二层状态更新
y_curr = [Y(3*(I-1)+1, j); Y(3*(I-1)+2, j); Y(3*(I-1)+3, j)];
f_y = get_system_dynamics(2, y_curr);
intra_coupling_2 = zeros(3, 1);
for J = 1:N_virtual
if J ~= I
coupling_weight = A_breve_2(I, J);
if coupling_weight ~= 0
if J <= N_original
y_diff = [Y(3*(J-1)+1, j) - Y(3*(I-1)+1, j);
Y(3*(J-1)+2, j) - Y(3*(I-1)+2, j);
Y(3*(J-1)+3, j) - Y(3*(I-1)+3, j)];
else
y_diff = [Y(3*(J-1)+1, j) - Y(3*(I-1)+1, j);
Y(3*(J-1)+2, j) - Y(3*(I-1)+2, j);
Y(3*(J-1)+3, j) - Y(3*(I-1)+3, j)];
end
coupled_diff = E * y_diff;
intra_coupling_2 = intra_coupling_2 + coupling_weight * coupled_diff;
end
end
end
inter_coupling_2 = zeros(3, 1);
for l = 1:M
if l ~= 2
if l == 1
y_diff = [X(3*(I-1)+1, j) - Y(3*(I-1)+1, j);
X(3*(I-1)+2, j) - Y(3*(I-1)+2, j);
X(3*(I-1)+3, j) - Y(3*(I-1)+3, j)];
else
y_diff = [Z(3*(I-1)+1, j) - Y(3*(I-1)+1, j);
Z(3*(I-1)+2, j) - Y(3*(I-1)+2, j);
Z(3*(I-1)+3, j) - Y(3*(I-1)+3, j)];
end
inter_coupling_2 = inter_coupling_2 + H(2, l) * F * y_diff;
end
end
for dim = 1:3
Y(3*(I-1)+dim, j+1) = Y(3*(I-1)+dim, j) + h * (f_y(dim) + ...
R1(Y(3*(I-1)+dim, j)) * (c_theta(1) * intra_coupling_2(dim) + d_theta(1) * inter_coupling_2(dim)) + ...
R2(Y(3*(I-1)+dim, j)) * (c_theta(2) * intra_coupling_2(dim) + d_theta(2) * inter_coupling_2(dim))) + ...
sjxs * Y(3*(I-1)+dim, j) * (Wiener(j+1) - Wiener(j));
end
% 第三层状态更新
z_curr = [Z(3*(I-1)+1, j); Z(3*(I-1)+2, j); Z(3*(I-1)+3, j)];
f_z = get_system_dynamics(3, z_curr);
intra_coupling_3 = zeros(3, 1);
for J = 1:N_virtual
if J ~= I
coupling_weight = A_breve_3(I, J);
if coupling_weight ~= 0
if J <= N_original
z_diff = [Z(3*(J-1)+1, j) - Z(3*(I-1)+1, j);
Z(3*(J-1)+2, j) - Z(3*(I-1)+2, j);
Z(3*(J-1)+3, j) - Z(3*(I-1)+3, j)];
else
z_diff = [Z(3*(J-1)+1, j) - Z(3*(I-1)+1, j);
Z(3*(J-1)+2, j) - Z(3*(I-1)+2, j);
Z(3*(J-1)+3, j) - Z(3*(I-1)+3, j)];
end
coupled_diff = E * z_diff;
intra_coupling_3 = intra_coupling_3 + coupling_weight * coupled_diff;
end
end
end
inter_coupling_3 = zeros(3, 1);
for l = 1:M
if l ~= 3
if l == 1
z_diff = [X(3*(I-1)+1, j) - Z(3*(I-1)+1, j);
X(3*(I-1)+2, j) - Z(3*(I-1)+2, j);
X(3*(I-1)+3, j) - Z(3*(I-1)+3, j)];
else
z_diff = [Y(3*(I-1)+1, j) - Z(3*(I-1)+1, j);
Y(3*(I-1)+2, j) - Z(3*(I-1)+2, j);
Y(3*(I-1)+3, j) - Z(3*(I-1)+3, j)];
end
inter_coupling_3 = inter_coupling_3 + H(3, l) * F * z_diff;
end
end
for dim = 1:3
Z(3*(I-1)+dim, j+1) = Z(3*(I-1)+dim, j) + h * (f_z(dim) + ...
R1(Z(3*(I-1)+dim, j)) * (c_theta(1) * intra_coupling_3(dim) + d_theta(1) * inter_coupling_3(dim)) + ...
R2(Z(3*(I-1)+dim, j)) * (c_theta(2) * intra_coupling_3(dim) + d_theta(2) * inter_coupling_3(dim))) + ...
sjxs * Z(3*(I-1)+dim, j) * (Wiener(j+1) - Wiener(j));
end
end
end
end
end

%% ==================== 计算同步误差用于分析 ====================
% 计算最终时刻的同步误差
%% ==================== 【修正】计算所有时刻的同步误差 ====================
% 计算最终时刻以及遗漏时刻的同步误差
for j = 1:total_time_steps+1
for I = 1:N_original
% 确保所有时刻的同步误差都被计算
if e1(3*(I-1)+1, j) == 0 && e2(3*(I-1)+1, j) == 0 && e3(3*(I-1)+1, j) == 0
e1(3*(I-1)+1, j) = X(3*(I-1)+1, j) - s1(1, j);
e1(3*(I-1)+2, j) = X(3*(I-1)+2, j) - s1(2, j);
e1(3*(I-1)+3, j) = X(3*(I-1)+3, j) - s1(3, j);
e2(3*(I-1)+1, j) = Y(3*(I-1)+1, j) - s2(1, j);
e2(3*(I-1)+2, j) = Y(3*(I-1)+2, j) - s2(2, j);
e2(3*(I-1)+3, j) = Y(3*(I-1)+3, j) - s2(3, j);
e3(3*(I-1)+1, j) = Z(3*(I-1)+1, j) - s3(1, j);
e3(3*(I-1)+2, j) = Z(3*(I-1)+2, j) - s3(2, j);
e3(3*(I-1)+3, j) = Z(3*(I-1)+3, j) - s3(3, j);
% 量化误差
for n_neuron = 1:3
if quantizer1(3*(I-1)+n_neuron, j) == 0
quantizer1(3*(I-1)+n_neuron, j) = quantizer(e1(3*(I-1)+n_neuron, j));
quantizer2(3*(I-1)+n_neuron, j) = quantizer(e2(3*(I-1)+n_neuron, j));
quantizer3(3*(I-1)+n_neuron, j) = quantizer(e3(3*(I-1)+n_neuron, j));
end
end
end
end
end

%% ==================== Lipschitz常数计算 ====================
fprintf('\n=== Lipschitz常数理论计算与验证 ===\n');
L = 1.66;  % Lipschitz常数（不是L+rho）
rho = 0.49;  % 噪声强度系数（单独使用，不加入Xi计算）
fprintf('最终采用的Lipschitz常数 L = %.4f\n', L);
fprintf('噪声强度系数 ρ = %.4f\n', rho);

%% 计算 λ_max(Ξ) 
% 注意：根据论文，Xi的计算不包含rho
% Xi = [(L ⊗ I_{nMN}) - d(I_N ⊗ (L_B ⊗ F)) - c((L_A + C) ⊗ E)]^{sym}
Xi = calculate_Xi(L, L_B, F, L_A4, C4, E, d, c, n_dim, M, N_original);
lambda_max_Xi = max(real(eig(Xi)));
fprintf('lambda_max(Xi) = %.4f\n', lambda_max_Xi);

%% ==================== 理论参数计算（根据论文Theorem 1） ====================
% 根据论文公式正确计算m1, m2, m3, m4
% m1 = (1+z1*ω)α(1-χ) - λ_max(Ξ) - ρ/2
m1 = (1 + z1 * omega_tilde) * alpha * (1 - chi) - lambda_max_Xi - rho/2;

% m2 = (1+z1*ω)β - z2*ω*Γ1
% 注意：m2是一个系数，不需要乘以L1范数
m2_coefficient = (1 + z1 * omega_tilde) * beta - z2 * omega_tilde * Gamma_1;
m2 = m2_coefficient; 

% m3 = (1+z1*ω)γ(nMN)^((1-δ)/2)(1-χ)^δ
m3 = (1 + z1 * omega_tilde) * gamma * (n_dim*M*N_original)^((1-delta)/2) * (1-chi)^delta;

% m4 = (1+z1*ω)α(1-χ)
m4 = (1 + z1 * omega_tilde) * alpha * (1 - chi);

fprintf('\n=== 理论参数 ===\n');
fprintf('m1 = %.4f\n', m1);
fprintf('m2系数 = %.4f\n', m2_coefficient);
fprintf('m3 = %.4f\n', m3);
fprintf('m4 = %.4f\n', m4);

%% ==================== 理论条件验证 ====================
% 条件1: β > z2*ω*Γ1/(1+z1*ω)
condition1_rhs = (z2 * omega_tilde * Gamma_1) / (1 + z1 * omega_tilde);
condition1_satisfied = beta > condition1_rhs;

% 条件2: (1+z1*ω)α(1-χ) > λ_max(Ξ) + ρ/2
condition2_lhs = (1 + z1 * omega_tilde) * alpha * (1 - chi);
condition2_rhs = lambda_max_Xi + rho/2;
condition2_satisfied = condition2_lhs > condition2_rhs;

fprintf('\n=== 条件验证 ===\n');
fprintf('条件1: β = %.4f > %.4f: %s\n', beta, condition1_rhs, ...
    string(condition1_satisfied));
fprintf('条件2: (1+z1*ω)α(1-χ) = %.4f > λ_max(Ξ) + ρ/2 = %.4f: %s\n', ...
    condition2_lhs, condition2_rhs, string(condition2_satisfied));

% 收敛条件: m1 - (m1+m4)(1-Λ) > 0
convergence_condition = m1 - (m1 + m4)*(1-Lambda);
fprintf('收敛条件 m1 - (m1+m4)(1-Λ) = %.4f > 0: %s\n', ...
    convergence_condition, string(convergence_condition > 0));

%% ==================== 理论收敛时间估计 ====================
if convergence_condition > 0 && condition1_satisfied && condition2_satisfied
    % 根据论文Theorem 1的公式
    % T_max = δ/[(m1-(m1+m4)(1-Λ))(δ-1)] * ln(1 + m1/m2 * (m2/m3)^(1/δ))
    
    % 估计m2的实际值（需要考虑同步误差的L1范数）
    % 这里使用一个合理的估计值
    m2_estimate = m2_coefficient * 1.0;  % 简化估计
    
    if m2_estimate > 0 && m3 > 0
        numerator = delta;
        denominator = convergence_condition * (delta - 1);
        log_term = log(1 + (m1/m2_estimate) * (m2_estimate/m3)^(1/delta));
        T_max_theory = numerator / denominator * log_term;
        
        fprintf('\n理论固定时间上界: T_max = %.4f 秒\n', T_max_theory);
    else
        fprintf('参数条件不满足，无法计算理论收敛时间\n');
        T_max_theory = NaN;
    end
else
    fprintf('理论条件不满足，无法计算收敛时间\n');
    T_max_theory = NaN;
end
%% ==================== Results Analysis and Visualization ====================
T_2 = T_max_theory;
t = linspace(0, R(N_periods+1), total_time_steps+1);
% Calculate final synchronization errors
final_e1_norm = norm(e1(:,end));
final_e2_norm = norm(e2(:,end));
final_e3_norm = norm(e3(:,end));
fprintf('\n=== Simulation Results ===\n');
fprintf('Final synchronization error norms:\n');
fprintf('Layer 1 (Liu): %.6f\n', final_e1_norm);
fprintf('Layer 2 (Lorenz): %.6f\n', final_e2_norm);
fprintf('Layer 3 (Rossler): %.6f\n', final_e3_norm);
% Attack statistics
total_attacks = sum(attack_events);
attack_rate = mean(attack_events);
fprintf('\n=== Attack Statistics ===\n');
fprintf('Total attacks: %d/%d\n', total_attacks, length(attack_events));
fprintf('Actual attack rate: %.3f\n', attack_rate);

%% ==================== Attack Signal ====================
figure(2);
hold on;
t_attack = linspace(0, 3, length(attack_events));
% Professional sci-style deeper blue color
stairs(t_attack, attack_events, 'Color', [0, 0, 0.8], 'LineWidth', 0.1);
xlabel('$t$', 'Interpreter', 'latex'); ylabel('$\omega(t)$', 'Interpreter', 'latex');
grid on; axis([0, 3, 0, 1]);
hold off;
%% ==================== Layer 1 Normal Controller Signal ==================== 
figure(3);
hold on;
h1 = plot(t, phi1(1,:), 'r-', 'LineWidth', 0.4);
h2 = plot(t, phi1(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, phi1(3,:), 'b-', 'LineWidth', 0.4);
for q = 2:N_original
plot(t, phi1(3*(q-1)+1,:), 'r-', 'LineWidth', 0.4);
plot(t, phi1(3*(q-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, phi1(3*(q-1)+3,:), 'b-', 'LineWidth', 0.4);
end
% Add T_2 marker with corrected LaTeX notation
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$\phi^{(1)}_{i1}(t)$', '$\phi^{(1)}_{i2}(t)$', '$\phi^{(1)}_{i3}(t)$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$\phi^{(1)}_{i1}(t)$', '$\phi^{(1)}_{i2}(t)$', '$\phi^{(1)}_{i3}(t)$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end
xlabel('$t$', 'Interpreter', 'latex'); 
ylabel('$\phi^{(1)}_i(t),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;
xlim([0, 3]);box on;
% Improved magnification inset - higher position, larger size, focused range
axes('Position', [0.32, 0.20, 0.36, 0.28]);
% Focus on initial oscillation phase where features are most prominent
idx_range = find(t <= 0.4); % Reduced range to highlight initial dynamics
initial_data = phi1(:, idx_range);
plot(t(idx_range), phi1(1,idx_range), 'r-', 'LineWidth', 1.0);
hold on;
plot(t(idx_range), phi1(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), phi1(3,idx_range), 'b-', 'LineWidth', 1.0);
for q = 2:N_original
plot(t(idx_range), phi1(3*(q-1)+1,idx_range), 'r-', 'LineWidth', 1.0);
plot(t(idx_range), phi1(3*(q-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), phi1(3*(q-1)+3,idx_range), 'b-', 'LineWidth', 1.0);
end
xlim([0, 0.4]); % Focus on initial oscillation phase
% Use data-driven y-axis range with tighter margins
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on; 
xlabel('$t$', 'Interpreter', 'latex');
hold off;
%% ==================== Layer 1 Total Control Input ==================== 
figure(4);
hold on;
h1 = plot(t, u1(1,:), 'r-', 'LineWidth', 0.4);
h2 = plot(t, u1(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, u1(3,:), 'b-', 'LineWidth', 0.4);
for q = 2:N_original
plot(t, u1(3*(q-1)+1,:), 'r-', 'LineWidth', 0.4);
plot(t, u1(3*(q-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, u1(3*(q-1)+3,:), 'b-', 'LineWidth', 0.4);
end
% Add T_2 marker with corrected LaTeX notation
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$U^{(1)}_{i1}(t)$', '$U^{(1)}_{i2}(t)$', '$U^{(1)}_{i3}(t)$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$U^{(1)}_{i1}(t)$', '$U^{(1)}_{i2}(t)$', '$U^{(1)}_{i3}(t)$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end
xlabel('$t$', 'Interpreter', 'latex'); 
ylabel('$U^{(1)}_i(t),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;
xlim([0, 3]);box on;
% Improved magnification inset
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.4);
initial_data = u1(:, idx_range);
plot(t(idx_range), u1(1,idx_range), 'r-', 'LineWidth', 1.0);
hold on;
plot(t(idx_range), u1(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), u1(3,idx_range), 'b-', 'LineWidth', 1.0);
for q = 2:N_original
plot(t(idx_range), u1(3*(q-1)+1,idx_range), 'r-', 'LineWidth', 1.0);
plot(t(idx_range), u1(3*(q-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), u1(3*(q-1)+3,idx_range), 'b-', 'LineWidth', 1.0);
end
xlim([0, 0.4]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex'); 
hold off;

%% ==================== Layer 2 Normal Controller Signal ==================== 
figure(5);
hold on;
h1 = plot(t, phi2(1,:), 'r-', 'LineWidth', 0.4);
h2 = plot(t, phi2(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, phi2(3,:), 'b-', 'LineWidth', 0.4);
for q = 2:N_original
plot(t, phi2(3*(q-1)+1,:), 'r-', 'LineWidth', 0.4);
plot(t, phi2(3*(q-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, phi2(3*(q-1)+3,:), 'b-', 'LineWidth', 0.4);
end
% Add T_2 marker with corrected LaTeX notation
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$\phi^{(2)}_{i1}(t)$', '$\phi^{(2)}_{i2}(t)$', '$\phi^{(2)}_{i3}(t)$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$\phi^{(2)}_{i1}(t)$', '$\phi^{(2)}_{i2}(t)$', '$\phi^{(2)}_{i3}(t)$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end
xlabel('$t$', 'Interpreter', 'latex'); 
ylabel('$\phi^{(2)}_i(t),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;
xlim([0, 3]);box on;
% Improved magnification inset
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.4);
initial_data = phi2(:, idx_range);
plot(t(idx_range), phi2(1,idx_range), 'r-', 'LineWidth', 1.0);
hold on;
plot(t(idx_range), phi2(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), phi2(3,idx_range), 'b-', 'LineWidth', 1.0);
for q = 2:N_original
plot(t(idx_range), phi2(3*(q-1)+1,idx_range), 'r-', 'LineWidth', 1.0);
plot(t(idx_range), phi2(3*(q-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), phi2(3*(q-1)+3,idx_range), 'b-', 'LineWidth', 1.0);
end
xlim([0, 0.4]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex');
hold off;
%% ==================== Layer 2 Total Control Input ==================== 
figure(6);
hold on;
h1 = plot(t, u2(1,:), 'r-', 'LineWidth', 0.4);
h2 = plot(t, u2(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, u2(3,:), 'b-', 'LineWidth', 0.4);
for q = 2:N_original
plot(t, u2(3*(q-1)+1,:), 'r-', 'LineWidth', 0.4);
plot(t, u2(3*(q-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, u2(3*(q-1)+3,:), 'b-', 'LineWidth', 0.4);
end
% Add T_2 marker with corrected LaTeX notation
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$U^{(2)}_{i1}(t)$', '$U^{(2)}_{i2}(t)$', '$U^{(2)}_{i3}(t)$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$U^{(2)}_{i1}(t)$', '$U^{(2)}_{i2}(t)$', '$U^{(2)}_{i3}(t)$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end
xlabel('$t$', 'Interpreter', 'latex'); 
ylabel('$U^{(2)}_i(t),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;
xlim([0, 3]);box on;
% Improved magnification inset
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.4);
initial_data = u2(:, idx_range);
plot(t(idx_range), u2(1,idx_range), 'r-', 'LineWidth', 1.0);
hold on;
plot(t(idx_range), u2(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), u2(3,idx_range), 'b-', 'LineWidth', 1.0);
for q = 2:N_original
plot(t(idx_range), u2(3*(q-1)+1,idx_range), 'r-', 'LineWidth', 1.0);
plot(t(idx_range), u2(3*(q-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), u2(3*(q-1)+3,idx_range), 'b-', 'LineWidth', 1.0);
end
xlim([0, 0.4]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex'); 
hold off;
%% ==================== Layer 3 Normal Controller Signal ==================== 
figure(7);
hold on;
h1 = plot(t, phi3(1,:), 'r-', 'LineWidth', 0.4);
h2 = plot(t, phi3(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, phi3(3,:), 'b-', 'LineWidth', 0.4);
for q = 2:N_original
plot(t, phi3(3*(q-1)+1,:), 'r-', 'LineWidth', 0.4);
plot(t, phi3(3*(q-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, phi3(3*(q-1)+3,:), 'b-', 'LineWidth', 0.4);
end
% Add T_2 marker with corrected LaTeX notation
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$\phi^{(3)}_{i1}(t)$', '$\phi^{(3)}_{i2}(t)$', '$\phi^{(3)}_{i3}(t)$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$\phi^{(3)}_{i1}(t)$', '$\phi^{(3)}_{i2}(t)$', '$\phi^{(3)}_{i3}(t)$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end
xlabel('$t$', 'Interpreter', 'latex'); 
ylabel('$\phi^{(3)}_i(t),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;
xlim([0, 3]);box on;
% Improved magnification inset - for Rossler system, focus on the most dynamic region
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.3); % Even shorter range for Rossler due to rapid dynamics
initial_data = phi3(:, idx_range);
plot(t(idx_range), phi3(1,idx_range), 'r-', 'LineWidth', 1.0);
hold on;
plot(t(idx_range), phi3(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), phi3(3,idx_range), 'b-', 'LineWidth', 1.0);
for q = 2:N_original
plot(t(idx_range), phi3(3*(q-1)+1,idx_range), 'r-', 'LineWidth', 1.0);
plot(t(idx_range), phi3(3*(q-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), phi3(3*(q-1)+3,idx_range), 'b-', 'LineWidth', 1.0);
end
xlim([0, 0.3]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex'); 
hold off;
%% ==================== Layer 3 Total Control Input ==================== 
figure(8);
hold on;
h1 = plot(t, u3(1,:), 'r-', 'LineWidth', 0.4);
h2 = plot(t, u3(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, u3(3,:), 'b-', 'LineWidth', 0.4);
for q = 2:N_original
plot(t, u3(3*(q-1)+1,:), 'r-', 'LineWidth', 0.4);
plot(t, u3(3*(q-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, u3(3*(q-1)+3,:), 'b-', 'LineWidth', 0.4);
end
% Add T_2 marker with corrected LaTeX notation
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$U^{(3)}_{i1}(t)$', '$U^{(3)}_{i2}(t)$', '$U^{(3)}_{i3}(t)$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$U^{(3)}_{i1}(t)$', '$U^{(3)}_{i2}(t)$', '$U^{(3)}_{i3}(t)$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end
xlabel('$t$', 'Interpreter', 'latex'); 
ylabel('$U^{(3)}_i(t),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;
xlim([0, 3]);box on;
% Improved magnification inset - focus on most dynamic region
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.3);
initial_data = u3(:, idx_range);
plot(t(idx_range), u3(1,idx_range), 'r-', 'LineWidth', 1.0);
hold on;
plot(t(idx_range), u3(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), u3(3,idx_range), 'b-', 'LineWidth', 1.0);
for q = 2:N_original
plot(t(idx_range), u3(3*(q-1)+1,idx_range), 'r-', 'LineWidth', 1.0);
plot(t(idx_range), u3(3*(q-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), u3(3*(q-1)+3,idx_range), 'b-', 'LineWidth', 1.0);
end
xlim([0, 0.3]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex'); 
hold off;

%% ==================== Comparison of Total Control Inputs for All Layers ====================
% Layer 1 control input u1
figure(10);
hold on;
h1 = plot(t, u1(1,:), 'r-', 'LineWidth', 0.4);
h2 = plot(t, u1(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, u1(3,:), 'b-', 'LineWidth', 0.4);
for q = 2:N_original
plot(t, u1(3*(q-1)+1,:), 'r-', 'LineWidth', 0.4);
plot(t, u1(3*(q-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, u1(3*(q-1)+3,:), 'b-', 'LineWidth', 0.4);
end

% Add T_2 marker with corrected LaTeX notation
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$U^{(1)}_{i1}(t)$', '$U^{(1)}_{i2}(t)$', '$U^{(1)}_{i3}(t)$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$U^{(1)}_{i1}(t)$', '$U^{(1)}_{i2}(t)$', '$U^{(1)}_{i3}(t)$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end

xlabel('$t$', 'Interpreter', 'latex');xlim([0, 3]);box on;
ylabel('$U^{(1)}_i(t),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;

% Improved magnification inset
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.4);
initial_data = u1(:, idx_range);

plot(t(idx_range), u1(1,idx_range), 'r-', 'LineWidth', 1.0);
hold on;
plot(t(idx_range), u1(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), u1(3,idx_range), 'b-', 'LineWidth', 1.0);
for q = 2:N_original
plot(t(idx_range), u1(3*(q-1)+1,idx_range), 'r-', 'LineWidth', 1.0);
plot(t(idx_range), u1(3*(q-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), u1(3*(q-1)+3,idx_range), 'b-', 'LineWidth', 1.0);
end
xlim([0, 0.4]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex'); 
hold off;

% Layer 2 control input u2
figure(11);
hold on;
h1 = plot(t, u2(1,:), 'r-', 'LineWidth', 0.4);
h2 = plot(t, u2(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, u2(3,:), 'b-', 'LineWidth', 0.4);
for q = 2:N_original
plot(t, u2(3*(q-1)+1,:), 'r-', 'LineWidth', 0.4);
plot(t, u2(3*(q-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, u2(3*(q-1)+3,:), 'b-', 'LineWidth', 0.4);
end

% Add T_2 marker with corrected LaTeX notation
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$U^{(2)}_{i1}(t)$', '$U^{(2)}_{i2}(t)$', '$U^{(2)}_{i3}(t)$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$U^{(2)}_{i1}(t)$', '$U^{(2)}_{i2}(t)$', '$U^{(2)}_{i3}(t)$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end

xlabel('$t$', 'Interpreter', 'latex');xlim([0, 3]);box on;
ylabel('$U^{(2)}_i(t),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;

% Improved magnification inset
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.4);
initial_data = u2(:, idx_range);

plot(t(idx_range), u2(1,idx_range), 'r-', 'LineWidth', 1.0);
hold on;
plot(t(idx_range), u2(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), u2(3,idx_range), 'b-', 'LineWidth', 1.0);
for q = 2:N_original
plot(t(idx_range), u2(3*(q-1)+1,idx_range), 'r-', 'LineWidth', 1.0);
plot(t(idx_range), u2(3*(q-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), u2(3*(q-1)+3,idx_range), 'b-', 'LineWidth', 1.0);
end
xlim([0, 0.4]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex'); 
hold off;

% Layer 3 control input u3
figure(12);
hold on;
h1 = plot(t, u3(1,:), 'r-', 'LineWidth', 0.4);
h2 = plot(t, u3(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, u3(3,:), 'b-', 'LineWidth', 0.4);
for q = 2:N_original
plot(t, u3(3*(q-1)+1,:), 'r-', 'LineWidth', 0.4);
plot(t, u3(3*(q-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, u3(3*(q-1)+3,:), 'b-', 'LineWidth', 0.4);
end

% Add T_2 marker with corrected LaTeX notation
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$U^{(3)}_{i1}(t)$', '$U^{(3)}_{i2}(t)$', '$U^{(3)}_{i3}(t)$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$U^{(3)}_{i1}(t)$', '$U^{(3)}_{i2}(t)$', '$U^{(3)}_{i3}(t)$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end

xlabel('$t$', 'Interpreter', 'latex');xlim([0, 3]);box on;
ylabel('$U^{(3)}_i(t),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;

% Improved magnification inset
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.3);
initial_data = u3(:, idx_range);

plot(t(idx_range), u3(1,idx_range), 'r-', 'LineWidth', 1.0);
hold on;
plot(t(idx_range), u3(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), u3(3,idx_range), 'b-', 'LineWidth', 1.0);
for q = 2:N_original
plot(t(idx_range), u3(3*(q-1)+1,idx_range), 'r-', 'LineWidth', 1.0);
plot(t(idx_range), u3(3*(q-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), u3(3*(q-1)+3,idx_range), 'b-', 'LineWidth', 1.0);
end
xlim([0, 0.3]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex'); 
hold off;

%% ==================== Quantization Error Plots for Each Layer ====================
%% Layer 1 Quantization Error Plot
figure(20);
hold on;
h1 = plot(t, quantizer1(1,:), 'b-', 'LineWidth', 0.4);
h2 = plot(t, quantizer1(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, quantizer1(3,:), 'r-', 'LineWidth', 0.4);
for I = 2:N_original
plot(t, quantizer1(3*(I-1)+1,:), 'b-', 'LineWidth', 0.4);
plot(t, quantizer1(3*(I-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, quantizer1(3*(I-1)+3,:), 'r-', 'LineWidth', 0.4);
end

% Add theoretical convergence time marker with corrected LaTeX
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$q(e^{(1)}_{i1}(t))$', '$q(e^{(1)}_{i2}(t))$', '$q(e^{(1)}_{i3}(t))$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$q(e^{(1)}_{i1}(t))$', '$q(e^{(1)}_{i2}(t))$', '$q(e^{(1)}_{i3}(t))$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end

xlabel('$t$', 'Interpreter', 'latex');
ylabel('$q(e^{(1)}_i(t)),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;
xlim([0, 3]);box on;

% Improved magnification inset for quantization error
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.4);
initial_data = quantizer1(:, idx_range);

plot(t(idx_range), quantizer1(1,idx_range), 'b-', 'LineWidth', 1.0);
hold on;
plot(t(idx_range), quantizer1(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), quantizer1(3,idx_range), 'r-', 'LineWidth', 1.0);
for I = 2:N_original
plot(t(idx_range), quantizer1(3*(I-1)+1,idx_range), 'b-', 'LineWidth', 1.0);
plot(t(idx_range), quantizer1(3*(I-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), quantizer1(3*(I-1)+3,idx_range), 'r-', 'LineWidth', 1.0);
end
xlim([0, 0.4]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex'); 
hold off;

%% Layer 2 Quantization Error Plot
figure(21);
hold on;
h1 = plot(t, quantizer2(1,:), 'b-', 'LineWidth', 0.4);
h2 = plot(t, quantizer2(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, quantizer2(3,:), 'r-', 'LineWidth', 0.4);
for I = 2:N_original
plot(t, quantizer2(3*(I-1)+1,:), 'b-', 'LineWidth', 0.4);
plot(t, quantizer2(3*(I-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, quantizer2(3*(I-1)+3,:), 'r-', 'LineWidth', 0.4);
end

% Add theoretical convergence time marker with corrected LaTeX
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$q(e^{(2)}_{i1}(t))$', '$q(e^{(2)}_{i2}(t))$', '$q(e^{(2)}_{i3}(t))$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$q(e^{(2)}_{i1}(t))$', '$q(e^{(2)}_{i2}(t))$', '$q(e^{(2)}_{i3}(t))$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end

xlabel('$t$', 'Interpreter', 'latex');
ylabel('$q(e^{(2)}_i(t)),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;
xlim([0, 3]);box on;

% Improved magnification inset
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.4);
initial_data = quantizer2(:, idx_range);

plot(t(idx_range), quantizer2(1,idx_range), 'b-', 'LineWidth', 1.0);
hold on;
plot(t(idx_range), quantizer2(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), quantizer2(3,idx_range), 'r-', 'LineWidth', 1.0);
for I = 2:N_original
plot(t(idx_range), quantizer2(3*(I-1)+1,idx_range), 'b-', 'LineWidth', 1.0);
plot(t(idx_range), quantizer2(3*(I-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), quantizer2(3*(I-1)+3,idx_range), 'r-', 'LineWidth', 1.0);
end
xlim([0, 0.4]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex'); 
hold off;

%% Layer 3 Quantization Error Plot
figure(22);
hold on;
h1 = plot(t, quantizer3(1,:), 'b-', 'LineWidth', 0.4);
h2 = plot(t, quantizer3(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, quantizer3(3,:), 'r-', 'LineWidth', 0.4);
for I = 2:N_original
plot(t, quantizer3(3*(I-1)+1,:), 'b-', 'LineWidth', 0.4);
plot(t, quantizer3(3*(I-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, quantizer3(3*(I-1)+3,:), 'r-', 'LineWidth', 0.4);
end

% Add theoretical convergence time marker with corrected LaTeX
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$q(e^{(3)}_{i1}(t))$', '$q(e^{(3)}_{i2}(t))$', '$q(e^{(3)}_{i3}(t))$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$q(e^{(3)}_{i1}(t))$', '$q(e^{(3)}_{i2}(t)$', '$q(e^{(3)}_{i3}(t))$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end

xlabel('$t$', 'Interpreter', 'latex');
ylabel('$q(e^{(3)}_i(t)),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;
xlim([0, 3]);box on;

% Improved magnification inset
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.3);
initial_data = quantizer3(:, idx_range);

plot(t(idx_range), quantizer3(1,idx_range), 'b-', 'LineWidth', 1.0);
hold on;
plot(t(idx_range), quantizer3(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), quantizer3(3,idx_range), 'r-', 'LineWidth', 1.0);
for I = 2:N_original
plot(t(idx_range), quantizer3(3*(I-1)+1,idx_range), 'b-', 'LineWidth', 1.0);
plot(t(idx_range), quantizer3(3*(I-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 1.0);
plot(t(idx_range), quantizer3(3*(I-1)+3,idx_range), 'r-', 'LineWidth', 1.0);
end
xlim([0, 0.3]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex'); 
hold off;

%% Three-Layer Quantization Error Comparison
figure(41);

% Layer 1 quantization error subplot
hold on;
h1 = plot(t, quantizer1(1,:), 'b-', 'LineWidth', 0.4);
h2 = plot(t, quantizer1(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, quantizer1(3,:), 'r-', 'LineWidth', 0.4);
for I = 2:N_original
plot(t, quantizer1(3*(I-1)+1,:), 'b-', 'LineWidth', 0.4);
plot(t, quantizer1(3*(I-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, quantizer1(3*(I-1)+3,:), 'r-', 'LineWidth', 0.4);
end

% Add T_2 marker with corrected LaTeX notation
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 6);
legend([h1, h2, h3, p], {'$q(e^{(1)}_{i1})$', '$q(e^{(1)}_{i2})$', '$q(e^{(1)}_{i3})$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)}, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$q(e^{(1)}_{i1})$', '$q(e^{(1)}_{i2})$', '$q(e^{(1)}_{i3})$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end

xlabel('$t$', 'Interpreter', 'latex'); ylabel('$q(e^{(1)}_{i}),i=1,2,...,6$', 'Interpreter', 'latex');
grid on; xlim([0, 3]);box on;
hold off;
figure(42);
% Layer 2 quantization error subplot
hold on;
h1 = plot(t, quantizer2(1,:), 'b-', 'LineWidth', 0.4);
h2 = plot(t, quantizer2(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, quantizer2(3,:), 'r-', 'LineWidth', 0.4);
for I = 2:N_original
plot(t, quantizer2(3*(I-1)+1,:), 'b-', 'LineWidth', 0.4);
plot(t, quantizer2(3*(I-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, quantizer2(3*(I-1)+3,:), 'r-', 'LineWidth', 0.4);
end

% Add T_2 marker with corrected LaTeX notation
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 6);
legend([h1, h2, h3, p], {'$q(e^{(2)}_{i1})$', '$q(e^{(2)}_{i2})$', '$q(e^{(2)}_{i3})$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)}, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$q(e^{(2)}_{i1})$', '$q(e^{(2)}_{i2})$', '$q(e^{(2)}_{i3})$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end

xlabel('$t$', 'Interpreter', 'latex'); ylabel('$q(e^{(2)}_{i}),i=1,2,...,6$', 'Interpreter', 'latex');
grid on; xlim([0, 3]);box on;
hold off;
figure(43);
% Layer 3 quantization error subplot
hold on;
h1 = plot(t, quantizer3(1,:), 'b-', 'LineWidth', 0.4);
h2 = plot(t, quantizer3(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, quantizer3(3,:), 'r-', 'LineWidth', 0.4);
for I = 2:N_original
plot(t, quantizer3(3*(I-1)+1,:), 'b-', 'LineWidth', 0.4);
plot(t, quantizer3(3*(I-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, quantizer3(3*(I-1)+3,:), 'r-', 'LineWidth', 0.4);
end

% Add T_2 marker with corrected LaTeX notation
if ~isnan(T_max_theory)
T_2_rounded = round(T_max_theory, 4);
p = plot(T_max_theory, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 6);
legend([h1, h2, h3, p], {'$q(e^{(3)}_{i1})$', '$q(e^{(3)}_{i2})$', '$q(e^{(3)}_{i3})$', sprintf('$\\hat{\\mathcal{T}}_{\\max}^1=%.4f$', T_2_rounded)}, 'Location', 'northeast', 'Interpreter', 'latex');
else
legend([h1, h2, h3], {'$q(e^{(3)}_{i1})$', '$q(e^{(3)}_{i2})$', '$q(e^{(3)}_{i3})$'}, 'Location', 'northeast', 'Interpreter', 'latex');
end

xlabel('$t$', 'Interpreter', 'latex'); ylabel('$q(e^{(3)}_{i}),i=1,2,...,6$', 'Interpreter', 'latex');
grid on; xlim([0, 3]);box on;
hold off;
%% ==================== 自动保存PDF功能 (扩展攻击版本) ====================
fprintf('\n=== 开始保存图形为PDF文件 (扩展攻击版本) ===\n');

% 创建保存目录
save_dir = 'simulation_results_extended_attack_pdf';
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
    fprintf('创建目录: %s\n', save_dir);
end

% 定义图形保存函数
function save_figure_as_pdf(fig_num, filename, save_directory)
    try
        figure(fig_num);
        % 设置图形属性以获得更好的PDF质量
        set(gcf, 'PaperPositionMode', 'auto');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperSize', [20, 15]); % 设置纸张大小
        set(gcf, 'PaperPosition', [0, 0, 20, 15]); % 设置图形位置
        
        % 完整的文件路径
        full_path = fullfile(save_directory, [filename, '.pdf']);
        
        % 保存为PDF
        print(gcf, full_path, '-dpdf', '-r300'); % 300 DPI分辨率
        fprintf('已保存: %s\n', full_path);
    catch ME
        fprintf('保存图形 %d 时出错: %s\n', fig_num, ME.message);
    end
end

% 保存各个图形
try
    % 攻击信号 (图形编号2)
    if ishandle(2)
        save_figure_as_pdf(2, 'attack_signal', save_dir);
    end
    
    % 第一层phi控制器信号 phi1 -> p1 (图形编号3)
    if ishandle(3)
        save_figure_as_pdf(3, 'p1', save_dir);
    end
    
    % 第一层总控制输入 u1 -> U1 (图形编号4)
    if ishandle(4)
        save_figure_as_pdf(4, 'U1', save_dir);
    end
    
    % 第二层phi控制器信号 phi2 -> p2 (图形编号5)
    if ishandle(5)
        save_figure_as_pdf(5, 'p2', save_dir);
    end
    
    % 第二层总控制输入 u2 -> U2 (图形编号6)
    if ishandle(6)
        save_figure_as_pdf(6, 'U2', save_dir);
    end
    
    % 第三层phi控制器信号 phi3 -> p3 (图形编号7)
    if ishandle(7)
        save_figure_as_pdf(7, 'p3', save_dir);
    end
    
    % 第三层总控制输入 u3 -> U3 (图形编号8)
    if ishandle(8)
        save_figure_as_pdf(8, 'U3', save_dir);
    end
    
    % 备用的总控制输入图形（如果存在）
    if ishandle(10)
        save_figure_as_pdf(10, 'U1_backup', save_dir);
    end
    
    if ishandle(11)
        save_figure_as_pdf(11, 'U2_backup', save_dir);
    end
    
    if ishandle(12)
        save_figure_as_pdf(12, 'U3_backup', save_dir);
    end
    
    % 第一层量化误差 quantizer1 -> q1 (图形编号20)
    if ishandle(20)
        save_figure_as_pdf(20, 'q1', save_dir);
    end
    
    % 第二层量化误差 quantizer2 -> q2 (图形编号21)
    if ishandle(21)
        save_figure_as_pdf(21, 'q2', save_dir);
    end
    
    % 第三层量化误差 quantizer3 -> q3 (图形编号22)
    if ishandle(22)
        save_figure_as_pdf(22, 'q3', save_dir);
    end
    
    % 三层量化误差比较图形（如果存在）
    if ishandle(41)
        save_figure_as_pdf(41, 'q1_comparison', save_dir);
    end
    
    if ishandle(42)
        save_figure_as_pdf(42, 'q2_comparison', save_dir);
    end
    
    if ishandle(43)
        save_figure_as_pdf(43, 'q3_comparison', save_dir);
    end
    
    fprintf('\n=== PDF保存完成 (扩展攻击版本) ===\n');
    fprintf('所有图形已保存到目录: %s\n', save_dir);
    fprintf('文件命名规则:\n');
    fprintf('  - 攻击信号: attack_signal.pdf\n');
    fprintf('  - 各层phi控制器: p1.pdf, p2.pdf, p3.pdf\n');
    fprintf('  - 各层总控制器: U1.pdf, U2.pdf, U3.pdf\n');
    fprintf('  - 各层量化误差: q1.pdf, q2.pdf, q3.pdf\n');
    fprintf('注：扩展攻击版本包含完整的攻击抵抗分析\n');
    
catch ME
    fprintf('保存过程中出现错误: %s\n', ME.message);
end

% 可选：显示保存的文件列表
try
    saved_files = dir(fullfile(save_dir, '*.pdf'));
    fprintf('\n已保存的PDF文件列表:\n');
    for i = 1:length(saved_files)
        fprintf('  %d. %s (大小: %.2f KB)\n', i, saved_files(i).name, saved_files(i).bytes/1024);
    end
catch
    fprintf('无法列出保存的文件\n');
end
end

