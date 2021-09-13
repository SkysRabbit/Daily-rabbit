function [state_ch,count_iter,res_ch,res_sinr_c,res_sinr_d,init_game_matrix] = PureStrategy(N_d2d,N_ch,prev_state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs,Thres_cue,Thres_d2d)
% Game theoretic method 
% Input argument: N_ue and N_d2d
% Output: maximum iteration, channel state, SINR value at BS and DT
% generate BS, CUE, and D2D users

maxIter = 15;

% Game theoretic approach for dynamic resource allocation
% Initialize channel allocation for all d2d pairs and CUEs
% treat indicator as function
% one pair can only occupy one channel, but one channel can 
% be occupied by more than one pair
% Random initial channel allocation

% obtain initial utility of each pair and game matrix
% iter = 0(initial state)
[init_game_matrix, sinr_C, sinr_D] = gameMatrix(N_d2d,N_ch,prev_state_ch,rp_cue_bs,rp_dt_d2d,rp_cue_d2d,rp_dt_bs);
%copy_game_matrix = init_game_matrix; % make a copy
% What does each iteration need to do? 
% Every step stands fpr the RB's update process
% 1. Make sure each pair has selected potential channel
% 2. Meet SINR constraints

%state_ch = zeros(N_ch, N_d2d);

% store the channel of each iteration for each pair
% ex: iter1: pair1 choose ch1
res_ch = zeros(maxIter+1, N_d2d);
res_util = zeros(maxIter+1, N_d2d);
res_sinr_c = zeros(maxIter+1,N_d2d);
res_sinr_d = zeros(maxIter+1,N_d2d);
iter = 0;

state_ch = prev_state_ch;
% I can design initial channel state deliberately
% record inforamtion of iter = 0(initial state)
for i=1:N_d2d
    pre_ch = find(state_ch(:,i) == 1);
    res_ch(1,i) = pre_ch;
    res_util(1,i) = init_game_matrix(pre_ch,i);
    res_sinr_c(1,i) = sinr_C(pre_ch,i);
    res_sinr_d(1,i) = sinr_D(pre_ch,i);
end

