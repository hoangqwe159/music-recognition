function [sorted_note_properties] = sort_note(quarter_note_properties, half_note_properties,whole_note_properties, n)
% SORT NOTE PITCH 
%   Inputs, notes types, y locations and subimages
%   Outputs, a cell with all classified notes
    
    for i_img = 1:n
        sorted_note_properties{i_img} = vertcat (quarter_note_properties{i_img}, half_note_properties{i_img}, whole_note_properties{i_img});        
        sorted_note_properties{i_img} = sortrows(sorted_note_properties{i_img});
    end
    

end

