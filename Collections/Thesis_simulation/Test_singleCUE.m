% Test for one type of CUE with different DUEs
clear all; clf
N_ue = 20; N_ch = N_ue; % Number of CUE and subchannels allocated to CUEs
N_d2d = 40; % Number of D2D pairs
R_cell = 500; % cell radius
d_due = 50; % maximum distance between each D2D pair [m]
BS = [R_cell;R_cell]; % location of BS

% UE Power setting
p_cue = 35; % dBm
p_d2d = 20; % dBm
Thres_cue = 7; % dB, original value =7
Thres_d2d = 3; % dB, original value = 3
Thres_cue = 10^(Thres_cue/10);
Thres_d2d = 10^(Thres_d2d/10);

% run with different number of CUEs and D2D pairs
n_d2d = (1:N_d2d);
n_ue = 20;

% Monte Carlo simulation
LOOP = 500;
L = length(n_ue);
K = length(n_d2d);

% Proposed
SE = zeros(K,1); % store system spectrum effieciency
SE_c = zeros(K,1);
SE_d = zeros(K,1);

% random
SE_ran = zeros(K,1); 
SE_d_ran = zeros(K,1);
SE_c_ran = zeros(K,1);

% exhaustive search
SE_brute = zeros(K,1);
SE_d_brute = zeros(K,1);
SE_c_brute = zeros(K,1);
% store number of sharing pair
n_underlay_ue = zeros(K,1);

% Obtain average value
avg_SE = zeros(K,1);
avg_SE_c = zeros(K,1);
avg_SE_d = zeros(K,1);

avg_SE_ran = zeros(K,1);
avg_SE_c_ran = zeros(K,1);
avg_SE_d_ran = zeros(K,1);

avg_SE_brute = zeros(K,1);
avg_SE_c_brute = zeros(K,1);
avg_SE_d_brute = zeros(K,1);
avg_n_underlay_ue = zeros(K,1);

% Store SINR value for each term
SINR_D2D_ran = zeros(N_d2d,LOOP);
SINR_D2D = zeros(N_d2d,LOOP);
SINR_D2D_brute = zeros(N_d2d,LOOP);
SINR_bs_ran = zeros(N_d2d,LOOP);
SINR_bs = zeros(N_d2d,LOOP);
SINR_bs_brute = zeros(N_d2d,LOOP);

avg_SINR_d = zeros(N_d2d,1);
avg_SINR_d_ran = zeros(N_d2d,1);
avg_SINR_d_brute = zeros(N_d2d, 1);
avg_SINR_bs = zeros(N_d2d,1);
avg_SINR_bs_ran = zeros(N_d2d,1);
avg_SINR_bs_brute = zeros(N_d2d, 1);


avg_count = 0;
count_loop = 1;

