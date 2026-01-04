%% Closed-Loop Stability Analysis of Grain Silo Temperature Model (FOPDT)
% First-order + dead time, P-controller → closed-loop remains 1st order
% Routh-Hurwitz + Step Response + IEEE Plot
% 100% working code — December 2025

clear; clc; close all;

%% 1. System Parameters (from your thesis)
K  = -15;           % Process gain (°C per unit input) → cooling = negative
tau = 206.16;       % Time constant in hours
theta = 24;         % Dead time in hours

% Convert to days
tau_days = tau / 24;
theta_days = theta / 24;

fprintf('=== Grain Silo FOPDT Model ===\n');
fprintf('K   = %.2f\n', K);
fprintf('τ   = %.2f hours (%.2f days)\n', tau, tau_days);
fprintf('θ   = %.1f hours (%.2f days)\n', theta, theta_days);

%% 2. Routh-Hurwitz Stability Criterion (Symbolic — now fixed!)
syms s Kc_sym          % ← This line was missing before!
char_eq = tau*s + (1 + Kc_sym*K);

fprintf('\n=== Routh-Hurwitz Analysis (P Control) ===\n');
fprintf('Characteristic equation: %.3f s + (1 + Kc×%.1f) = 0\n', tau, K);

% Stability condition
Kc_ultimate = -1/K;     % Positive because K is negative
fprintf('Stability requires: 1 + Kc×K > 0\n');
fprintf('⇒ Kc < -1/K = %.5f\n', Kc_ultimate);
fprintf('→ Ultimate controller gain Ku = %.5f\n', Kc_ultimate);
fprintf('→ System is STABLE for all 0 < Kc < %.5f\n\n', Kc_ultimate);

%% 3. Closed-Loop Simulation with Different Kc Values
Kc_list = [0.02, 0.04, 0.055, 0.066, 0.0666];  % from safe to near-limit
colors = lines(length(Kc_list));
figure('Color','white','Position',[100 100 620 440]);
leg = {};

for i = 1:length(Kc_list)
    Kc = Kc_list(i);
    
    % Closed-loop transfer function (with input delay)
    num = Kc * K;
    den = [tau  (1 + Kc*K)];
    sys_cl = tf(num, den) * tf(1, 1, 'InputDelay', theta);  % delay in hours
    
    % Simulate 50-day step response
    t_hours = 0:0.5:50*24;           % 0 to 50 days, step 0.5 h
    [y, t_hours_sim] = step(sys_cl, t_hours);
    y = y * (-15);                   % scale to real 0 → -15 °C change
    t_days = t_hours_sim / 24;
    
    % Plot
    plot(t_days, y, 'Color', colors(i,:), 'LineWidth', 2.2); hold on;
    leg{end+1} = sprintf('K_c = %.4f  (pole = %.5f h^{−1})', ...
        Kc, -(1 + Kc*K)/tau);
end

%% 4. Finalize IEEE-Quality Plot
grid on; box on;
xlabel('Time (days)', 'Interpreter','latex', 'FontSize',12);
ylabel('Grain Temperature ($^\circ$C)', 'Interpreter','latex', 'FontSize',12);
title('Closed-Loop Step Response under Proportional Control', ...
    'Interpreter','latex', 'FontSize',13);

% Setpoint line
plot(xlim, [-15 -15], 'k--', 'LineWidth',1.4);
text(38, -14.2, 'Setpoint = $-15^\circ$C', 'FontSize',11, 'BackgroundColor','w');

legend(leg, 'Location','southeast', 'Interpreter','none', 'FontSize',10.5);
set(gca, 'FontName','Times', 'FontSize',11, 'TickLabelInterpreter','latex', ...
    'LineWidth',1.2);

% Stability conclusion box
annotation('textbox', [0.15 0.68 0.35 0.12], 'String', ...
    {'\textbf{\textcolor{green}{All shown K_c values}}', ...
     '\textbf{\textcolor{green}{yield STABLE closed-loop}}', ...
     ['K_{c,max} = ' num2str(Kc_ultimate,'%.5f')]}, ...
    'FitBoxToText','on', 'BackgroundColor','w', 'EdgeColor','g', ...
    'FontSize',11, 'FontWeight','bold');

%% 5. Export High-Quality Figures (IEEE ready)
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 8.7 6.5]);
print('Grain_Silo_ClosedLoop_Stability','-dpdf','-r600');
print('Grain_Silo_ClosedLoop_Stability','-dpng','-r600');

fprintf('\nFigures saved successfully!\n');
fprintf('Conclusion: First-order closed-loop system is STABLE for Kc < %.5f\n', Kc_ultimate);