function multilayer_fuzzy_network_preassigned_time_no_attack()
% Based on extended adjacency matrix three-layer T-S fuzzy multilayer network preassigned-time sync simulation (no attack)
% Layer 1: Liu system, Layer 2: Lorenz system, Layer 3: Rossler system
% Using extended adjacency matrix \breve{\mathcal{A}}^{(k)} and new state iteration formula
close all; clear; clc;
% === Ensure complete reproducibility ===
rng(42, 'twister'); % Fix all random number generators
rand('state', 42);
randn('state', 42);
%% ==================== Intermittent Control Time Setup ====================
n = 480; % Time discretization parameter
h = 1/n; % Time step = 0.025
% Design (8,2) minute intermittent control: ensure all time points*n are integers
total_simulation_time = 8; % Total simulation time
cycle_length = 0.25; % Each intermittent control cycle 0.25 seconds
active_time = 0.2; % Active time 0.2 seconds
inactive_time = 0.05; % Inactive time 0.05 seconds
N_periods = floor(total_simulation_time / cycle_length);
% Construct C and R arrays ensuring integer indices
C = zeros(1, N_periods);
R = zeros(1, N_periods+1);
R(1) = 0;
for k = 1:N_periods
cycle_start = (k-1) * cycle_length;
C(k) = cycle_start + active_time;
R(k+1) = k * cycle_length;
end
N_periods = length(C); % Number of intermittent control cycles
fprintf('=== Based on Extended Adjacency Matrix Three-Layer T-S Fuzzy Network Preassigned-Time Sync Simulation (No Attack) ===\n');
fprintf('Number of intermittent control cycles: %d\n', N_periods);
fprintf('Time step: %.4f\n', h);
%% ==================== Network Parameters ====================
M = 3; % Number of layers
N_original = 6; % Number of original nodes per layer
N_virtual = 7; % Total number including virtual nodes (N_original + 1)
n_dim = 3; % Dimension of each node
r = 2; % Number of fuzzy rules
total_nodes = M * N_original;
fprintf('Network parameters: M=%d layers, %d actual nodes+1 virtual node per layer, %d dimensions per node, %d fuzzy rules\n', ...
M, N_original, n_dim, r);
%% ==================== Fuzzy Membership Functions (Simplified according to Code 2) ====================
% Define simple fuzzy functions according to Code 2 approach
R1 = @(x) 0.2 + 0.2 * sin(x).^2; % Simplified fuzzy function 1
R2 = @(x) 0.6 + 0.2 * cos(x).^2; % Simplified fuzzy function 2
sign = @(x) (abs(x+0.1)-abs(x-0.1))/1.2;
%% ==================== Controller Parameters (No Attack Case) ====================
% Control for each fuzzy rule (alpha_theta, beta_theta, gamma_theta in paper)
alpha_theta = [5.5, 5.6]; % Basic control alpha_theta
beta_theta = [2, 2.1]; % Sign function beta_theta
gamma_theta = [5.7, 5.8]; % Power term gamma_theta
delta = 1.2; % Power exponent delta > 1 for fixed-time
alpha = min(alpha_theta); % alpha = min{alpha_theta}
beta = min(beta_theta); % beta = min{beta_theta}
gamma = min(gamma_theta); % gamma = min{gamma_theta}
% Coupling coefficients (each fuzzy rule)
c_theta = [0.3, 0.25]; % Intra-layer coupling strength c_theta
d_theta = [0.3, 0.25]; % Inter-layer coupling strength d_theta
d = min(d_theta);
c = min(c_theta);
sjxs = 0.7; % Stochastic term coefficient
%% ==================== Quantization Parameters ====================
rho = 0.7; % Quantization density rho
chi = (1-rho)/(1+rho); % Quantization parameter chi
Lambda = 0.8; % Intermittent control parameter
fprintf('=== Controller Parameter Verification (No Attack) ===\n');
fprintf('Control gains: alpha_min=%.2f, beta_min=%.2f, gamma_min=%.2f\n', alpha, beta, gamma);
fprintf('Quantization parameters: rho=%.2f, chi=%.4f\n', rho, chi);
%% ==================== Preassigned-Time Parameters Setup ====================
% Known theoretical fixed-time convergence time from Code 1
T_max_theory = 2.3429; % Fixed-time theoretical convergence time (from Code 1)
T_p = 1.2; % Preassigned convergence time (less than theoretical fixed-time)
time_ratio = T_max_theory / T_p; % Preassigned-time synchronization coefficient
fprintf('\n=== Preassigned-Time Synchronization Parameters ===\n');
fprintf('Fixed-time theoretical convergence time T_max = %.4f seconds\n', T_max_theory);
fprintf('Preassigned convergence time T_p = %.4f seconds\n', T_p);
fprintf('Time ratio coefficient T_max/T_p = %.4f\n', time_ratio);
%% ==================== Construct Extended Adjacency Matrix ====================
fprintf('\n=== Construct Extended Adjacency Matrix ===\n');
% Adjusted Laplace matrix L_A1
L_A1_original = [3 -0.6 -0.6 -0.6 -0.6 -0.6;
-0.6 1.2 -0.6 0 0 0;
-0.6 -0.6 1.8 -0.6 0 0;
-0.6 0 -0.6 1.2 0 0;
-0.6 0 0 0 1.2 -0.6;
-0.6 0 0 0 -0.6 1.2];
% Adjusted Laplace matrix L_A2
L_A2_original = [0.4 0 -0.2 -0.2 0 0;
0 0.45 -0.15 0 -0.1 -0.2;
-0.2 -0.15 0.5 0 -0.15 0;
-0.2 0 0 0.35 -0.05 -0.1;
0 -0.1 -0.15 -0.05 0.3 0;
0 -0.2 0 -0.1 0 0.3];
% Adjusted Laplace matrix L_A3
L_A3_original= [2.5 -0.5 -0.5 -0.5 -0.5 0;
-0.5 2 -0.5 0 -0.5 -0.5;
-0.5 -0.5 2 -0.5 0 -0.5;
-0.5 0 -0.5 2 -0.5 -0.5;
-0.5 -0.5 0 -0.5 2 -0.5;
0 -0.5 -0.5 -0.5 -0.5 2.5];
L_A4 = blkdiag(L_A1_original, L_A2_original, L_A3_original);
% Convert from Laplacian matrix to adjacency matrix
G_A1_original = -L_A1_original;
G_A2_original = -L_A2_original;
G_A3_original = -L_A3_original;
% Set diagonal elements to 0 (adjacency matrix property)
for i = 1:N_original
G_A1_original(i,i) = 0;
G_A2_original(i,i) = 0;
G_A3_original(i,i) = 0;
end
% Virtual node connection weight vector \breve{c}_j^{(k)}
c_tilde_1 = zeros(N_original, 1);
c_tilde_2 = zeros(N_original, 1);
c_tilde_3 = zeros(N_original, 1);
% Construct extended Laplacian matrix
C1_matrix = diag(c_tilde_1);
C2_matrix = diag(c_tilde_2);
C3_matrix = diag(c_tilde_3);
C4 = blkdiag(C1_matrix, C2_matrix, C3_matrix);
% Construct extended adjacency matrix
A_breve_1 = zeros(N_virtual, N_virtual);
A_breve_1(1:N_original, 1:N_original) = G_A1_original;
A_breve_1(1:N_original, N_virtual) = c_tilde_1;
A_breve_1(N_virtual, :) = 0;
A_breve_2 = zeros(N_virtual, N_virtual);
A_breve_2(1:N_original, 1:N_original) = G_A2_original;
A_breve_2(1:N_original, N_virtual) = c_tilde_2;
A_breve_2(N_virtual, :) = 0;
A_breve_3 = zeros(N_virtual, N_virtual);
A_breve_3(1:N_original, 1:N_original) = G_A3_original;
A_breve_3(1:N_original, N_virtual) = c_tilde_3;
A_breve_3(N_virtual, :) = 0;
fprintf('Extended adjacency matrix dimension: %dx%d\n', size(A_breve_1));
%% ==================== Inter-layer Coupling Matrix H ====================
H = [-2 1 1;
1 -2 1;
1 1 -2];
L_B = -H;
% Coupling matrices
E = eye(n_dim); % Intra-layer coupling matrix
F = eye(n_dim); % Inter-layer coupling matrix
%% ==================== System Dynamics Functions ====================
function f = get_system_dynamics(layer, s)
if layer == 1 % Liu system
f = 0.01*[12*s(2) - 10*s(1);
20*s(1) - 2.5*s(1) - s(1)*s(3);
4*s(1)*s(1) - 3*s(3)];
elseif layer == 2 % Lorenz system
f = 0.01*[10*(s(2) - s(1));
28*s(1) - s(2) - s(1)*s(3);
s(1)*s(2) - (8/3)*s(3)];
else % layer == 3, Rossler system
f = 0.01*[-(s(2) + s(3));
s(1) + 0.2*s(2);
s(1)*s(3) - 18*s(3) + 0.2];
end
end
%% ==================== State Variable Initialization ====================
total_time_steps = R(N_periods+1)*n;
% System states (including virtual nodes)
X = zeros(3*N_virtual, total_time_steps+1); % Layer 1
Y = zeros(3*N_virtual, total_time_steps+1); % Layer 2
Z = zeros(3*N_virtual, total_time_steps+1); % Layer 3
% Control input related variables (no attack)
u1 = zeros(3*N_original, total_time_steps+1); % Layer 1 control input
u2 = zeros(3*N_original, total_time_steps+1); % Layer 2 control input
u3 = zeros(3*N_original, total_time_steps+1); % Layer 3 control input
% Synchronization states
s1 = zeros(3, total_time_steps+1); % Layer 1 sync state
s2 = zeros(3, total_time_steps+1); % Layer 2 sync state
s3 = zeros(3, total_time_steps+1); % Layer 3 sync state
% Synchronization errors and quantizer
e1 = zeros(3*N_original, total_time_steps+1);
quantizer1 = zeros(3*N_original, total_time_steps+1);
e2 = zeros(3*N_original, total_time_steps+1);
quantizer2 = zeros(3*N_original, total_time_steps+1);
e3 = zeros(3*N_original, total_time_steps+1);
quantizer3 = zeros(3*N_original, total_time_steps+1);
%% Wiener process initialization
randn('state', 300);
dWiener = zeros(1, total_time_steps+1);
Wiener = zeros(1, total_time_steps+1);
for g = 1:total_time_steps
dWiener(g+1) = sqrt(h)*randn;
Wiener(g+1) = Wiener(g) + dWiener(g+1);
end
%% ==================== Initial Conditions Setup ====================
% Synchronization state initial conditions
s1(:,1) = [2.2,-2.3,0.2];
s2(:,1) = [2.2,-2.2,0.1];
s3(:,1) = [2.2,-2.3,-0.2];
% Node state initialization
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
% Virtual node initial state set to synchronization state
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
%% ==================== Main Simulation Loop ====================
fprintf('Starting extended adjacency matrix based no-attack preassigned-time sync simulation loop...\n');
for k = 1:N_periods
%% ===== Control Active Phase =====
fprintf('Cycle %d/%d: Control active phase [%.2f, %.2f]\n', k, N_periods, R(k), C(k));
for j = R(k)*n+1:C(k)*n
%% Update synchronization states (according to Code 2 simplified approach)
% Layer 1 synchronization state
s1_curr = [s1(1,j); s1(2,j); s1(3,j)];
f_s1 = get_system_dynamics(1, s1_curr);
% Inter-layer coupling calculation
inter_layer_coupling_1 = zeros(3,1);
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
% Layer 2 synchronization state
s2_curr = [s2(1,j); s2(2,j); s2(3,j)];
f_s2 = get_system_dynamics(2, s2_curr);
inter_layer_coupling_2 = zeros(3,1);
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
% Layer 3 synchronization state
s3_curr = [s3(1,j); s3(2,j); s3(3,j)];
f_s3 = get_system_dynamics(3, s3_curr);
inter_layer_coupling_3 = zeros(3,1);
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
%% Update virtual node states
X(3*(virtual_idx-1)+1, j+1) = s1(1, j+1);
X(3*(virtual_idx-1)+2, j+1) = s1(2, j+1);
X(3*(virtual_idx-1)+3, j+1) = s1(3, j+1);
Y(3*(virtual_idx-1)+1, j+1) = s2(1, j+1);
Y(3*(virtual_idx-1)+2, j+1) = s2(2, j+1);
Y(3*(virtual_idx-1)+3, j+1) = s2(3, j+1);
Z(3*(virtual_idx-1)+1, j+1) = s3(1, j+1);
Z(3*(virtual_idx-1)+2, j+1) = s3(2, j+1);
Z(3*(virtual_idx-1)+3, j+1) = s3(3, j+1);
%% Process actual nodes according to extended adjacency matrix
for I = 1:N_original
%% Calculate synchronization errors
e1(3*(I-1)+1, j) = X(3*(I-1)+1, j) - s1(1, j);
e1(3*(I-1)+2, j) = X(3*(I-1)+2, j) - s1(2, j);
e1(3*(I-1)+3, j) = X(3*(I-1)+3, j) - s1(3, j);
e2(3*(I-1)+1, j) = Y(3*(I-1)+1, j) - s2(1, j);
e2(3*(I-1)+2, j) = Y(3*(I-1)+2, j) - s2(2, j);
e2(3*(I-1)+3, j) = Y(3*(I-1)+3, j) - s2(3, j);
e3(3*(I-1)+1, j) = Z(3*(I-1)+1, j) - s3(1, j);
e3(3*(I-1)+2, j) = Z(3*(I-1)+2, j) - s3(2, j);
e3(3*(I-1)+3, j) = Z(3*(I-1)+3, j) - s3(3, j);
%% Quantize synchronization errors
% Layer 1 quantization
for n_neuron = 1:3
error_val = e1(3*(I-1)+n_neuron, j);
quantizer1(3*(I-1)+n_neuron, j) = quantizer(error_val);
% Layer 2 quantization
error_val = e2(3*(I-1)+n_neuron, j);
quantizer2(3*(I-1)+n_neuron, j) = quantizer(error_val);
% Layer 3 quantization
error_val = e3(3*(I-1)+n_neuron, j);
quantizer3(3*(I-1)+n_neuron, j) = quantizer(error_val);
end
%% Preassigned-time no-attack controller design (according to Corollary 2)
% Layer 1 controller (add time ratio coefficient)
for n_neuron = 1:3
q_val = quantizer1(3*(I-1)+n_neuron, j);
% Preassigned-time controller: add time ratio coefficient before beta and gamma terms
u1_val1 = -alpha_theta(1)*q_val - time_ratio*beta_theta(1)*sign(q_val) - time_ratio*gamma_theta(1)*sign(q_val)*abs(q_val)^delta;
u1_val2 = -alpha_theta(2)*q_val - time_ratio*beta_theta(2)*sign(q_val) - time_ratio*gamma_theta(2)*sign(q_val)*abs(q_val)^delta;
% Apply fuzzy weights
u1_current = R1(X(3*(I-1)+n_neuron, j))*u1_val1 + R2(X(3*(I-1)+n_neuron, j))*u1_val2;
u1(3*(I-1)+n_neuron, j) = u1_current;
% Layer 2 controller
q_val = quantizer2(3*(I-1)+n_neuron, j);
u2_val1 = -alpha_theta(1)*q_val - time_ratio*beta_theta(1)*sign(q_val) - time_ratio*gamma_theta(1)*sign(q_val)*abs(q_val)^delta;
u2_val2 = -alpha_theta(2)*q_val - time_ratio*beta_theta(2)*sign(q_val) - time_ratio*gamma_theta(2)*sign(q_val)*abs(q_val)^delta;
u2_current = R1(Y(3*(I-1)+n_neuron, j))*u2_val1 + R2(Y(3*(I-1)+n_neuron, j))*u2_val2;
u2(3*(I-1)+n_neuron, j) = u2_current;
% Layer 3 controller
q_val = quantizer3(3*(I-1)+n_neuron, j);
u3_val1 = -alpha_theta(1)*q_val - time_ratio*beta_theta(1)*sign(q_val) - time_ratio*gamma_theta(1)*sign(q_val)*abs(q_val)^delta;
u3_val2 = -alpha_theta(2)*q_val - time_ratio*beta_theta(2)*sign(q_val) - time_ratio*gamma_theta(2)*sign(q_val)*abs(q_val)^delta;
u3_current = R1(Z(3*(I-1)+n_neuron, j))*u3_val1 + R2(Z(3*(I-1)+n_neuron, j))*u3_val2;
u3(3*(I-1)+n_neuron, j) = u3_current;
end
%% Use extended adjacency matrix to update system states
% Layer 1 state update
x_curr = [X(3*(I-1)+1, j); X(3*(I-1)+2, j); X(3*(I-1)+3, j)];
f_x = get_system_dynamics(1, x_curr);
% Use extended adjacency matrix to calculate intra-layer coupling
intra_coupling_1 = zeros(3, 1);
for J = 1:N_virtual
if J ~= I % j != i
coupling_weight = A_breve_1(I, J);
if coupling_weight ~= 0
if J <= N_original % Normal node
x_diff = [X(3*(J-1)+1, j) - X(3*(I-1)+1, j);
X(3*(J-1)+2, j) - X(3*(I-1)+2, j);
X(3*(J-1)+3, j) - X(3*(I-1)+3, j)];
else % Virtual node
x_diff = [X(3*(J-1)+1, j) - X(3*(I-1)+1, j);
X(3*(J-1)+2, j) - X(3*(I-1)+2, j);
X(3*(J-1)+3, j) - X(3*(I-1)+3, j)];
end
coupled_diff = E * x_diff;
intra_coupling_1 = intra_coupling_1 + coupling_weight * coupled_diff;
end
end
end
% Inter-layer coupling
inter_coupling_1 = zeros(3, 1);
for l = 1:M
if l ~= 1
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
% State update
for dim = 1:3
X(3*(I-1)+dim, j+1) = X(3*(I-1)+dim, j) + h * (f_x(dim) + ...
R1(X(3*(I-1)+dim, j)) * (c_theta(1) * intra_coupling_1(dim) + d_theta(1) * inter_coupling_1(dim) + u1(3*(I-1)+dim, j)) + ...
R2(X(3*(I-1)+dim, j)) * (c_theta(2) * intra_coupling_1(dim) + d_theta(2) * inter_coupling_1(dim) + u1(3*(I-1)+dim, j))) + ...
sjxs * X(3*(I-1)+dim, j) * (Wiener(j+1) - Wiener(j));
end
% Layer 2 state update
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
% Layer 3 state update
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
end % End node loop
end % End control active phase time loop
%% ===== Control Inactive Phase =====
if k < N_periods
fprintf('Cycle %d/%d: Control inactive phase [%.2f, %.2f]\n', k, N_periods, C(k), R(k+1));
for j = C(k)*n+1:R(k+1)*n
%% Update synchronization states
% Layer 1 synchronization state
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
% Layer 2 synchronization state
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
% Layer 3 synchronization state
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
%% Update virtual node states
X(3*(virtual_idx-1)+1, j+1) = s1(1, j+1);
X(3*(virtual_idx-1)+2, j+1) = s1(2, j+1);
X(3*(virtual_idx-1)+3, j+1) = s1(3, j+1);
Y(3*(virtual_idx-1)+1, j+1) = s2(1, j+1);
Y(3*(virtual_idx-1)+2, j+1) = s2(2, j+1);
Y(3*(virtual_idx-1)+3, j+1) = s2(3, j+1);
Z(3*(virtual_idx-1)+1, j+1) = s3(1, j+1);
Z(3*(virtual_idx-1)+2, j+1) = s3(2, j+1);
Z(3*(virtual_idx-1)+3, j+1) = s3(3, j+1);
%% Process actual nodes (no control input period)
for I = 1:N_original
% Set controller to zero (inactive phase)
u1(3*(I-1)+1:3*(I-1)+3, j) = 0;
u2(3*(I-1)+1:3*(I-1)+3, j) = 0;
u3(3*(I-1)+1:3*(I-1)+3, j) = 0;
%% Use extended adjacency matrix to update system states (no control input)
% Layer 1 state update
x_curr = [X(3*(I-1)+1, j); X(3*(I-1)+2, j); X(3*(I-1)+3, j)];
f_x = get_system_dynamics(1, x_curr);
% Intra-layer coupling
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
% Inter-layer coupling
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
% Layer 2 state update
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
% Layer 3 state update
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
%% ==================== Calculate Synchronization Errors for Analysis ====================
% Calculate synchronization errors for all time instants
for j = 1:total_time_steps+1
for I = 1:N_original
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
% Quantization errors
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
%% ==================== Results Analysis and Visualization ====================
T_p_rounded = round(T_p, 4);
t = linspace(0, R(N_periods+1), total_time_steps+1);
% Calculate final synchronization errors
final_e1_norm = norm(e1(:,end));
final_e2_norm = norm(e2(:,end));
final_e3_norm = norm(e3(:,end));
fprintf('\n=== Preassigned-Time Synchronization Simulation Results (No Attack) ===\n');
fprintf('Final synchronization error norms:\n');
fprintf('Layer 1 (Liu): %.6f\n', final_e1_norm);
fprintf('Layer 2 (Lorenz): %.6f\n', final_e2_norm);
fprintf('Layer 3 (Rossler): %.6f\n', final_e3_norm);
%% ==================== Figure Drawing ====================
%% Layer 1 Control Input Signal
figure(1);
hold on;
h1 = plot(t, u1(1,:), 'r-', 'LineWidth', 0.4);
h2 = plot(t, u1(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, u1(3,:), 'b-', 'LineWidth', 0.4);
for q = 2:N_original
plot(t, u1(3*(q-1)+1,:), 'r-', 'LineWidth', 0.4);
plot(t, u1(3*(q-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, u1(3*(q-1)+3,:), 'b-', 'LineWidth', 0.4);
end
% Add preassigned-time marker
p = plot(T_p, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$U^{(1)}_{i1}(t)$', '$U^{(1)}_{i2}(t)$', '$U^{(1)}_{i3}(t)$', sprintf('$\\hat{\\mathcal{T}}^2_p=%.1f$', T_p_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
xlabel('$t$', 'Interpreter', 'latex');
ylabel('$U^{(1)}_i(t),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;
xlim([0, 2]);
box on;
% Add magnification window
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.4);
initial_data = u1(:, idx_range);
plot(t(idx_range), u1(1,idx_range), 'r-', 'LineWidth', 0.7);
hold on;
plot(t(idx_range), u1(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t(idx_range), u1(3,idx_range), 'b-', 'LineWidth', 0.7);
for q = 2:N_original
plot(t(idx_range), u1(3*(q-1)+1,idx_range), 'r-', 'LineWidth', 0.7);
plot(t(idx_range), u1(3*(q-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t(idx_range), u1(3*(q-1)+3,idx_range), 'b-', 'LineWidth', 0.7);
end
xlim([0, 0.4]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex');
hold off;
%% Layer 2 Control Input Signal
figure(2);
hold on;
h1 = plot(t, u2(1,:), 'r-', 'LineWidth', 0.4);
h2 = plot(t, u2(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, u2(3,:), 'b-', 'LineWidth', 0.4);
for q = 2:N_original
plot(t, u2(3*(q-1)+1,:), 'r-', 'LineWidth', 0.4);
plot(t, u2(3*(q-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, u2(3*(q-1)+3,:), 'b-', 'LineWidth', 0.4);
end
p = plot(T_p, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$U^{(2)}_{i1}(t)$', '$U^{(2)}_{i2}(t)$', '$U^{(2)}_{i3}(t)$', sprintf('$\\hat{\\mathcal{T}}^2_p=%.1f$', T_p_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
xlabel('$t$', 'Interpreter', 'latex');
ylabel('$U^{(2)}_i(t),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;
xlim([0, 2]);box on;
% Add magnification window
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.4);
initial_data = u2(:, idx_range);
plot(t(idx_range), u2(1,idx_range), 'r-', 'LineWidth', 0.7);
hold on;
plot(t(idx_range), u2(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t(idx_range), u2(3,idx_range), 'b-', 'LineWidth', 0.7);
for q = 2:N_original
plot(t(idx_range), u2(3*(q-1)+1,idx_range), 'r-', 'LineWidth', 0.7);
plot(t(idx_range), u2(3*(q-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t(idx_range), u2(3*(q-1)+3,idx_range), 'b-', 'LineWidth', 0.7);
end
xlim([0, 0.4]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex');
hold off;
%% Layer 3 Control Input Signal
figure(3);
hold on;
h1 = plot(t, u3(1,:), 'r-', 'LineWidth', 0.4);
h2 = plot(t, u3(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
h3 = plot(t, u3(3,:), 'b-', 'LineWidth', 0.4);
for q = 2:N_original
plot(t, u3(3*(q-1)+1,:), 'r-', 'LineWidth', 0.4);
plot(t, u3(3*(q-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.4);
plot(t, u3(3*(q-1)+3,:), 'b-', 'LineWidth', 0.4);
end
p = plot(T_p, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 8);
legend_entries = {'$U^{(3)}_{i1}(t)$', '$U^{(3)}_{i2}(t)$', '$U^{(3)}_{i3}(t)$', sprintf('$\\hat{\\mathcal{T}}^2_p=%.1f$', T_p_rounded)};
legend([h1, h2, h3, p], legend_entries, 'Location', 'northeast', 'Interpreter', 'latex');
xlabel('$t$', 'Interpreter', 'latex');
ylabel('$U^{(3)}_i(t),i=1,2,...,6$', 'Interpreter', 'latex');
grid on;
xlim([0, 2]);box on;
% Add magnification window
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.3);
initial_data = u3(:, idx_range);
plot(t(idx_range), u3(1,idx_range), 'r-', 'LineWidth', 0.7);
hold on;
plot(t(idx_range), u3(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t(idx_range), u3(3,idx_range), 'b-', 'LineWidth', 0.7);
for q = 2:N_original
plot(t(idx_range), u3(3*(q-1)+1,idx_range), 'r-', 'LineWidth', 0.7);
plot(t(idx_range), u3(3*(q-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t(idx_range), u3(3*(q-1)+3,idx_range), 'b-', 'LineWidth', 0.7);
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
p = plot(T_p, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 6);
legend([h1, h2, h3, p], {'$q(e^{(1)}_{i1}(t))$', '$q(e^{(1)}_{i2}(t))$', '$q(e^{(1)}_{i3}(t))$', sprintf('$\\hat{\\mathcal{T}}^2_p=%.1f$', T_p_rounded)}, 'Location', 'northeast', 'Interpreter', 'latex');
xlabel('$t$', 'Interpreter', 'latex');
ylabel('$q(e^{(1)}_{i}(t)),i=1,2,...,6$', 'Interpreter', 'latex');
grid on; xlim([0, 2]);box on;
% Improved magnification inset for quantization error
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.4);
initial_data = quantizer1(:, idx_range);

plot(t(idx_range), quantizer1(1,idx_range), 'b-', 'LineWidth', 0.7);
hold on;
plot(t(idx_range), quantizer1(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t(idx_range), quantizer1(3,idx_range), 'r-', 'LineWidth', 0.7);
for I = 2:N_original
plot(t(idx_range), quantizer1(3*(I-1)+1,idx_range), 'b-', 'LineWidth', 0.7);
plot(t(idx_range), quantizer1(3*(I-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t(idx_range), quantizer1(3*(I-1)+3,idx_range), 'r-', 'LineWidth', 0.7);
end
xlim([0, 0.4]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex');
hold off;
figure(42);
% Layer 2 quantization error subplot
hold on;
h1 = plot(t, quantizer2(1,:), 'b-', 'LineWidth', 0.7);
h2 = plot(t, quantizer2(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
h3 = plot(t, quantizer2(3,:), 'r-', 'LineWidth', 0.7);
for I = 2:N_original
plot(t, quantizer2(3*(I-1)+1,:), 'b-', 'LineWidth', 0.7);
plot(t, quantizer2(3*(I-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t, quantizer2(3*(I-1)+3,:), 'r-', 'LineWidth', 0.7);
end
p = plot(T_p, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 6);
legend([h1, h2, h3, p], {'$q(e^{(2)}_{i1}(t))$', '$q(e^{(2)}_{i2}(t))$', '$q(e^{(2)}_{i3}(t))$', sprintf('$\\hat{\\mathcal{T}}^2_p=%.1f$', T_p_rounded)}, 'Location', 'northeast', 'Interpreter', 'latex');
xlabel('$t$', 'Interpreter', 'latex');
ylabel('$q(e^{(2)}_{i}(t)),i=1,2,...,6$', 'Interpreter', 'latex');
grid on; xlim([0, 2]);box on;
% Improved magnification inset for quantization error
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.4);
initial_data = quantizer1(:, idx_range);

plot(t(idx_range), quantizer1(1,idx_range), 'b-', 'LineWidth', 0.7);
hold on;
plot(t(idx_range), quantizer1(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t(idx_range), quantizer1(3,idx_range), 'r-', 'LineWidth', 1.0);
for I = 2:N_original
plot(t(idx_range), quantizer1(3*(I-1)+1,idx_range), 'b-', 'LineWidth', 0.7);
plot(t(idx_range), quantizer1(3*(I-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t(idx_range), quantizer1(3*(I-1)+3,idx_range), 'r-', 'LineWidth', 0.7);
end
xlim([0, 0.4]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex');
hold off;
figure(43);
% Layer 3 quantization error subplot
hold on;
h1 = plot(t, quantizer3(1,:), 'b-', 'LineWidth', 0.7);
h2 = plot(t, quantizer3(2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
h3 = plot(t, quantizer3(3,:), 'r-', 'LineWidth', 0.4);
for I = 2:N_original
plot(t, quantizer3(3*(I-1)+1,:), 'b-', 'LineWidth', 0.7);
plot(t, quantizer3(3*(I-1)+2,:), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t, quantizer3(3*(I-1)+3,:), 'r-', 'LineWidth', 0.7);
end
p = plot(T_p, 0, 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 6);
legend([h1, h2, h3, p], {'$q(e^{(3)}_{i1}(t))$', '$q(e^{(3)}_{i2}(t))$', '$q(e^{(3)}_{i3}(t))$', sprintf('$\\hat{\\mathcal{T}}^2_p=%.1f$', T_p_rounded)}, 'Location', 'northeast', 'Interpreter', 'latex');
xlabel('$t$', 'Interpreter', 'latex');
ylabel('$q(e^{(3)}_{i}(t)),i=1,2,...,6$', 'Interpreter', 'latex');
grid on; xlim([0, 2]);box on;
% Improved magnification inset for quantization error
axes('Position', [0.32, 0.20, 0.36, 0.28]);
idx_range = find(t <= 0.4);
initial_data = quantizer1(:, idx_range);

plot(t(idx_range), quantizer1(1,idx_range), 'b-', 'LineWidth', 0.7);
hold on;
plot(t(idx_range), quantizer1(2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t(idx_range), quantizer1(3,idx_range), 'r-', 'LineWidth', 0.7);
for I = 2:N_original
plot(t(idx_range), quantizer1(3*(I-1)+1,idx_range), 'b-', 'LineWidth', 0.7);
plot(t(idx_range), quantizer1(3*(I-1)+2,idx_range), 'Color', [0, 0.8, 0], 'LineWidth', 0.7);
plot(t(idx_range), quantizer1(3*(I-1)+3,idx_range), 'r-', 'LineWidth', 0.7);
end
xlim([0, 0.4]);
y_min = min(initial_data(:));
y_max = max(initial_data(:));
y_margin = (y_max - y_min) * 0.05;
ylim([y_min - y_margin, y_max + y_margin]);
grid on;
xlabel('$t$', 'Interpreter', 'latex');
hold off;

%% ==================== 自动保存PDF功能 (无攻击版本) ====================
fprintf('\n=== 开始保存图形为PDF文件 (无攻击版本) ===\n');

% 创建保存目录
save_dir = 'simulation_results_no_attack_pdf';
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
    % 第一层总控制输入 u1 -> U1 (图形编号1)
    if ishandle(1)
        save_figure_as_pdf(1, 'U1', save_dir);
    end
    
    % 第二层总控制输入 u2 -> U2 (图形编号2)
    if ishandle(2)
        save_figure_as_pdf(2, 'U2', save_dir);
    end
    
    % 第三层总控制输入 u3 -> U3 (图形编号3)
    if ishandle(3)
        save_figure_as_pdf(3, 'U3', save_dir);
    end
    
    % 第一层量化误差 quantizer1 -> q1 (图形编号41)
    if ishandle(41)
        save_figure_as_pdf(41, 'q1', save_dir);
    end
    
    % 第二层量化误差 quantizer2 -> q2 (图形编号42)
    if ishandle(42)
        save_figure_as_pdf(42, 'q2', save_dir);
    end
    
    % 第三层量化误差 quantizer3 -> q3 (图形编号43)
    if ishandle(43)
        save_figure_as_pdf(43, 'q3', save_dir);
    end
    
    fprintf('\n=== PDF保存完成 (无攻击版本) ===\n');
    fprintf('所有图形已保存到目录: %s\n', save_dir);
    fprintf('文件命名规则:\n');
    fprintf('  - 各层总控制器: U1.pdf, U2.pdf, U3.pdf\n');
    fprintf('  - 各层量化误差: q1.pdf, q2.pdf, q3.pdf\n');
    fprintf('注：无攻击版本不包含phi控制器和攻击信号图形\n');
    
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

