N = 1e6; 
gamma_th_db = 4; 
gamma_th_lin = 10^(gamma_th_db/10);
gamma_t_db_vec = 20:60;
C_ergodic_LOS = zeros(size(gamma_t_db_vec));
C_ergodic_NLOS = zeros(size(gamma_t_db_vec));
P_out_LOS = zeros(size(gamma_t_db_vec));
P_out_NLOS = zeros(size(gamma_t_db_vec));

% Precompute path loss:
c = 3e8;
f = 900e6;
lambda = c/f;
r = sqrt((80)^2 + (10-6)^2);
G_t_lin = 10^(20/10); 
G_r_lin = 10^(20/10); 
PL = G_t_lin * G_r_lin * (lambda/(4*pi*r))^2;

K_db = 8;
K_lin = 10^(K_db/10);

for idx = 1:length(gamma_t_db_vec)
    gamma_t_db = gamma_t_db_vec(idx);
    gamma_t_lin = 10^(gamma_t_db/10);
    
    % NLOS (Rayleigh)
    X = randn(N,1);
    Y = randn(N,1);
    h_Rayleigh = sqrt((X.^2 + Y.^2)/2); 
    SNR_ray = gamma_t_lin * PL * h_Rayleigh.^2;
    C_ergodic_NLOS(idx) = mean(log2(1 + SNR_ray));
    P_out_NLOS(idx) = mean(SNR_ray <= gamma_th_lin);
    
    % LOS (Rician)
    X = randn(N,1);
    Y = randn(N,1);
    h_Rician = sqrt((K_lin/(K_lin+1))) + sqrt(1/(K_lin+1))*(X + 1j*Y);
    h_Rician_amp = abs(h_Rician);
    SNR_ric = gamma_t_lin * PL * h_Rician_amp.^2;
    C_ergodic_LOS(idx) = mean(log2(1 + SNR_ric));
    P_out_LOS(idx) = mean(SNR_ric <= gamma_th_lin);
end

% Plot results
figure; 
plot(gamma_t_db_vec, C_ergodic_NLOS, 'r', gamma_t_db_vec, C_ergodic_LOS, 'b'); 
xlabel('SNR (dB)'); ylabel('Ergodic Capacity (bits/s/Hz)'); legend('NLOS','LOS');

figure; 
plot(gamma_t_db_vec, P_out_NLOS, 'r', gamma_t_db_vec, P_out_LOS, 'b');
xlabel('SNR (dB)'); ylabel('Outage Probability'); legend('NLOS','LOS');
