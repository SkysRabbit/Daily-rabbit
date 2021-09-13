% The purpose of this program is to observe
% the difference for different number of channels and 
% D2D pairs
clear all; clf
N_ue = 20; N_ch = N_ue; % Number of CUE and channels
N_d2d = 40; % Number of D2D pairs
R_cell = 500; % cell radius
d_due = 50; % maximum distance between each D2D pair [m]
BS = [R_cell;R_cell];
 
% UE Power setting
p_cue = 35; % dBm
p_d2d = 20; % dBm
Thres_cue = 7; % dB, original value =7
Thres_d2d = 3; % dB, original value = Si3
Thres_cue = 10^(Thres_cue/10);
Thres_d2d = 10^(Thres_d2d/10);

n_d2d = (1:N_d2d); % 1 to 40
n_ue = [10,20,30,40];
% run with different number of CUEs and D2D pairs
% Monte Carlo simulation
LOOP = 150;
L = length(n_ue); % 4
K = length(n_d2d); % 1 to n_d2d
SE = zeros(K,4); % game theoretic approach
SE_ran = zeros(K,4); % random
SE_d = zeros(K,4);
SE_d_ran = zeros(K,4);
SE_c = zeros(K,4);
SE_c_ran = zeros(K,4);

% exhaustive search
SE_brute = zeros(K,4);
SE_d_brute = zeros(K,4);
SE_c_brute = zeros(K,4);

% count the number of underlay UE
n_underlay_ue = zeros(K,4); % game theoretic approach
n_underlay_ue_ran = zeros(K,4); % random allocation
avg_SE = zeros(K,4); % store average value (Monte Carlo)
avg_SE_c = zeros(K,4);
avg_SE_d = zeros(K,4);
avg_SE_ran = zeros(K,4);
avg_SE_c_ran = zeros(K,4);
avg_SE_d_ran = zeros(K,4);

avg_SE_brute = zeros(K,4);
avg_SE_c_brute = zeros(K,4);
avg_SE_d_brute = zeros(K,4);

% Store SINR value for every D2D pair (for a specific condition)
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

count_loop = 1;

for i = 1:LOOP
    for j = 1:L
        for c = 1:K
            [ue] = UE_Generation(R_cell,R_cell,R_cell,n_ue(j));
            [tr_ue, re_ue] = DUE_Generation(R_cell,R_cell,R_cell,d_due,n_d2d(c));
            
            % Obtain channel gain for each link(every combination)
            dt_to_BS_gain = cal_channel_gain(3.67, tr_ue, BS, n_ue(j), 'UEtoBS'); % original:3.67
            d2d_gain = cal_channel_gain(4, tr_ue, re_ue, n_ue(j), 'D2D&CUE');
            cue_to_BS_gain = cal_channel_gain(3.67, ue, BS, n_ue(j), 'UEtoBS');
            cue_to_dr_gain = cal_channel_gain(4, ue, re_ue, n_ue(j), 'D2D&CUE');
            
            % power received at BS(W)
            rp_cue_bs = (10^-3*10^(p_cue/10)) * cue_to_BS_gain;
            % interference power at BS(W)
            rp_dt_bs = (10^-3*10^(p_d2d/10)) * dt_to_BS_gain;

            % power received at dt(including power from different pairs)
            rp_dt_d2d = (10^-3*10^(p_d2d/10)) * d2d_gain;
            % interference power from CUE to DUE transmitter(W) 
            rp_cue_d2d = (10^-3*10^(p_cue/10)) * cue_to_dr_gain;
            
            % initial allocation 
            % generate initial channel state matrix
            prev_state_ch = zeros(n_ue(j), n_d2d(c));
            
            ch_arr = (1:n_ue(j));
            for d=1:n_d2d(c)
                % every pair can only select one channel
                n=length(ch_arr);
                idx = ch_arr(randperm(n,1));
                prev_state_ch(idx,d)=1;
            end
            
            count_underlay = 0;
            count_underlay_ran = 0;
            [ch_state_ran,res_ch_ran,sinr_c_ran,sinr_d_ran,sinr_matrix] = Random_allocation(n_d2d(c),n_ue(j),prev_state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs,Thres_cue,Thres_d2d);
            [ch_state_game,count,res_ch,sinr_c,sinr_d,game_matrix] = PureStrategy(n_d2d(c),n_ue(j),prev_state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs,Thres_cue,Thres_d2d);
            [ch_state_brute,res_ch_brute,sinr_c_brute,sinr_d_brute] = ExhaustiveSearch_fairness(n_d2d(c),n_ue(j),prev_state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs,Thres_cue,Thres_d2d);
            
            SE_c(c,j) = sum(log2(1+sinr_c(count+1,:)));
            SE_d(c,j) = sum(log2(1+sinr_d(count+1,:)));
            
            SE_c_brute(c,j) = sum(log2(1+sinr_c_brute(1,:)));
            SE_d_brute(c,j) = sum(log2(1+sinr_d_brute(1,:)));
            
            SE(c,j) = sum(log2(1+sinr_c(count+1,:))) + sum(log2(1+sinr_d(count+1,:)));
            SE_c_ran(c,j) = sum(log2(1+sinr_c_ran(1,:)));
            SE_d_ran(c,j) = sum(log2(1+sinr_d_ran(1,:)));
            
            SE_ran(c,j) = sum(log2(1+sinr_c_ran(1,:))) + sum(log2(1+sinr_d_ran(1,:)));
            SE_brute(c,j) = sum(log2(1+sinr_c_brute(1,:))) + sum(log2(1+sinr_d_brute(1,:)));
            for col = 1:c
                count_underlay = count_underlay + sum(ch_state_game(:,col));
                count_underlay_ran = count_underlay_ran + sum(ch_state_ran(:,col));
                n_underlay_ue(c,j) = count_underlay;
                n_underlay_ue_ran(c,j) = count_underlay_ran;
            end
        end
    end
    avg_SE = avg_SE + SE;
    avg_SE_c = avg_SE_c + SE_c;
    avg_SE_d = avg_SE_d + SE_d;
    
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

