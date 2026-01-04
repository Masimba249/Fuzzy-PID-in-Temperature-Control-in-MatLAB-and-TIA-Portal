%% Grain Storage - Linear Simulation, Step, Impulse, Nyquist & Bode Analysis
clear; clc; close all;

%% 1. Define Parameters
tau_hours = 206.16;              % Time constant in hours
tau_sec   = tau_hours * 3600;    % Time constant in seconds
K2 = 1;                          % DC gain of the process

%% 2. Create Transfer Function
Gp = tf(K2, [tau_sec 1]);        % Gp(s) = 1 / (tau*s + 1)

%% 3. Display Transfer Function
disp('---------------------------------------------');
disp(' GRAIN STORAGE TRANSFER FUNCTION Gp(s):');
disp('---------------------------------------------');
disp(Gp);
disp('---------------------------------------------');

%% 4. Fault Simulation (Step Change in Coolant Temperature)
t_days = 0:0.1:50;
t_sec  = t_days' * 86400;

u_coolant = 15 * ones(size(t_sec));
u_coolant(t_days >= 25) = 18;    % Fault: coolant jumps from 15 to 18 °C at day 25

T_grain = lsim(Gp, u_coolant, t_sec);

figure('Color','w','Position',[100 100 900 600]);
subplot(2,1,1);
plot(t_days, u_coolant, 'g-', 'LineWidth', 2);
ylabel('Coolant Temp T_c [°C]'); grid on;
title('Input: Coolant Temperature Fault at Day 25');
ylim([14 19]);

subplot(2,1,2);
plot(t_days, T_grain, 'b-', 'LineWidth', 2.5);
hold on; yline(18, 'r--', 'LineWidth', 1.2);
xlabel('Time [days]'); 
ylabel('Grain Temp T_{grain} [°C]');
title(['Response to Coolant Fault (\tau = ' num2str(tau_hours,'%.1f') ' hours)']);
grid on;

%% 5. Step Response: Setpoint 0 → 15 °C with τ and rise time labeled
T_initial  = 0;                  % °C
T_setpoint = 15;                 % °C
Delta_T    = T_setpoint - T_initial;

t_final_sec = 5 * tau_sec;
[y_norm, t_step] = step(Gp, t_final_sec);
y_real = T_initial + Delta_T * y_norm;

t_step_days = t_step / 86400;
tau_days    = tau_sec / 86400;

% Rise time (10% – 90%)
final_value = T_setpoint;
T10 = 0.10 * final_value;
T90 = 0.90 * final_value;

idx10 = find(y_real >= T10, 1, 'first');
idx90 = find(y_real >= T90, 1, 'first');

t_rise_sec  = t_step(idx90) - t_step(idx10);
t_rise_days = t_rise_sec / 86400;
t_rise_mid_days = t_step_days(idx10) + 0.5*t_rise_days;

figure('Color','w','Position',[1000 100 960 560]);
plot(t_step_days, y_real, 'k-', 'LineWidth', 2.5); hold on;

% Time constant τ (63.2%)
T632 = 0.6321 * final_value;
plot([tau_days tau_days], [0 T632], 'r--', 'LineWidth', 1.8);
plot([0 tau_days], [T632 T632], 'r--', 'LineWidth', 1.8);
plot(tau_days, T632, 'ro', 'MarkerSize',8, 'MarkerFaceColor','r');

% Rise time 10%-90%
plot([t_step_days(idx10) t_step_days(idx90)], [T10 T10], 'b--', 'LineWidth', 1.5);
plot([t_step_days(idx10) t_step_days(idx10)], [0 T10], 'b--', 'LineWidth', 1.5);
plot([t_step_days(idx90) t_step_days(idx90)], [0 T90], 'b--', 'LineWidth', 1.5);
plot(t_step_days(idx10), T10, 'bo', 'MarkerSize',8, 'MarkerFaceColor','b');
plot(t_step_days(idx90), T90, 'bo', 'MarkerSize',8, 'MarkerFaceColor','b');

% Setpoint line
plot(xlim, [T_setpoint T_setpoint], 'k:', 'LineWidth', 1.2);

