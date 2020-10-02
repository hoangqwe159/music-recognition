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
    strout = '';
    image = imread("images/mary.png");
    % ------ PREPROCESSING   
    
    % Crop image
    [height_start, height_end, width_start, width_end] = naive_crop(image);

    % Convert to binary image with the size of the cropped image
    bw = 1-imbinarize(image(height_start:height_end,width_start:width_end,3),...
        'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);

    % Rotate image using Hough transform to find the angle
    bw = rotate_image(bw);
  
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

        % Clean up holes where the staff lines where removed
        subimg_clean = clean_image(subimg_no_sl, n);

        % Caluculate locations for staff lines in the subimages
        subimg_staff_lines = map_stafflines_to_subimages(staff_lines, split_pos);

        % ------ IDENTIFY NOTES 

        [locs_x, locs_y] = find_note_locations(subimg_no_sl, n);

        [locs_bb, subimg_clean] = get_bounding_boxes(locs_x, locs_y, subimg_clean, n);

        % Check if multiple noteheads share bounding box and classify as eighth notes
        locs_group_size = get_note_group(locs_bb, n);

        % ------ CLASSIFY NOTES 

        % Determine note type 
        [locs_fourth_note, locs_eighth_note] = get_note_type(locs_x, locs_y, locs_bb, locs_group_size, subimg_clean, n);    

        % Determine tones
        strout = get_note_pitch(locs_eighth_note, locs_fourth_note, locs_y, subimg_staff_lines, n);
    end
%end