for i = 1:LOOP
    for c = 1:K
        [ue] = UE_Generation(R_cell,R_cell,R_cell,n_ue);
        [tr_ue, re_ue] = DUE_Generation(R_cell,R_cell,R_cell,50,n_d2d(c));

        % Obtain channel gain for each link(every combination)
        dt_to_BS_gain = cal_channel_gain(3.67, tr_ue, BS, n_ue, 'UEtoBS'); % original:3.67
        d2d_gain = cal_channel_gain(4, tr_ue, re_ue, n_ue, 'D2D&CUE');
        cue_to_BS_gain = cal_channel_gain(3.67, ue, BS, n_ue, 'UEtoBS');
        cue_to_dr_gain = cal_channel_gain(4, ue, re_ue, n_ue, 'D2D&CUE');

        % power received at BS(W)
        rp_cue_bs = (10^-3*10^(p_cue/10)) * cue_to_BS_gain;
        % interference power at BS(W)
        rp_dt_bs = (10^-3*10^(p_d2d/10)) * dt_to_BS_gain;

        % power received at dt(including power from different pairs)
        rp_dt_d2d = (10^-3*10^(p_d2d/10)) * d2d_gain;
        % interference power from CUE to DUE transmitter(W) 
        rp_cue_d2d = (10^-3*10^(p_cue/10)) * cue_to_dr_gain;

        % channel state matrix
        prev_state_ch = zeros(n_ue, n_d2d(c));

        ch_arr = (1:n_ue);
        for d=1:n_d2d(c)
            % every pair can only select one channel
            n=length(ch_arr);
            idx = ch_arr(randperm(n,1));
            prev_state_ch(idx,d)=1;
        end
        
        count_underlay = 0;
        [ch_state,count,res_ch,sinr_c,sinr_d,game_matrix] = PureStrategy(n_d2d(c),n_ue,prev_state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs,Thres_cue,Thres_d2d);
        [ch_state_ran,res_ch_ran,sinr_c_ran,sinr_d_ran,game_matrix_ran] = Random_allocation(n_d2d(c),n_ue,prev_state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs,Thres_cue,Thres_d2d);
        [ch_state_brute,res_ch_brute,sinr_c_brute,sinr_d_brute] = ExhaustiveSearch_fairness(n_d2d(c),n_ue,prev_state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs,Thres_cue,Thres_d2d);
        
        SE_c_ran(c,1) = sum(log2(1+sinr_c_ran(1,:)));
        SE_d_ran(c,1) = sum(log2(1+sinr_d_ran(1,:)));
        SE_c_brute(c,1) = sum(log2(1+sinr_c_brute(1,:)));
        SE_d_brute(c,1) = sum(log2(1+sinr_d_brute(1,:)));
        SE_ran(c,1) = sum(log2(1+sinr_c_ran(1,:))) + sum(log2(1+sinr_d_ran(1,:)));
        SE_brute(c,1) = sum(log2(1+sinr_c_brute(1,:))) + sum(log2(1+sinr_d_brute(1,:)));
        SE_c(c,1) = sum(log2(1+sinr_c(count+1,:)));
        SE_d(c,1) = sum(log2(1+sinr_d(count+1,:)));
        SE(c,1) = sum(log2(1+sinr_c(count+1,:))) + sum(log2(1+sinr_d(count+1,:)));
        for col = 1:c
            count_underlay = count_underlay + sum(ch_state(:,col));
            n_underlay_ue(c,1) = count_underlay;
        end
    end
    avg_SE = avg_SE + SE;
    avg_SE_c = avg_SE_c + SE_c;
    avg_SE_d = avg_SE_d + SE_d;
    avg_n_underlay_ue = avg_n_underlay_ue + n_underlay_ue;
    
    avg_SE_ran = avg_SE_ran + SE_ran;
    avg_SE_c_ran = avg_SE_c_ran + SE_c_ran;
    avg_SE_d_ran = avg_SE_d_ran + SE_d_ran;
    
    avg_SE_brute = avg_SE_brute + SE_brute;
    avg_SE_c_brute = avg_SE_c_brute + SE_c_brute;
    avg_SE_d_brute = avg_SE_d_brute + SE_d_brute;
    
    for x=1:N_d2d
        SINR_D2D(x,i) = sinr_d(count+1,x);
        SINR_D2D_ran(x,i) = sinr_d_ran(1,x);
        SINR_bs(x,i) = sinr_c(count+1,x);
        SINR_bs_ran(x,i) = sinr_c_ran(1,x);
        SINR_D2D_brute(x,i) = sinr_d_brute(1,x);
        SINR_bs_brute(x,i) = sinr_c_brute(1,x);
    end
    
    disp(['Loop: ',num2str(count_loop)]);
    count_loop = count_loop + 1;
end

avg_SE = avg_SE / LOOP;
avg_SE_c = avg_SE_c / LOOP;
avg_SE_d = avg_SE_d / LOOP;
avg_n_underlay_ue = avg_n_underlay_ue / LOOP;

avg_SE_ran = avg_SE_ran / LOOP;
avg_SE_c_ran = avg_SE_c_ran / LOOP;
avg_SE_d_ran = avg_SE_d_ran / LOOP;

avg_SE_brute = avg_SE_brute / LOOP;
avg_SE_c_brute = avg_SE_c_brute / LOOP;
avg_SE_d_brute = avg_SE_d_brute / LOOP;


for pair=1:N_d2d
avg_SINR_d(pair,1) = sum(SINR_D2D(pair,:))/ LOOP;
avg_SINR_d_ran(pair,1) = sum(SINR_D2D_ran(pair,:))/ LOOP;
avg_SINR_d_brute(pair,1) = sum(SINR_D2D_brute(pair,:)) / LOOP;