xlabel('Time [days]'); ylabel('Temperature [°C]');
title('Step Response: Setpoint Change 0 °C \rightarrow 15 °C');
legend('Temperature response', ...
       sprintf('\\tau = %.2f days (63.2%%)', tau_days), ...
       sprintf('t_r (10%%-90%%) = %.2f days', t_rise_days), ...
       'Location','southeast');

% Text annotations
text(tau_days*1.05, T632 + 0.5, sprintf('\\tau = %.2f days', tau_days), ...
     'Color','red', 'FontWeight','bold', 'FontSize',11);
text(t_rise_mid_days, T90 + 1.0, sprintf('t_r = %.2f days', t_rise_days), ...
     'Color','blue', 'FontWeight','bold', 'FontSize',11, 'HorizontalAlignment','center');
grid on; axis tight; ylim([-0.5 16]);

%% 7 Nyquist - Stability Type Indication
% Setup System (First-Order Lag)
Gp_nyquist = tf(1, [10 1]); 

% --- 1. Figure Setup ---
figure('Color', 'w', 'Units', 'inches', 'Position', [2, 2, 5, 4.5]); 
ax = gca;
hold on; axis equal; box on;
set(ax, 'FontName', 'Times New Roman', 'FontSize', 10);

% --- 2. Draw M-Circles (Context Layer) ---
dB_levels = [6, 0, -6]; 
theta = linspace(0, 2*pi, 300);
for dB = dB_levels
    M = 10^(dB/20);
    if abs(dB) < 1e-6
        x_m = -0.5 * ones(size(theta)); y_m = linspace(-5, 5, length(theta));
    else
        x0 = -M^2 / (M^2 - 1); r = abs(M / (M^2 - 1));
        x_m = x0 + r * cos(theta); y_m = r * sin(theta);
    end
    plot(x_m, y_m, ':', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.8);
end

