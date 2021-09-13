function [cue] = UE_Generation(r,xx0,yy0,N_ue)
% r: radius
% xx0, yy0: centre of the cell
% N_ue: number of CUE
theta=2*pi*(rand(N_ue,1)); %angular coordinates
rho=r*sqrt(rand(N_ue,1)); %radial coordinates
% Convert from polar to Cartesian coordinates
[xx,yy]=pol2cart(theta,rho); %x/y coordinates of Poisson points
% Shift centre of disk to (xx0,yy0)
xx=xx+xx0;
yy=yy+yy0;
cue = zeros(2,N_ue);
for i=1:length(xx)
    cue(1,i)=xx(i);
    cue(2,i)=yy(i);
end
