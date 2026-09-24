% Bernoulli_Attack_Vis_Corrected.m
clear all; close all; clc;

%% 1. 时间参数设置 (Time Setup)
% 保持与第一个代码相同的时间长度，以便观察
Tmax = 3;          % 总时间 (秒)
h = 0.005;          % 步长 (精度)
t = 0:h:Tmax;       % 生成正确的时间向量 t
m = length(t);      % 采样点总数

%% 2. 伯努利攻击参数 (Attack Parameters)
% 严格采用第二个代码 (multilayer_fuzzy...m) 中的参数
omega_tilde = 0.7;  % 攻击发生的概率 (Attack Probability)

%% 3. 生成随机攻击信号 (Signal Generation)
% 使用 binornd 生成伯努利分布序列 (0 或 1)
% 这里的 1 代表 N=1 (单次实验)，omega_tilde 为成功的概率
% 设置随机种子以便复现结果 (可选)
rand('state', 100); 
w_t = binornd(1, omega_tilde, 1, m);

%% 4. 可视化 (Visualization)
figure(1);

% 核心修正：stairs 的第一个参数必须是时间向量 t
% 样式参考：蓝色线条，线宽适中以便看清 (第一个代码的0.01太细，这里调整为0.6)
stairs(t, w_t, 'Color', 'b', 'LineWidth', 0.5);

% 5. 坐标轴与标签设置 (LaTeX Formatting)
% 限制横坐标为 0 到 Tmax，纵坐标为 -0.1 到 1.1 以便清楚看到 0 和 1 的状态
axis([0, Tmax, -0.1, 1.1]); 

% 添加 LaTeX 格式的标签
leg1 = xlabel('$t$');
leg2 = ylabel('$\omega(t)$'); % 攻击信号通常记为 omega(t) 或 w(t)
set(leg1, 'Interpreter', 'latex', 'FontSize', 12);
set(leg2, 'Interpreter', 'latex', 'FontSize', 12);

% 添加网格和标题
grid on;


% 去除多余的留白
box on;