% --- 3. Stability Regions (Visual Indication) ---
fill([-2 -2 -0.8 -0.8], [-1 1 1 -1], [1 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
text(-1.4, 0.8, '\it{Unstable Region}', 'Color', [0.7 0 0], 'FontSize', 8, 'FontName', 'Times New Roman');

% --- 4. Plot Main Data ---
[re, im, w] = nyquist(Gp_nyquist, logspace(-2, 3, 1000));
re = squeeze(re); im = squeeze(im);

% Critical Point
plot(-1, 0, 'rx', 'MarkerSize', 10, 'LineWidth', 2); 

% Main Locus
pMain = plot(re, im, 'b-', 'LineWidth', 2, 'Color', [0 0.447 0.741]); 

% Direction Arrows
q1 = quiver(re(100), im(100), re(101)-re(100), im(101)-im(100), 30, 'k', 'LineWidth', 1.5, 'MaxHeadSize', 4);
mid = floor(length(re)/2);
q2 = quiver(re(mid), im(mid), re(mid+1)-re(mid), im(mid+1)-im(mid), 30, 'k', 'LineWidth', 1.5, 'MaxHeadSize', 4);

% --- 5. Explicit Stability Type Annotation ---
dist_sq = (re + 1).^2 + im.^2;
[min_dist, idx] = min(dist_sq);

str_logic = {
    '\textbf{Stability Analysis}';
    'Type: \textbf{Unconditionally Stable}';
    '--------------------------------';
    '$P = 0$ (Open-loop unstable poles)';
    '$N = 0$ (Encirclements of -1)';
    '$\Rightarrow Z = N + P = 0$ (Closed-loop stable)';
    '--------------------------------';
    ['Min Distance: ' sprintf('%.2f', sqrt(min_dist))];
};

annotation('textbox', [0.55 0.58 0.35 0.3], 'String', str_logic, ...
    'Interpreter', 'latex', 'FontSize', 10, 'FontName', 'Times New Roman', ...
    'BackgroundColor', 'w', 'EdgeColor', [0.2 0.2 0.2], 'LineWidth', 1, 'Margin', 6);

xlabel('Real Axis $\mathcal{R}e(G(j\omega))$', 'Interpreter', 'latex', 'FontSize', 11);
ylabel('Imaginary Axis $\mathcal{I}m(G(j\omega))$', 'Interpreter', 'latex', 'FontSize', 11);
xlim([-1.8 1.2]);
ylim([-1.2 1.2]);
grid on;
hold off;

%% 8. Bode Plot with Built-in Margins
figure('Color','w','Position',[200 200 800 600]);
% Using 'margin' instead of 'bode' automatically calculates and plots the margins
margin(Gp); 
grid on;
title('Bode Plot with Margins: G_p(s) = 1/(206.16 \times 3600 s + 1)');

%% 9. Custom Bode Plot with Manual Arrows for Margins
figure('Color','w','Position',[200 100 900 700]);

% 1. Frequency Vector and Data
w = logspace(-7, -1, 1000);
[mag, phase] = bode(Gp, w);
mag = squeeze(mag); 
phase = squeeze(phase);
mag_dB = 20*log10(mag);

% Corner frequency calculation
omega_c = 1/tau_sec;

% --- SUBPLOT 1: MAGNITUDE ---
subplot(2,1,1);
semilogx(w, mag_dB, 'b-', 'LineWidth', 2); hold on;
grid on;

% Draw 0 dB Reference Line
yline(0, 'k-', 'LineWidth', 1.5); 

% Annotate "Infinite Phase Margin"
% Since the curve never rises above 0 dB, we point to the gap.
text_x = w(round(length(w)*0.15)); % Pick a spot on the left
text_y = -10;
text(text_x, text_y, {'Phase Margin: \infty', '(Mag never exceeds 0 dB)'}, ...
     'Color', 'k', 'FontSize', 10, 'FontWeight', 'bold', ...
     'BackgroundColor','w', 'EdgeColor','k');

% Arrow pointing to the 0 dB line
plot([text_x text_x], [text_y+2 0], 'k-', 'LineWidth', 1);
plot(text_x, 0, 'kv', 'MarkerFaceColor','k'); % Arrowhead

% Mark Corner Frequency
xline(omega_c, 'r--', 'LineWidth', 1);
plot(omega_c, -3.01, 'ro', 'MarkerFaceColor','r');
text(omega_c, -3.01 - 15, sprintf('\\omega_c\n(-3 dB)'), 'Color','r', 'HorizontalAlignment','center');

ylabel('Magnitude (dB)');
title('Bode Plot with Explicit Stability Margins');
ylim([-100 10]); 

% --- SUBPLOT 2: PHASE ---
subplot(2,1,2);
semilogx(w, phase, 'b-', 'LineWidth', 2); hold on;
grid on;

% Draw -180 Instability Line
yline(-180, 'r--', 'LineWidth', 2);
text(w(1), -175, 'Instability Limit (-180^\circ)', 'Color', 'r', 'FontSize', 9);

% --- DRAW ARROW FOR GAIN MARGIN ---
% We pick a frequency on the right side where the gap is visible
idx_arrow = round(length(w) * 0.7); 
x_arrow = w(idx_arrow);
y_curve = phase(idx_arrow);
y_limit = -180;

% 1. The Arrow Line (Vertical)
plot([x_arrow x_arrow], [y_curve y_limit], 'g-', 'LineWidth', 2);

% 2. The Arrowheads (Manual plotting ensures they appear correctly)
plot(x_arrow, y_curve, 'gv', 'MarkerFaceColor','g', 'MarkerSize', 8); % Top head
plot(x_arrow, y_limit, 'g^', 'MarkerFaceColor','g', 'MarkerSize', 8); % Bottom head

% 3. The Text Label
text(x_arrow, (y_curve + y_limit)/2, ...
     {'   Gain Margin: \infty', '   (Phase never reaches -180^\circ)'}, ...
     'Color', [0 0.5 0], 'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');

ylabel('Phase (degrees)');
xlabel('Frequency (rad/s)');
ylim([-190 0]);

sgtitle('Stability Analysis: Infinite Margins (First-Order System)');
%% Summary Output
tau_days = tau_hours / 24;
peak_theory = K2 / tau_sec;   % Theoretical impulse response peak (for FOPDT)

fprintf('\n=== Summary ===\n');
fprintf('Time constant τ = %.2f hours = %.2f days\n', tau_hours, tau_days);
fprintf('Corner frequency ω_c = 1/τ = %.3e rad/s\n', omega_c);
fprintf('Margins Check:\n');
fprintf('  Gain Margin: Infinite (First-order system phase never crosses -180°)\n');
fprintf('  Phase Margin: Infinite (Magnitude is always <= 0dB, stable for all K)\n');
fprintf('================================\n\n');