% Obtain average value of simulation
avg_SE = avg_SE / LOOP;
avg_SE_c = avg_SE_c / LOOP;
avg_SE_d = avg_SE_d / LOOP;

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

% Comparision between two approaches
% 1. Spectral efficiency 
% 2. SINR at BS and D2D receiver
figure(1)
plot(n_d2d,avg_SE(:,1),'LineWidth',2);
hold on
plot(n_d2d,avg_SE_ran(:,1),n_d2d,avg_SE_brute(:,1));
hold on
plot(n_d2d,avg_SE(:,2),':','LineWidth',2);
hold on
plot(n_d2d,avg_SE_ran(:,2),':',n_d2d,avg_SE_brute(:,2),':');
hold on
plot(n_d2d,avg_SE(:,3),'-.','LineWidth',2);
hold on
plot(n_d2d,avg_SE_ran(:,3),'-.',n_d2d,avg_SE_brute(:,3),'-.');
hold on
plot(n_d2d,avg_SE(:,4),'--','LineWidth',2);
hold on
plot(n_d2d,avg_SE_ran(:,4),'--',n_d2d,avg_SE_brute(:,4),'--');
grid
xlabel('Number of D2D pairs','FontSize',14);
ylabel('Spectral efficiency (bps/Hz)','FontSize',14);
title('System spectral efficiency','FontSize',16);
legend({'CUE=10 (Game theory)','CUE=10 (Random)','CUE=10 (Exhaustive)',...
    'CUE=20 (Game theory)','CUE=20 (Random)','CUE=20 (Exhaustive)',...
    'CUE=30 (Game theory)','CUE=30 (Random)','CUE=30 (Exhaustive)',...
    'CUE=40 (Game theory)','CUE=40 (Random)','CUE=40 (Exhaustive)'},...
    'Location','northwest', 'FontSize', 13);


% SINR comparison for every link (dBW)
figure(2)
plot(n_d2d,avg_SINR_d(:,1),'-o');
hold on
plot(n_d2d,avg_SINR_d_ran(:,1),'--o');
grid
xlabel('D2D pair','FontSize',15);
ylabel('SINR (dBW)','FontSize',15);
title('SINR at every D2D receiver (CUE=40,D2D pair=20)','FontSize',17);
legend({'Game theory', 'Random'}, 'FontSize', 13);


% SINR comparison for every link (dBW)
figure(3)
plot(n_d2d,avg_SINR_bs(:,1),'-d');
hold on
plot(n_d2d,avg_SINR_bs_ran(:,1),'--d');
grid
xlabel('D2D pair','FontSize',15);
ylabel('SINR(dBW)','FontSize',15);
title('SINR at BS from every D2D transmitter (CUE=40, D2D pair=20)',...
    'FontSize',15);
legend({'Game theory', 'Random'},'FontSize',13);


figure(4)
plot(n_d2d,avg_SE(:,2),'-o',n_d2d,avg_SE_c(:,2),'-o',...
    n_d2d,avg_SE_d(:,2),'-o');
hold on
plot(n_d2d,avg_SE(:,4),'-d',n_d2d,avg_SE_c(:,4),'-d',...
    n_d2d,avg_SE_d(:,4),'-d');
grid
xlabel('D2D pair','FontSize',15);
ylabel('Spectral efficiency (bps/Hz)','FontSize',15);
title('Spectrual efficiency for different users','FontSize',17);
legend({'System for CUE=20','CUE for CUE=20','DUE for CUE=20',...
    'System for CUE=40','CUE for CUE=40','DUE for CUE=40'},...
    'Location','northwest', 'FontSize', 13);