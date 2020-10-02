function [ subimg_staff_lines ] = map_stafflines_to_subimages( staff_lines, split_pos )
% MAP STAFF LINES TO SUBIMAGES 
%   Inputs, staff lines and split positions
%   Outputs, staff lines locations in subimages
    
    subimg_staff_lines = [];
    for i=1:length(split_pos)-1
        for j=1:5
            subimg_staff_lines{i}(j) = staff_lines((i-1)*5+j) - split_pos(i);
        end
    end
end

