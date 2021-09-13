function plotCell(center, R, color, marker)
% Input
% center: cell center
% R: radius(m)
theta = linspace(0,2*pi);
x = center(1) + R*cos(theta);
y = center(2) + R*sin(theta);

plot(x, y);
hold on;
% display the location of BS at the center
plot(center(1), center(2), '+', 'Color', color, 'MarkerSize', marker);
hold on;
xlabel('X axis (m)', 'FontSize', 14), ylabel('Y axis (m)', 'FontSize', 14); 
axis equal
end
