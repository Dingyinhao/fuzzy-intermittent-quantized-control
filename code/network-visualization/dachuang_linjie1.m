% 优雅阴影字体版本 - 三维多层网络可视化（修改版）
% 更大椭圆底面，透明标签，Times New Roman字体，简化图例
% Z轴标注修改为1,2,3对应Layer 1,2,3

clear; clc; close all;

%% 设置专业绘图参数 - 统一使用Times New Roman字体
set(0,'DefaultFigureColor','w');
set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultAxesFontSize',12);
set(0,'DefaultTextFontName','Times New Roman');
set(0,'DefaultTextFontSize',12);
set(0,'DefaultTextInterpreter','latex');
set(0,'DefaultAxesTickLabelInterpreter','latex');
set(0,'DefaultLegendInterpreter','latex');

%% 定义三层网络的邻接矩阵（已验证对称性）
% 第一层邻接矩阵 L_A^(1)
L_A1 = [3  -0.6 -0.6 -0.6 -0.6 -0.6;
       -0.6 1.2 -0.6  0    0    0;
       -0.6 -0.6 1.8 -0.6 0    0;
       -0.6 0   -0.6  1.2 0    0;
       -0.6 0    0     0   1.2 -0.6;
       -0.6 0    0     0  -0.6 1.2];

% 第二层邻接矩阵 L_A^(2)
L_A2 = [0.4   0   -0.2  -0.2   0     0;
        0    0.45 -0.15  0    -0.1  -0.2;
       -0.2  -0.15 0.5   0    -0.15  0;
       -0.2   0     0    0.35 -0.05 -0.1;
        0    -0.1  -0.15 -0.05 0.3   0;
        0    -0.2   0    -0.1   0    0.3];

% 第三层邻接矩阵 L_A^(3) - 修改为对称且行和为0
L_A3 =  [2.5  -0.5  -0.5  -0.5  -0.5   0;
       -0.5   2    -0.5   0    -0.5  -0.5;
       -0.5  -0.5   2    -0.5   0    -0.5;
       -0.5   0    -0.5   2    -0.5  -0.5;
       -0.5  -0.5   0    -0.5   2    -0.5;
        0    -0.5  -0.5  -0.5  -0.5   2.5];
layers = {L_A1, L_A2, L_A3};

%% 节点位置设置（优化的3D布局）
% 六边形排列，增强可视化效果
theta = linspace(0, 2*pi, 7);
theta = theta(1:6);  % 6个节点
radius = 3.0;
node_x = radius * cos(theta);
node_y = radius * sin(theta);

% 调整节点1到顶部位置
node_positions = [
    node_x(1), node_y(1);   % 节点1 (顶部)
    node_x(2), node_y(2);   % 节点2 (右上)
    node_x(3), node_y(3);   % 节点3 (右下)
    node_x(4), node_y(4);   % 节点4 (底部)
    node_x(5), node_y(5);   % 节点5 (左下)
    node_x(6), node_y(6);   % 节点6 (左上)
];

%% 创建3D图形
fig = figure('Position', [50, 50, 1400, 1000]);
fig.Color = 'white';

% 定义每层的Z坐标（保持原有间距）
z_levels = [1, 2, 3];
z_layers = [0, 4, 8];  % 实际绘制高度（保持不变）

layer_names = {'Layer 1', 'Layer 2', 'Layer 3'};

%% 定义颜色方案
% 节点颜色
node_colors = [
    0.3, 0.7, 1.0;    % 第一层节点：浅蓝色
    1.0, 0.6, 0.2;    % 第二层节点：橙色
    0.4, 0.8, 0.4;    % 第三层节点：绿色
];

% 层背景颜色
layer_bg_colors = [
    0.3, 0.7, 1.0;     % 第一层背景：与节点相同的蓝色
    1.0, 0.6, 0.2;     % 第二层背景：与节点相同的橙色
    0.4, 0.8, 0.4;     % 第三层背景：与节点相同的绿色
];

hold on;

%% 绘制每层的椭圆形背景平面（更大的椭圆）
for layer = 1:3
    z = z_layers(layer);
    
    % 创建更大的椭圆形背景
    t = linspace(0, 2*pi, 100);
    a = 6.0;  % 长轴（增大）
    b = 4.5;  % 短轴（增大）
    bg_x = a * cos(t);
    bg_y = b * sin(t);
    bg_z = z * ones(size(t));
    
    % 绘制更淡的半透明背景
    fill3(bg_x, bg_y, bg_z, layer_bg_colors(layer,:), ...
        'FaceAlpha', 0.1, 'EdgeColor', layer_bg_colors(layer,:) * 0.6, ...
        'LineWidth', 1.5);
end

