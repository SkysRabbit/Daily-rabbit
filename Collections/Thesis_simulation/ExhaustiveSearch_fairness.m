function [state_ch,res_ch,res_sinr_c,res_sinr_d] = ExhaustiveSearch_fairness(N_d2d,N_ch,prev_state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs,Thres_cue,Thres_d2d)
% Exhaustive search resource allocation (brute force)
% Subchannels are allocated in advance 
% Procedure o exhaustive research resource allocation
% Find the minimum channel gain from the interference between CUE and D2D
% (the minimum value of rp_cue_d2d) -> first attempt
% or (the minimum value of rp_dt_d2d except the same pair)
% Obtain SINR
% If the pair passes the constraints, assign the subchannel to the pair
% Otherwise, reject the pair

% Generate information of every link
%[init_game_matrix, sinr_C, sinr_D] = gameMatrix(N_d2d,N_ch,prev_state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs);

% Made alias of inital channel state
state_ch = prev_state_ch;
state_ch(:,:) = 0;



% recording results in arrays
res_ch = zeros(1,N_d2d);
res_sinr_c = zeros(1,N_d2d);
res_sinr_d = zeros(1,N_d2d);

% set available pair for current subchannel
available_pair = linspace(1,N_d2d,N_d2d);

% Begin allocation
% Initial channel state has not been given
% start of exhaustive search (brute force) algorithm
% to find optimal solution
for c = 1:N_ch
    % store potential sinr of CUE and DUE in a list
    pot_sinr_c = zeros(1,N_d2d);
    pot_sinr_d = zeros(1,N_d2d);
    pot_sinr_all = zeros(1,N_d2d);
    
    for m = 1:length(available_pair)
        % avoid same pair accesses the same subchannel again
        if available_pair(m) == 0
            continue
        else
            
            inter_dt_BS = 0; inter_dt_other_dr = 0;
            state_ch(c,m) = 1;

            % This part considers underlay situation
            underlay_pair = zeros(1,N_d2d);

            % calculate frequency reuse indicator
            % and store them into underlay_pair
            for d = 1:N_d2d
                underlay_pair(d) = getIndicator(state_ch,c,d);
            end

            % start to calculate sharing sinr value
            occupied_pair = find(state_ch(c,:) == 1);
            % if there exists certain pair occupies the subchannel
            if isempty(occupied_pair) == 0
                for i = 1:length(occupied_pair)
                    inter_dt_BS = rp_dt_bs(occupied_pair(i), c) + inter_dt_BS;
                end
            else
                inter_dt_BS = 0;
            end

            % Obtain received power and interference
            cue_rp = rp_cue_bs(c,c);
            d2d_rp = rp_dt_d2d(m, N_ch*(m-1)+c);
            inter_cue_dt = rp_cue_d2d(c,N_ch*(m-1)+c);

            % Obtain interference from other pair to current pair
            % underlay_pair is a list which contains binary 0 or 1
            K = find(underlay_pair == 1);
            % current pair, i.e. pair m
            if isempty(K) == 0 % if underlay pair exists
                for l=1:length(K) 
                    if K(l) == m
                        continue
                    end
                    inter_dt_other_dr = underlay_pair(K(l)) * rp_dt_d2d(K(l),N_ch*(K(l)-1)+c) + inter_dt_other_dr;
                end
            %else
                %inter_dt_other_dr = 0;
            end

            % Obtain current SINR value and store into a list
            SINR_c = cal_SINR(cue_rp, inter_dt_BS);
            SINR_d = cal_SINR(d2d_rp, (inter_cue_dt+inter_dt_other_dr));

            % verify if the value passes the communication requrement
            if SINR_c >= Thres_cue && SINR_d >= Thres_d2d
                % pass the requirement and store in the list
                SINR = SINR_c + SINR_d;
            else
                SINR_d = 0; 
                SINR = SINR_c;
            end
            
            % store every result into a list
            pot_sinr_c(1,m) = SINR_c;
            pot_sinr_d(1,m) = SINR_d;
            pot_sinr_all(1,m) = SINR;

            % Reset previous channel state
            state_ch(c,m) = 0;
        end
        
    end
    
    if all(pot_sinr_d(1,:) == 0)
        % current subchannel cannot share resource with any pair
        state_ch(c,:) = 0;
        % maintain current available pair list
    else
        [sinr_d_opt, pair_opt] = max(pot_sinr_d(1,:)); % 
        %[sinr_c_opt, pair_opt] = max(pot_sinr_c(1,:)); % CUE as priority
        % allocate current subchannel to the optimal pair
        state_ch(c,pair_opt) = 1;
        
        % store final results for the optimal pair
        % one D2D pair cannot access more than one subchannel
        res_ch(1,pair_opt) = c;
        res_sinr_c(1,pair_opt) = pot_sinr_c(1,pair_opt);
        res_sinr_d(1,pair_opt) = sinr_d_opt;
        %res_sinr_c(1,pair_opt) = sinr_c_opt;
        %res_sinr_d(1,pair_opt) = pot_sinr_d(1,pair_opt);
        
        % remove selected pair from candidate list by giving zero
        available_pair(pair_opt) = 0;
    end
end