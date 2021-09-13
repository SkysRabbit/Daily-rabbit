function channel_gain = cal_channel_gain(alpha, tr, rc, n_rb, option)
% Input:
% type: Can be Rayleigh or Rician fading for different links
% calculate distances between D2D pairs
% n_rb: number of resource blocks
% alpha: path loss exponent
% PL: pathloss(dB)

% obtain distance between two users
switch option
    case 'D2D&CUE'
        K1 = size(tr);
        K2 = size(rc);
        %distance = zeros(length(tr), length(rc));
        distance = zeros(K1(2),K2(2));
        for i=1:K1(2) % length(tr)
            for j=1:K2(2)
                dist = abs(tr(:,i) - rc(:,j));
                distance(i,j) = sqrt((dist(1,1).^2) + (dist(2,1).^2));
            end
        end
        % shadowing fading
        sigma = 12;
        
        % path-loss model: 30*30 for d2ds
        % pass-loss exponent is 4
        % fc carrier frequency is 2GHz
        PL = 10*alpha*log10(distance) + 28.03;
        % shadowing: 30*30 for d2ds
        shadowing = sigma * ones(size(distance));
        shadowing = shadowing.*randn(size(shadowing));
        
        % mapping PL to 30*600, which represents each d2d link
        % fits in all subchannels (show all possible combination) 
        PL = kron(PL, ones(1, n_rb));
        shadowing = kron(shadowing, ones(1, n_rb));
        
        sub_power_array = 10.^((-PL+shadowing)./10);
        size_h = size(sub_power_array);
        
        % Calculate h (channel vector)
        % Rayleigh small scale fading
        h = (randn(size_h)+1i*randn(size_h))/sqrt(2); 
        
        channel_gain = (abs(h)).^2.*sub_power_array; 
        
    case 'UEtoBS'
        % Base station as receiver, position=(0,0)
        K = size(tr);
        %distance = zeros(length(tr), 1);
        distance = zeros(K(2), 1);
        for i=1:K(2)
            dist = abs(tr(:,i) - rc);
            distance(i,1) = sqrt((dist(1,1).^2) + (dist(2,1).^2));
        end
        % shadowing fading
        sigma = 4;
        
        % alpha in this case should be 3.67
        % fc carrier frequency is set to 2GHz
        % distance: meter, 10m < d < 2000m
        PL = 10*alpha*log10(distance) + 30.526;
        shadowing = sigma * ones(size(distance));
        shadowing = shadowing.*randn(size(shadowing));
        
        PL = kron(PL, ones(1, n_rb));
        shadowing = kron(shadowing, ones(1, n_rb));
        
        sub_power_array = 10.^((-PL+shadowing)./10);
        size_h = size(sub_power_array);
        
        % Rayleigh small scale fading
        h = (randn(size_h)+1i*randn(size_h))/sqrt(2); 
        
        channel_gain = (abs(h)).^2.*sub_power_array;      
end
%dist = abs(tr-rc); 
%dist_users = sqrt((dist(1,:).^2+dist(2,:).^2));
%size_dist = size(dist_users)

% shadow fading
%sigma = 4; 

% rayleigh random variable
% h = (rand(1,number of channel)+j*randn(1,number of channel))/sqrt(2)
% Pathloss model with rayleigh fading (rayleigh random distribution)
% path loss + shadow fading
% shadow fading: gaussian random variable with mean zero and deviation
% sigma (depending on environment)

%PL = 10*alpha*log10(dist_users) + 28.03;
%shadowing = sigma * ones(size(dist_users));
%shadowing = shadowing.*randn(size(shadowing));

%PL = kron(PL, ones(1, n_rb));
%shadowing = kron(shadowing, ones(1, n_rb));
%Path_loss_size = size(PL)
%shadowing_size = size(shadowing)

%sub_power_array = 10.^((-PL+shadowing)./10);
%size_h = size(sub_power_array)
%channel_gain = kron(sub_power_array, ones(1, n_rb));


% Calculate h(dB)
%h = (randn(size_h)+1i*randn(size_h))/sqrt(2); % Rayleigh small scale fading

% final power array
%channel_gain = (abs(h)).^2.*sub_power_array;

% channel_gain(dB)
% The unit of transmission power and receiving power should be watt(W)
% received power = 10^(p/10)*gain, p(dBw)
% Or, received power = p*gain, p(w)
end