%% 绘制每层网络
for layer = 1:3
    A = layers{layer};
    z = z_layers(layer);
    z_level = z_levels(layer);
    
    %% 绘制层内节点间的实线连接（只显示红色连接）
    for i = 1:6
        for j = i+1:6  % 只遍历上三角矩阵，避免重复显示
            if abs(A(i,j)) > 0.05
                x_line = [node_positions(i,1), node_positions(j,1)];
                y_line = [node_positions(i,2), node_positions(j,2)];
                z_line = [z, z];
                
                % 统一使用红色连接
                plot3(x_line, y_line, z_line, '-', ...
                    'Color', [0.8, 0.2, 0.2], 'LineWidth', 2);
            end
        end
    end
    
    %% 绘制节点
    for i = 1:6
        % 节点主体
        plot3(node_positions(i,1), node_positions(i,2), z, 'o', ...
            'MarkerSize', 28, 'MarkerFaceColor', node_colors(layer,:), ...
            'MarkerEdgeColor', [0.2, 0.2, 0.2], 'LineWidth', 2.5);
        
        % 节点编号 - 优雅阴影效果（只在右下角添加阴影）
        % 深灰色阴影
        text(node_positions(i,1) + 0.02, node_positions(i,2) - 0.02, z + 0.04, sprintf('%d', i), ...
            'FontSize', 17, 'FontWeight', 'normal', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'Color', [0.2, 0.2, 0.2], 'Interpreter', 'latex');
        
        % 白色主字体（稍微细一点）
        text(node_positions(i,1), node_positions(i,2), z + 0.06, sprintf('%d', i), ...
            'FontSize', 17, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'Color', [1.0, 1.0, 1.0], 'Interpreter', 'latex');
    end
    
    %% 添加透明层标签（无边框，右侧注释层数）
    % 主标签（透明背景，无边框）
    text(-5.5, 3.5, z, layer_names{layer}, ...
        'FontSize', 16, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left', 'Color', [0.2, 0.2, 0.2], ...
        'BackgroundColor', 'none', 'EdgeColor', 'none', ...
        'Interpreter', 'latex');
end

%% 绘制层间连接（渐变虚线效果）
for layer = 1:2
    z1 = z_layers(layer);
    z2 = z_layers(layer + 1);
    
    % 节点间的垂直连接（双虚线效果）
    for i = 1:6
        % 粗虚线
        plot3([node_positions(i,1), node_positions(i,1)], ...
              [node_positions(i,2), node_positions(i,2)], ...
              [z1, z2], ':', 'Color', [0.7, 0.7, 0.7], 'LineWidth', 2.5);
        
        % 细虚线叠加
        plot3([node_positions(i,1), node_positions(i,1)], ...
              [node_positions(i,2), node_positions(i,2)], ...
              [z1, z2], ':', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);
    end
end

%% 设置3D图形属性
axis equal;
grid on;
grid minor;

% 设置坐标轴
xlabel('$X$ ', 'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'latex');
ylabel('$Y$ ', 'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'latex');
zlabel('$Z$', 'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'latex');

% 设置坐标轴范围（调整以适应更大的椭圆）
xlim([-7, 7]);
ylim([-6, 6]);
zlim([-1, 10]);

% 手动设置Z轴刻度标注，使其显示为1,2,3对应实际的层位置
set(gca, 'ZTick', z_layers);  % 设置刻度位置为实际的z_layers位置 [0, 4, 8]
set(gca, 'ZTickLabel', {'1', '2', '3'});  % 设置刻度标签为1,2,3

% 设置观察视角
view(20, 25);

%% 添加光照效果
lighting gouraud;
light('Position', [1, 1, 1], 'Style', 'local');
light('Position', [-1, -1, 1], 'Style', 'local');

%% 优化显示效果
set(gca, 'Color', [0.98, 0.98, 1.0]);
set(gca, 'GridColor', [0.7, 0.7, 0.7]);
set(gca, 'GridAlpha', 0.3);
set(gca, 'MinorGridColor', [0.8, 0.8, 0.8]);
set(gca, 'MinorGridAlpha', 0.2);

%% 添加简化图例（只显示层内连接）
legend_handles = [];
legend_labels = {};

% 节点图例
for layer = 1:3
    h = plot3(NaN, NaN, NaN, 'o', 'MarkerSize', 12, ...
        'MarkerFaceColor', node_colors(layer,:), ...
        'MarkerEdgeColor', [0.2, 0.2, 0.2], 'LineWidth', 2);
    legend_handles = [legend_handles, h];
    legend_labels{end+1} = sprintf('Layer %d Nodes', layer);
end

% 层内连接图例（红色）
h_intra = plot3(NaN, NaN, NaN, '-', 'Color', [0.8, 0.2, 0.2], 'LineWidth', 2);
legend_handles = [legend_handles, h_intra];
legend_labels{end+1} = 'Intra-layer Connections';

% 层间连接图例
h_interlayer = plot3(NaN, NaN, NaN, ':', 'Color', [0.7, 0.7, 0.7], 'LineWidth', 2);
legend_handles = [legend_handles, h_interlayer];
legend_labels{end+1} = 'Inter-layer Connections';

% 显示图例
legend(legend_handles, legend_labels, 'Location', 'eastoutside', ...
    'FontSize', 11, 'Box', 'on', 'Interpreter', 'latex');

hold off;