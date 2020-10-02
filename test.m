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
    
    % ------ PREPROCESSING   
    image = imread("images/mary.png");
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
        
        
        half_note_template = imread('images/half_note_template.png');
        half_note_template_bw = imbinarize(half_note_template(:,:,3),...
            'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);
        
        note_template = imread('images/note_template_1.png');
        note_template_bw = imbinarize(note_template(:,:,3),...
            'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);

        c = normxcorr2(note_template_bw,subimg_no_sl{2});
        c1 = normxcorr2(half_note_template_bw,subimg_no_sl{2});
        
        imcorr_bw = im2bw(c, 0.5);
        
        
        subimg_temp = [];
        i_img = 1;
        subimg_temp{i_img} = imcorr_bw;
        
        [L, n] = bwlabel(imcorr_bw);


        % Get all objects areas
        
        note_heads = regionprops(L, 'Area');
        m_area = median([note_heads.Area]);


        
        % Remove noise smaller than 40% of the maximal object
        subimg_temp{i_img} = xor(bwareaopen(subimg_temp{i_img}, round(m_area*0.8)),...
            bwareaopen(subimg_temp{i_img}, round(m_area*2)));
        
        figure;
        imshow(subimg_temp{i_img});
        
        figure;
        imshow(subimg_no_sl{1});
        
        [x, y] = centresOfMass(subimg_temp{i_img});
        
        x = x - size(note_template_bw, 2) /2;
        y = y - size(note_template_bw, 1) /2;
   
        locs_x{i_img} = centroids(:,1);
        locs_y{i_img} = centroids(:,2);
           
        % Caluculate locations for staff lines in the subimages
        subimg_staff_lines = map_stafflines_to_subimages(staff_lines, split_pos);

        % ------ IDENTIFY NOTES 

        %[locs_x, locs_y] = find_note_locations(subimg, n);
       

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