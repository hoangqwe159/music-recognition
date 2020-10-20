function [ note_array ] = detect_note( sorted_note_properties, subimg_staff_lines, n )
% Detect NOTE PITCH 
%   Inputs, notes properties and subimages
%   Outputs, sorted note array with frequency and duration

  
    note_array = [];
    duration_array =[];
    %pitches = {'E6','D6','C6','B5','A5','G5','F5', 'E5','D5','C5','B4','A4', 'G4','F4', 'E4','D4','C4','B3','A3','G3'};
    frequencies = {1318.51, 1174.66, 1046.50, 987.77, 880.00,  783.99, 698.46, 659.26, 587.33, 523.25, 493.88, 440.00, 392.00, 349.23, 329.63, 293.66, 261.63, 246.94, 220.00, 196.00};
    
    % Distance between staff
    diffrence = mean(diff(subimg_staff_lines{1}))/2;
    
    for i_img=1:n
        
        % Extract note properties from sotred array
        locs_y{i_img} = sorted_note_properties{i_img}(:, 2);
        duration_array = [duration_array, transpose(sorted_note_properties{i_img}(:, 3))];
        
        % The bottom staff line
        ref_staff_line = subimg_staff_lines{i_img}(5);
        
        % Loop through y-axis of subimg
        for i = 1:length(locs_y{i_img})
            
            % Calculate distance from note to bottom line
            distance = ref_staff_line-locs_y{i_img}(i);

            % The scope of the staff, we defined 20 notes from (-5, 15]
            ref_note = 15;
            tone_distance = distance/diffrence;
            
            % Detect note type based on distance from note to the bottom
            % staff based on tone_distance
            if tone_distance < ref_note && tone_distance > -5
                frequency = frequencies{round(ref_note-tone_distance)};
                note_array =  [note_array, frequency];
            else % If the note is not found
               note_array =  [note_array, -1];
            end
        end
    end
    
    % Add duration array to note array
    note_array = vertcat(note_array, duration_array);
end

