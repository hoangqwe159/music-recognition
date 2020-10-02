function [ rotated_image ] = rotate_image( image )
% FIND ROTATION 
%   Inputs, binary image
%   Outputs, binary image that is rotatated with an angle based on Hough
%   transform

    [H, theta, rho] = hough(image, 'theta', -89.9:0.1:89.9);
    peak = houghpeaks(H);
    lineAngle = theta(peak(2));

    if lineAngle > 0
        rotationAngle = 270 + lineAngle;
    else
        rotationAngle = 90 + lineAngle;
    end
    
     rotated_image = imrotate(image, rotationAngle, 'bilinear','crop');
end

