function [ strout ] = get_note_pitch( locs_eighth_note, locs_fourth_note, locs_y, subimg_staff_lines, n )
% GET NOTE PITCH 
%   Inputs, notes types, y locations and subimages
%   Outputs, a string with all classified notes

    strout = '';
    pitches = {'E4','D4','C4','B3','A3','G3','F3','E3','D3','C3','B2','A2','G2','F2','E2','D2','C2','B1','A1','G1'};
    diffrence = mean(diff(subimg_staff_lines{1}))/2;
   
    for i_img=1:n
        
        % The bottom staff line
        ref_staff_line = subimg_staff_lines{i_img}(5);
        
        % Loop through y-axis of subimg
        for i = 1:length(locs_y{i_img})
            
            % Calculate distance from note to bottom line
            distance = ref_staff_line-locs_y{i_img}(i);


            ref_note = 15;
            tone_distance = distance/diffrence;

            if tone_distance < ref_note && tone_distance > -5
                tone = pitches{round(ref_note-tone_distance)};
            else
                locs_eighth_note{i_img}(i) = false;
                locs_fourth_note{i_img}(i) = false; 
            end


            if locs_eighth_note{i_img}(i)
                tone = lower(tone);
                strout = strcat(strout, tone);

            elseif locs_fourth_note{i_img}(i)
                strout = strcat(strout, tone);
            end

        end

        if i_img ~= n
            strout = strcat(strout, 'n');
        end
    end
end

