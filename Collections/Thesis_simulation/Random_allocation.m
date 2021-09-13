function [state_ch,res_ch,res_sinr_c,res_sinr_d,init_game_matrix] = Random_allocation(N_d2d,N_ch,prev_state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs,Thres_cue,Thres_d2d)
% Random allocation for D2D pairs
% COnstraints should be satisfied as well

% Generate information of every link
[init_game_matrix, sinr_C, sinr_D] = gameMatrix(N_d2d,N_ch,prev_state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs);

% Made alias of inital channel state
state_ch = prev_state_ch;

% record results in arrays
res_ch = zeros(1,N_d2d);
res_sinr = zeros(1, N_d2d);
res_sinr_c = zeros(1,N_d2d);
res_sinr_d = zeros(1,N_d2d);

% Begin Random Allocation 
for m = 1:N_d2d
    pot_sinr_d = zeros(1,N_ch);
    pot_sinr_c = zeros(1,N_ch);
    pot_sinr = zeros(1,N_ch); 
    
    for c = 1:N_ch
        inter_dt_BS = 0;
        inter_dt_other_dr = 0;
        % Avoid recalculate interference term
        % We set the current pair's column of prev_state_ch to zero
        P = find(state_ch(:,m) == 1); % Find which subchannel pair m initially occepies
        state_ch(:,m) = 0;
        % Find underlay pairs for each channel
        underlay_pair = [];
        
        % get indicator of current channel for all pairs
        for i=1:N_d2d
            underlay_pair(i) = getIndicator(state_ch,c,i);
        end
        
        % The step to find potential channel
        % assume current pair occupied the channel
        occupied_ch = find(prev_state_ch(c,:) == 1);
        for i = 1:length(occupied_ch)
                inter_dt_BS = rp_dt_bs(occupied_ch(i),c) + inter_dt_BS;
        end
        
        cue_rp = rp_cue_bs(c,c);
        d2d_rp = rp_dt_d2d(m,N_ch*(m-1)+c);
        inter_cue_dt = double(rp_cue_d2d(c,N_ch*(m-1)+c));
        
        K = find(underlay_pair == 1);
        if isempty(K) == 0
            for l=1:length(K) 
                % underlay_pair(l) = frequency indicator,
                inter_dt_other_dr = underlay_pair(K(l)) * rp_dt_d2d(K(l),N_ch*(K(l)-1)+c) + inter_dt_other_dr;
            end
        end
        
        % remember to add the original channel state back
        state_ch(P,m) = 1;

        SINR_c = cal_SINR(cue_rp, inter_dt_BS);
        SINR_d = cal_SINR(d2d_rp, (inter_cue_dt+inter_dt_other_dr));
        
        if SINR_c >= Thres_cue && SINR_d >= Thres_d2d
            SINR = SINR_c + SINR_d;
        else
            SINR_d = 0; SINR = 0; % SINR_c = 0;
            %SINR_c = cal_SINR(cue_rp, 0);
            %SINR = SINR_d + SINR_c;
        end
        
        % record every sinr value of every channel 
        pot_sinr(1,c) = SINR;
        pot_sinr_c(1,c) = SINR_c;
        pot_sinr_d(1,c) = SINR_d;
        
        % Deal with initial subchannel, reset the SINR value
        if isempty(P) == 0 % not empty
            underlay_pair = []; % modified
            state_ch(P,m) = 0; % set it as 0
            % In this situation, imagine the pair doesn't occupy this
            % channel
            cue_rp = rp_cue_bs(P,P);
            d2d_rp = 0;
            inter_cue_dt = 0;
            inter_dt_BS = 0;
            inter_dt_other_dr = 0;

            occupied_ch = find(state_ch(P,:) == 1);
            for i = 1:length(occupied_ch)
                inter_dt_BS = rp_dt_bs(occupied_ch(i),c) + inter_dt_BS;
            end

            for i=1:N_d2d
                underlay_pair(i) = getIndicator(state_ch,P,i);
            end

            K = find(underlay_pair == 1); 
            for l=1:length(K)
                % underlay_pair(l) = frequency indicator,
                %inter_dt_BS = underlay_pair(K(l)) * rp_dt_bs(K(l),P) + inter_dt_BS;
                inter_dt_other_dr = 0;
                %inter_dt_other_dr = underlay_pair(K(l)) * rp_dt_d2d(K(l),N_ch*(K(l)-1)+c) + inter_dt_other_dr;
            end
            sinr_c = cal_SINR(cue_rp, inter_dt_BS);
            sinr_d = cal_SINR(d2d_rp, (inter_cue_dt+inter_dt_other_dr));

            % Modify utility of previously occupied channel
            init_game_matrix(P,m) = sinr_c + sinr_d;
        end 
          
    end
    
    % randomly selected qualified subchannel 
    % First extract value unequal to zero
    if all(pot_sinr_d(1,:) == 0)
        res_sinr(1,m) = 0;
        res_ch(1,m) = 0;
        res_sinr_c(1,m) = 0;
        res_sinr_d(1,m) = 0;
    else
        qualified_ch = find(pot_sinr > 0); % find indices array (which subchannel) 
        len_qual_ch = length(qualified_ch);
        ch_index = randperm(len_qual_ch,1); % select one subchannel randomly
        
        % save result to each item
        res_sinr(1,m) = pot_sinr(qualified_ch(ch_index));
        res_ch(1,m) = qualified_ch(ch_index);
        res_sinr_c(1,m) = pot_sinr_c(1,qualified_ch(ch_index));
        res_sinr_d(1,m) = pot_sinr_d(1,qualified_ch(ch_index));
        state_ch(res_ch(1,m), m) = 1;
    end

    % update matrix of SINR
    [init_game_matrix,a,b] = gameMatrix(N_d2d,N_ch,state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs);
    
end
end
