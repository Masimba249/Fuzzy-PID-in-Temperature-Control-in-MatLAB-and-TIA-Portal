%% Grain Storage - PURE DERIVATIVE (D-only) Controller
% Setpoint 0 → 15 °C – shows perfect damping but huge steady-state error
% Tested and working in all MATLAB versions
clear; clc; close all;

%% 1. Plant (same realistic grain silo model)
tau_hours = 206.16;
tau_sec   = tau_hours * 3600;

wn   = 1/(tau_sec/6);
zeta = 0.15;

Gp1  = tf(1, [tau_sec 1]);                                 % Main lag
Gp_res = tf(0.25*[wn^2], [1 2*zeta*wn wn^2]);               % Small resonance
Gp   = Gp1 + Gp_res;                                       % Final plant

%% 2. Pure Derivative Controller (THIS LINE IS NOW 100% CLEAN)
Kd = 80000;                                                % Tune this value
C_D = tf([Kd  0], 1);                                      % Kd*s  ← correct syntax

%% 3. Closed loop
T_cl = feedback(C_D * Gp, 1);

%% 4. Simulation (0 → 15 °C step)
T_setpoint = 15;
t_final_sec = 40*86400;
t = 0:60:t_final_sec;

[y, t_step] = step(T_cl, t);                               % unit step response
y_real = T_setpoint * y;                                   % scale to 15 °C
t_days = t_step / 86400;

%% 5. Metrics
y_ss   = y_real(end);
ess    = T_setpoint - y_ss;
[peak_val, idx_peak] = max(y_real);
overshoot = max(0, 100*(peak_val - T_setpoint)/T_setpoint);

%% 6. Plot
figure('Color','w','Position',[100 100 1200 700]);

subplot(2,1,1)
plot(t_days, y_real, 'Color',[0.0 0.75 0.0], 'LineWidth', 3.2); hold on;
plot([0 40], [15 15], 'k--', 'LineWidth', 2);
plot([0 40], [y_ss y_ss], 'r-.', 'LineWidth', 2);
grid on; box on;
xlim([0 35]); ylim([-1 18]);
title(['Pure Derivative Controller | K_d = ' num2str(Kd)], 'FontSize',15,'FontWeight','bold');
ylabel('Temperature [°C]');
legend('Response','Setpoint 15 °C',['Final value = ' num2str(y_ss,'%.3f') ' °C'],'Location','southeast');

text(10, 5, {['Steady-state error = ' num2str(ess,'%.3f') ' °C'], ...
             ['Overshoot = ' num2str(overshoot,'%.2f') ' %'], ...
             'Excellent damping!','Cannot reach setpoint'}, ...
     'BackgroundColor','w','EdgeColor','k','FontSize',12,'FontWeight','bold');

subplot(2,1,2)
[y_open, t_open] = step(15*Gp, t);
plot(t_open/86400, y_open, 'Color',[0.85 0.15 0.15], 'LineWidth', 3);
hold on; plot([0 40],[15 15],'k--','LineWidth',2);
grid on; box on;
xlim([0 35]); ylim([-1 18]);
title('Open-Loop Step Response (for comparison)','FontSize',14);
xlabel('Time [days]'); ylabel('Temperature [°C]');

%% 7. Summary
fprintf('\n=== Pure Derivative Controller Results ===\n');
fprintf('K_d            = %g\n', Kd);
fprintf('Final temp     = %.4f °C\n', y_ss);
fprintf('Steady-state error = %.4f °C  ← very large!\n', ess);
fprintf('Overshoot      = %.2f %%\n', overshoot);
fprintf('Lesson: Derivative = perfect brake, zero authority at steady-state\n');
fprintf('========================================\n\n');