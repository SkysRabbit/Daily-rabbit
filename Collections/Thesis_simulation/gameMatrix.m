function [game_matrix, SINR_c, SINR_d] = gameMatrix(N_d2d, N_ch, state_ch, rp_cue_bs, rp_dt_d2d, rp_cue_d2d, rp_dt_bs)
% generate original utility matrix of all pairs and channels
game_matrix = zeros(N_ch, N_d2d);
%inter_dt_BS = 0;
%inter_dt_other_dr = 0;
SINR_c = zeros(N_ch, N_d2d);
SINR_d = zeros(N_ch, N_d2d);

for m = 1:N_d2d
    %iter = iter + 1;
    %if iter <= maxIter
    for ch = 1:N_ch
        inter_dt_BS = 0;
        inter_dt_other_dr = 0;
        [reuse, pos] = VerfifyReuse(state_ch, ch);
        % calculate each pair's utility, perhaps using max()?
        cue_rp = rp_cue_bs(ch,ch);
        %d2d_rp = rp_dt_d2d(m,N_ch*(m-1)+ch);
        %inter_cue_dt = rp_cue_d2d(ch,N_ch*(m-1)+ch);
        
        % obtain interference at BS
        
        % Verify if the current pair is in underlay situation
        if reuse == 1 
            occupied_ch = find(state_ch(ch,:) == 1);
            for i = 1:length(occupied_ch)
                inter_dt_BS = rp_dt_bs(occupied_ch(i),ch) + inter_dt_BS;
            end
            
            if any(pos(:) == m)
                d2d_rp = rp_dt_d2d(m,N_ch*(m-1)+ch);
                inter_cue_dt = rp_cue_d2d(ch, N_ch*(m-1)+ch);
                pos(pos(:) == m) = [];
                for p = 1:length(pos)
                    % interference
                    inter_dt_other_dr = rp_dt_d2d(pos(p),N_ch*(m-1)+ch);
                end
            else
                d2d_rp = 0;
                inter_cue_dt = 0;
                inter_dt_other_dr = 0;
            end
            %d2d_rp = rp_dt_d2d(m,N_ch*(m-1)+ch);
            %inter_cue_dt = rp_cue_d2d(ch, N_ch*(m-1)+ch);
            % interference term, except current pair
            %pos(pos(:) == m) = [];
        else % current pair doesn't occupy the channel
            % gain
            d2d_rp = 0;
            % interference
            inter_cue_dt = 0;
            inter_dt_BS = 0;
            %inter_dt_BS stays the same as above;
            inter_dt_other_dr = 0;
        end

        sinr_c = cal_SINR(cue_rp,inter_dt_BS);
        sinr_d = cal_SINR(d2d_rp, (inter_cue_dt+inter_dt_other_dr));
        % fill utility into game matrix
        SINR_c(ch,m) = sinr_c;
        SINR_d(ch,m) = sinr_d;
        game_matrix(ch,m) = sinr_c + sinr_d;
    end 
end
end
