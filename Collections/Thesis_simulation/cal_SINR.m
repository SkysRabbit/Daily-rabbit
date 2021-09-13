function SINR_arr = cal_SINR(power_arr, interference_arr)
% noise: noise variance = -114dBm
% turn noise into W
% pay attention to the size of the power and interference
% they must stay the same
N0 = -114; % dBm

SINR_arr = power_arr / (interference_arr + (10^-3)*10^(N0/10));
end