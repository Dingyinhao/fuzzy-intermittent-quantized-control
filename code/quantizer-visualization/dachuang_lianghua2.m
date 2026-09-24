% 对数量化器可视化代码 - 多参数版本
% 基于论文中的量化器定义实现多种参数配置

clear; clc; close all;

% 定义多种参数配置
configs = {
    struct('v', 0.5, 'iota_max', 4, 'xlim_val', 0.8, 'ylim_val', 0.6, 'title_suffix', 'Configuration 1: v=0.5'),
    struct('v', 0.6, 'iota_max', 3, 'xlim_val', 0.6, 'ylim_val', 0.5, 'title_suffix', 'Configuration 2: v=0.6'),
    struct('v', 0.4, 'iota_max', 5, 'xlim_val', 1.0, 'ylim_val', 0.8, 'title_suffix', 'Configuration 3: v=0.4'),
    struct('v', 0.7, 'iota_max', 3, 'xlim_val', 0.5, 'ylim_val', 0.4, 'title_suffix', 'Configuration 4: v=0.7')
};

% 为每种配置创建图形
for config_idx = 1:length(configs)
    config = configs{config_idx};
    
    % 参数设置
    v = config.v;                    % 量化密度
    chi = (1-v)/(1+v);              % 量化步长 χ = (1-v)/(1+v)
    varsigma_0 = 0.5;               % 基础量化级别 ς₀
    
    % 生成量化级别集合 ξ = {±ς*ι : ς*ι = v^ι ς₀, ι = 0, ±1, ±2, ...} ∪ {0}
    iota_max = config.iota_max;
    iota_values = -iota_max:iota_max;
    quantization_levels = [];
    iota_indices = [];
    
    for i = 1:length(iota_values)
        if iota_values(i) ~= 0
            % ς*ι = v^|ι| ς₀ for ι ≠ 0
            varsigma_iota = (v^abs(iota_values(i))) * varsigma_0 * sign(iota_values(i));
            quantization_levels = [quantization_levels, varsigma_iota];
            iota_indices = [iota_indices, iota_values(i)];
        end
    end
    quantization_levels = [quantization_levels, 0]; % 添加零点
    iota_indices = [iota_indices, 0];
    
    % 对量化级别和索引同时排序
    [quantization_levels, sort_idx] = sort(quantization_levels);
    iota_indices = iota_indices(sort_idx);
    
    % 创建图形
    figure('Position', [100 + (config_idx-1)*200, 100, 900, 700]);
    set(gcf, 'Color', 'white');
    hold on; grid on;
    
    % 设置网格样式
    set(gca, 'GridLineStyle', '-', 'GridAlpha', 0.3, 'GridColor', [0.5, 0.5, 0.5]);
    
    % 绘制量化级别的水平线段
    for i = 1:length(quantization_levels)
        varsigma_iota = quantization_levels(i);
        idx = iota_indices(i);
        
        if varsigma_iota ~= 0
            % 量化区间：(ς*ι/(1+χ), ς*ι/(1-χ)] for ς*ι > 0
            % 量化区间：[ς*ι/(1-χ), ς*ι/(1+χ)) for ς*ι < 0
            if varsigma_iota > 0
                lower = varsigma_iota / (1 + chi);
                upper = varsigma_iota / (1 - chi);
            else
                lower = varsigma_iota / (1 - chi);
                upper = varsigma_iota / (1 + chi);
            end
            
            % 只绘制在显示范围内的线段
            xlim_range = [-config.xlim_val, config.xlim_val];
            if upper >= xlim_range(1) && lower <= xlim_range(2)
                plot_lower = max(lower, xlim_range(1));
                plot_upper = min(upper, xlim_range(2));
                
                % 绘制水平线段
                plot([plot_lower, plot_upper], [varsigma_iota, varsigma_iota], 'b-', 'LineWidth', 1.8);
                
                % 绘制端点
                if lower >= xlim_range(1)
                    if varsigma_iota > 0
                        plot(lower, varsigma_iota, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'white', ...
                             'MarkerEdgeColor', 'b', 'LineWidth', 1.2);
                    else
                        plot(lower, varsigma_iota, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'b', ...
                             'LineWidth', 1.2);
                    end
                end
                if upper <= xlim_range(2)
                    if varsigma_iota > 0
                        plot(upper, varsigma_iota, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'b', ...
                             'LineWidth', 1.2);
                    else
                        plot(upper, varsigma_iota, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'white', ...
                             'MarkerEdgeColor', 'b', 'LineWidth', 1.2);
                    end
                end
                
                % 添加量化级别注释 ς*ι
                mid_point = (plot_lower + plot_upper) / 2;
                if idx > 0
                    text(mid_point, varsigma_iota + 0.02, sprintf('ς_{%d}', idx), 'FontName', 'Times New Roman', ...
                         'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                         'VerticalAlignment', 'bottom', 'Color', [0, 0, 0.8]);
                elseif idx < 0
                    text(mid_point, varsigma_iota - 0.02, sprintf('ς_{%d}', idx), 'FontName', 'Times New Roman', ...
                         'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                         'VerticalAlignment', 'top', 'Color', [0, 0, 0.8]);
                end
            end
        else
            % 绘制零点
            plot(0, 0, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'b', 'LineWidth', 1.2);
            text(0.02, 0.01, 'ς_0', 'FontName', 'Times New Roman', 'FontSize', 10, ...
                 'FontWeight', 'bold', 'Color', [0, 0, 0.8]);
        end
    end
    
    % 绘制边界线 - Filippov解的边界
    v_line = linspace(-config.xlim_val, config.xlim_val, 100);
    % σ = χ 时：q̃(ψ) = (1+χ)ψ
    p1_line = (1 + chi) * v_line;
    % σ = -χ 时：q̃(ψ) = (1-χ)ψ  
    p2_line = (1 - chi) * v_line;
    
    plot(v_line, p1_line, '--', 'LineWidth', 1.5, 'Color', [0.8, 0.3, 0.8]);
    plot(v_line, p2_line, '--', 'LineWidth', 1.5, 'Color', [0.8, 0.3, 0.8]);
    
    % 添加边界线标签
    text_pos = config.xlim_val * 0.6;
    text(text_pos, (1+chi)*text_pos+0.02, 'q̃(ψ)=(1+χ)ψ', 'FontName', 'Times New Roman', ...
         'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.8, 0.3, 0.8]);
    text(text_pos, (1-chi)*text_pos-0.03, 'q̃(ψ)=(1-χ)ψ', 'FontName', 'Times New Roman', ...
         'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.8, 0.3, 0.8]);
    
    % 设置坐标轴
    xlim([-config.xlim_val, config.xlim_val]);
    ylim([-config.ylim_val, config.ylim_val]);
    xlabel('Input ψ', 'FontName', 'Times New Roman', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Quantizer Output q̃(ψ)', 'FontName', 'Times New Roman', 'FontSize', 14, 'FontWeight', 'bold');
    
    % 设置坐标轴刻度
    xtick_step = config.xlim_val / 4;
    ytick_step = config.ylim_val / 3;
    xticks(-config.xlim_val:xtick_step:config.xlim_val);
    yticks(-config.ylim_val:ytick_step:config.ylim_val);
    
    % 设置坐标轴样式
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    ax.FontName = 'Times New Roman';
    ax.FontSize = 12;
    ax.FontWeight = 'bold';
    ax.LineWidth = 1.2;
    ax.TickLength = [0.02, 0.02];
    
    % 设置图形框
    box on;
    set(gca, 'Layer', 'top');
    
    % 参数信息框
    param_text = {
        sprintf('\\bf\\fontname{Times New Roman}Quantizer Parameters:');
        sprintf('\\bf\\fontname{Times New Roman}ρ = %.3f', v);
        sprintf('\\bf\\fontname{Times New Roman}χ = %.3f', chi);
        sprintf('\\bf\\fontname{Times New Roman}ς_0 = %.1f', varsigma_0);
        sprintf('\\bf\\fontname{Times New Roman}Levels: %d', length(quantization_levels));
        sprintf('\\bf\\fontname{Times New Roman}σ ∈ [-χ, χ)');
    };
    
    % 创建参数框
    annotation('textbox', [0.02, 0.70, 0.30, 0.25], 'String', param_text, ...
               'FontSize', 9, 'FontWeight', 'bold', 'FontName', 'Times New Roman', ...
               'BackgroundColor', [0.95, 0.95, 0.95], 'EdgeColor', [0.3, 0.3, 0.3], ...
               'LineWidth', 1, 'FitBoxToText', 'on');
    
    % 添加标题
    title(['Logarithmic Quantizer: ', config.title_suffix], 'FontName', 'Times New Roman', ...
          'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
    
    hold off;
    
    % 设置图形属性以符合学术标准
    set(gcf, 'PaperPositionMode', 'auto');
    set(gcf, 'Renderer', 'painters');
    
    % 打印当前配置的量化级别信息
    fprintf('\n=== Configuration %d: v = %.3f ===\n', config_idx, v);
    fprintf('χ = (1-v)/(1+v) = %.4f\n', chi);
    fprintf('Quantization levels ξ = {±ς*ι : ς*ι = v^ι ς₀} ∪ {0}:\n');
    for i = 1:length(quantization_levels)
        varsigma_iota = quantization_levels(i);
        idx = iota_indices(i);
        if varsigma_iota == 0
            fprintf('  ι=%d: ς_%d = %.4f (zero level)\n', idx, idx, varsigma_iota);
        else
            fprintf('  ι=%d: ς_%d = %.4f = v^%d × ς₀\n', idx, idx, varsigma_iota, abs(idx));
        end
    end
    fprintf('Filippov solution: q̃(ψ) = (1+σ)ψ, σ ∈ [-χ, χ)\n');
end

fprintf('\n=== All configurations generated ===\n');
fprintf('Choose the configuration that best shows the intersection\n');
fprintf('between horizontal quantization levels and boundary lines.\n');