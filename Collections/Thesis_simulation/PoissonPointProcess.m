%Simulation window parameters
r=1; %radius of disk
xx0=0; yy0=0; %centre of disk
areaTotal=pi*r^2; %area of disk
%Point process parameters
lambda=10; %intensity (ie mean density) of the Poisson process
%Simulate Poisson point process
numbPoints=poissrnd(areaTotal*lambda);%Poisson number of points
theta=2*pi*(rand(numbPoints,1)); %angular coordinates
rho=r*sqrt(rand(numbPoints,1)); %radial coordinates
%Convert from polar to Cartesian coordinates
[xx,yy]=pol2cart(theta,rho); %x/y coordinates of Poisson points
%Shift centre of disk to (xx0,yy0)
xx=xx+xx0;
yy=yy+yy0;
% modified, generate another point
d = 0.1; %shift radius
shift_x = d*cos(theta).*rand(numbPoints,1);
shift_y = d*sin(theta).*rand(numbPoints,1);
xx1 = xx+shift_x;
yy1 = yy+shift_y;
%Plotting
scatter(xx,yy);
hold on;
scatter(xx1,yy1);
xlabel('x');ylabel('y');
axis square;