r = 0;
count_iter = 0;
while iter <= maxIter % maxIter
    iter = iter + 1;
    % We must find a channel at each iteration
    % Each iteration refers to every step of UE's channel update
    for m=1:N_d2d
        % find the potential channel that maximizes the 
        % utility of each pair 
        % We have initial utility matrix and initial channel state
        % cur_state_ch = prev_state_ch;
        % For each iteration
        % Find underlay pairs for each channel
        pot_sinr_d = zeros(1,N_ch);
        pot_sinr_c = zeros(1,N_ch);
        pot_util = zeros(1,N_ch); % record potential utility
        %unqualified_util = zeros(1,N_ch); % store utility doesn't pass the constraints
        for c=1:N_ch
            inter_dt_BS = 0;
            inter_dt_other_dr = 0;
            % Avoid recalculate interference term
            % We set the current pair's column of prev_state_ch to zero
            P = find(state_ch(:,m) == 1); % Pair m 使用第幾個channel
            state_ch(:,m) = 0;
            % Find underlay pairs for each channel
            underlay_pair = [];
            
            % get indicator of current channel for all pairs
            for i=1:N_d2d
                underlay_pair(i) = getIndicator(state_ch,c,i);
            end
            
            % start to find potential channel
            % assume current pair occupied the channel
            occupied_ch = find(state_ch(c,:) == 1);
            for i = 1:length(occupied_ch)
                inter_dt_BS = rp_dt_bs(occupied_ch(i),c) + inter_dt_BS;
            end
            
            cue_rp = rp_cue_bs(c,c);
            d2d_rp = rp_dt_d2d(m,N_ch*(m-1)+c);
            inter_cue_dt = double(rp_cue_d2d(c,N_ch*(m-1)+c));
            %inter_dt_BS = 0;
            inter_dt_other_dr = 0;
            K = find(underlay_pair == 1);
            if isempty(K) == 0
                for l=1:length(K) 
                    % underlay_pair(l) = frequency indicator,
                    %inter_dt_BS = underlay_pair(K(l)) * rp_dt_bs(K(l),c) + inter_dt_BS;
                    inter_dt_other_dr = underlay_pair(K(l)) * rp_dt_d2d(K(l),N_ch*(K(l)-1)+c) + inter_dt_other_dr;
                end
            end
            
            % remember to add the original channel state back
            prev_state_ch(P,m) = 1;
            
            SINR_c = cal_SINR(cue_rp, inter_dt_BS);
            SINR_d = cal_SINR(d2d_rp, (inter_cue_dt+inter_dt_other_dr));
            
            if SINR_c >= Thres_cue && SINR_d >= Thres_d2d
                utility = SINR_c + SINR_d; 
            else % continue to find qualified channel, protect the incumbent(CUE)
                %if SINR_c >= Thres_cue
                %    fail_util = SINR_c + SINR_d;
                %    unqualified_util(1,c) = fail_util;
                %end
                utility = 0; % Set the utility to zero, no payoff
                SINR_c = 0; SINR_d = 0;
                % Set the channel state to zero(Rejected)
                %prev_state_ch(c,m) = 0; % modified
            end
            pot_util(1,c) = utility;
            pot_sinr_c(1,c) = SINR_c;
            pot_sinr_d(1,c) = SINR_d;
            %unqualified_util(1,c) = fail_util;
            % Compare current to original utility
            % if larger than the origin, replace it
            % Store qualified utility 
            % We need to inspect this part carefully!!
            %prev_utility = init_game_matrix(c,m);
            %cur_utility = utility;
            %if cur_utility >= prev_utility
            %    pot_util(1,c) = cur_utility;
            %else
                % If current value is smaller than the previous
                % In case all utility value are zero
                %pot_util(1,c) = prev_utility;
            %    pot_util(1,c) = 0; % modified, no payoff
            %end
            % update every information of utility and channel state
            % Modify original channel's utility(the channel is not occupied by current pair)
            
            % Current pair: pair m
            %P = find(prev_state_ch(:,m) == 1); % Pair m 使用第幾個channel
            % if current pair has selected one specific channel P
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
            % When previous utility is set to zero, the initial utility
            % should be modified as well
            % Is the value of init_game_matrix correct?
            
        end
        % choose the best channel of current pair at this iteration
        % in the case all utility value are zero
        if all(pot_util(1,:) == 0)
            % At least one utility can give a try
            %[res_util(iter+1,m), res_ch(iter+1,m)] = max(unqualified_util(1,:));
            %prev_state_ch(res_ch(iter+1,m),m) = 1;
            %init_game_matrix(res_ch(iter+1,m),m) = res_util(iter+1,m);
            res_ch(iter+1,m) = 0;
            res_util(iter+1,m) = 0;
            res_sinr_c(iter+1,m) = 0;
            res_sinr_d(iter+1,m) = 0;
            % obtain the largest utility but not pass the constraints
            %res_util(iter+1,m) = init_game_matrix(,m); % stays the same
        else
            [res_util(iter+1,m), res_ch(iter+1, m)] = max(pot_util(1,:));
            res_sinr_c(iter+1,m) = pot_sinr_c(res_ch(iter+1,m));
            res_sinr_d(iter+1,m) = pot_sinr_d(res_ch(iter+1,m));
            % Update the payoff of each pair
            %init_game_matrix(res_ch(iter+1,m),m) = res_util(iter+1,m);
            state_ch(res_ch(iter+1,m), m) = 1;
        end 
        [init_game_matrix,a,b] = gameMatrix(N_d2d,N_ch,state_ch,rp_cue_bs, rp_dt_d2d, rp_cue_d2d, rp_dt_bs);
    end
    
    % Test if all players meet NE
    % count how many pairs have matched
    comp_res = (res_ch(iter+1,:) == res_ch(iter,:));
    r = sum(comp_res(:) == 1); 
    count_iter = count_iter + 1;
    % If all pairs have matched
    if r == N_d2d
        % disp("All pairs have matched")
        %iter = maxIter + 5; 
        break;
    end
end

end