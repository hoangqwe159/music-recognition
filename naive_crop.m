function [ height_start, height_end, width_start, width_end ] = naive_crop( image )
% NAIVE CROP 
%   Inputs, image
%   Outputs, positions where to crop
    
    % Theshold the image so that the background is white and the sheet 
    % is black 
    bw = 1-imbinarize(image(:,:,3),'global');
    bw = bwareaopen(bw, 2000);
    bw_out = bw;
    height_start = 1;
    height_end = length(bw_out(:,1));
    width_start = 1;
    width_end = length(bw_out(1,:));
    
    while true
        
        if ~(sum(bw_out(1,:)) > 150 || sum(bw_out(:,1)) > 150 ...
            || sum(bw_out(end,:)) > 150 || sum(bw_out(:,end)) > 150)
            break
        end
        
        width = length(bw_out(1,:));
        height = length(bw_out(:,1));
        
        if sum(bw_out(1,:)) > 150
            bw_out = bw_out(2:height, :);
            height_start = height_start+1;
            height = height-1;
        end
        
        if sum(bw_out(height,:)) > 150
            bw_out = bw_out(1:height-1, :);
            height_end = height_end-1;
            height = height-1;
        end
        
        if sum(bw_out(:,1)) > 150
            bw_out = bw_out(:, 2:width); 
            width_start = width_start+1; 
            width = width-1;
        end
        
        if sum(bw_out(:,width)) > 150
            bw_out = bw_out(:, 1:width-1);
            width_end = width_end-1;
            width = width-1;
        end
        
    end
end