avg_SINR_bs(pair,1) = sum(SINR_bs(pair,:))/ LOOP;
avg_SINR_bs_ran(pair,1) = sum(SINR_bs_ran(pair,:))/ LOOP;
avg_SINR_bs_brute(pair,1) = sum(SINR_bs_brute(pair,:)) /LOOP;
end

% tranfer W to dBW (unit transformation)
avg_SINR_d = 10*log10(avg_SINR_d);
avg_SINR_d_ran = 10*log10(avg_SINR_d_ran);
avg_SINR_d_brute = 10*log10(avg_SINR_d_brute);

avg_SINR_bs = 10*log10(avg_SINR_bs);
avg_SINR_bs_ran = 10*log10(avg_SINR_bs_ran);
avg_SINR_bs_brute = 10*log10(avg_SINR_bs_brute);

% Compare different number of CUEs/channels and DUEs
% number of D2D pair versus underlaid D2D pair
figure(1)
plot(n_d2d,avg_n_underlay_ue(:,1),'-o','MarkerIndices',n_ue,'MarkerSize',10);
text(n_ue,avg_n_underlay_ue(n_ue,1)-1,['CUE=',num2str(n_ue)], 'FontSize', 14);
grid
xlabel('Number of D2D pairs', 'FontSize', 16);
ylabel('Number of D2D pairs sharing with CUEs', 'FontSize', 16);
%title('Number of shared D2D pairs versus number of D2D pairs', 'FontSize', 16);
%legend({'CUE=20'},'Location','northwest', 'FontSize', 13);

figure(2)
plot(n_d2d,avg_SE(:,1),'-o','MarkerIndices',n_ue,'MarkerSize',10);
hold on
plot(n_d2d,avg_SE_c(:,1));
hold on
plot(n_d2d,avg_SE_d(:,1));
text(n_ue,avg_SE(n_ue,1)-20,['CUE=',num2str(n_ue)], 'FontSize', 13);
grid
xlabel('Number of D2D pairs','FontSize',16);
ylabel('Spectral efficiency (bps/Hz)','FontSize',16);
title('System spectral efficiency', 'FontSize',16);
legend({'System','CUEs','DUEs'}, 'Location','northwest', 'FontSize', 13);

% Compare to another approach
figure(3)
plot(n_d2d,avg_SE(:,1),'LineWidth',2);
hold on
plot(n_d2d,avg_SE_ran(:,1),'LineWidth',2);
hold on
plot(n_d2d,avg_SE_brute(:,1),'LineWidth',2);
hold on
plot(n_d2d,avg_SE_c(:,1),n_d2d,avg_SE_c_ran(:,1),n_d2d,avg_SE_c_brute(:,1));
hold on
plot(n_d2d,avg_SE_d(:,1),'--',n_d2d,avg_SE_d_ran(:,1),'--',n_d2d,avg_SE_d_brute(:,1),'--');
grid
xlabel('Number of D2D pairs','FontSize',14);
ylabel('Spectral efficiency (bps/Hz)','FontSize',14);
title('System spectral efficiency','FontSize',16);
legend({'System (Game theory)','System (Random)','System (Exhaustive)',...
    'CUEs (Game theory)','CUEs (Random)','CUEs (Exhaustive)',...
    'DUEs (Game theory)','DUEs (Random)','DUEs (Exhaustive)'},...
    'Location','northwest', 'FontSize', 13);

% SINR comparison
% SINR at BS
figure(4)
plot(n_d2d,avg_SINR_bs(:,1),'-s');
hold on
plot(n_d2d,avg_SINR_bs_ran(:,1),'-.d');
hold on
plot(n_d2d,avg_SINR_bs_brute(:,1), '--o');
grid
xlabel('D2D pair','FontSize',15);
ylabel('SINR (dBW)','FontSize',15);
legend({'Game theory', 'Random', 'Exhaustive'}, 'FontSize', 13);
title('SINR at BS versus D2D link')

% SINR at each D2D receiver
figure(5)
plot(n_d2d,avg_SINR_d(:,1),'-s');
hold on
plot(n_d2d,avg_SINR_d_ran(:,1),'-.d');
hold on
plot(n_d2d,avg_SINR_d_brute(:,1),'--o');
grid
xlabel('D2D pair','FontSize',15);
ylabel('SINR(dBW)','FontSize',15);
legend({'Game theory', 'Random', 'Exhaustive'},'FontSize',13);
title('SINR at each D2D rceiver')