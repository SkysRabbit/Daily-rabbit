function frequency_indicator = getIndicator(state_ch,c,d)
% To decide the frequency indicator in a more efficient way
% Input arguments:
% c = which channel 
% d = which pair
if state_ch(c,d) == 1
    frequency_indicator = 1;
else
    frequency_indicator = 0;
end
end
