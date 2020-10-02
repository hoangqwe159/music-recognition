function [x, y] = centresOfMass(BW)
% centresOfMass  Find centres of mass of particles in black and white image
% [x, y] = centresOfMass(BW) returns the (x,y) coordinates of the centres
% of mass identified in the black and white image BW.  Coordinates are
% relative to a [-1,1] x [-1,1] axis.

% Identify region boundaries in image
B = bwboundaries(BW);

% n is the number of regions identified
n = length(B);
x = zeros(1, n);
y = zeros(1, n);

% Compute centres of mass in (x,y) coordinates
for i = 1:n
    x(i) = mean(B{i}(:,2)) ;
    y(i) =mean(B{i}(:,1));
end