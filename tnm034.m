%%%%%%%%%%%%%%%%%%%%%%%%%%
%function strout = tnm034( image )
%
% Im: Input image of captured sheet music. Im should be in
% double format, normalized to the interval [0,1]
%
% strout: The resulting character string of the detected notes.
% The string must follow the pre-defined format, explained below.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%

    Fs = 24000;
    image = imread("images/duck.png");
    % ------ PREPROCESSING  
    
    % Convert to binary image with the size of the cropped image
    bw = 1-imbinarize(image(:,:,3),'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);
  
    % ------ STAFF LINE IDENTIFICATION     
    staff_lines = staff_line_identification(bw);
    
    if ~isempty(staff_lines)
        
        % ------ CLEAN UP IMAGES 

        % Remove staff lines
        bw_no_sl = remove_stafflines(bw, staff_lines);

        % Identify positions to split into subimages for each row block
        split_pos = get_split_positions(bw, staff_lines);

        % Calcualate the number of subimages 
        n = length(split_pos)-1;

        % Split bw and bw without staff lines into subimages
        subimg = split_images(bw, split_pos);
        subimg_no_sl = split_images(bw_no_sl, split_pos);

        % Caluculate locations for staff lines in the subimages
        subimg_staff_lines = map_stafflines_to_subimages(staff_lines, split_pos);

        % ------ IDENTIFY NOTES 
        
        % Find note location
        [locs_x_quarter, locs_y_quarter, quarter_note_properties] = find_note_locations(subimg, n, 'quarter');
        [locs_x_half, locs_y_half, half_note_properties] = find_note_locations(subimg_no_sl, n, 'half');        
        [locs_x_whole, locs_y_whole, whole_note_properties] = find_note_locations(subimg_no_sl, n, 'whole');
        
        % Sort the note based on x-axis
        sorted_note_properties = sort_note(quarter_note_properties, half_note_properties, whole_note_properties, n);       
        
        % Detect note type
        note_array = detect_note(sorted_note_properties, subimg_staff_lines, n);
        
        % Play the song from note array
        song = generate_song(note_array, Fs, 2);
        soundsc(song, Fs);
    end
%end