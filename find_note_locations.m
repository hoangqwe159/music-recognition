function [ locs_x, locs_y, note_properties ] = find_note_locations( subimg, n, note_type )
% FIND NOTE LOCATIONS 
%   Inputs, binary images and number of subimages
%   Outputs, subimages stored in cells

    % Structuring elements that looks like note heads
    se_disk_large = strel('disk', 5);
    
    
    half_note_template = imread('images/half_note_template.png');
    half_note_template_bw = imbinarize(half_note_template(:,:,3),...
        'adaptive','ForegroundPolarity','dark','Sensitivity',0.30);
    
    half_note_template_1 = imread('images/half_note_template_1.png');
    half_note_template_bw_1 = imbinarize(half_note_template_1(:,:,3),...
        'adaptive','ForegroundPolarity','dark','Sensitivity',0.30);
    
    half_note_template_2 = imread('images/half_note_template_2.png');
    half_note_template_bw_2 = imbinarize(half_note_template_2(:,:,3),...
        'adaptive','ForegroundPolarity','dark','Sensitivity',0.30);

    quarter_note_template = imread('images/quarter_note_template.png');
    quarter_note_template_bw = imbinarize(quarter_note_template(:,:,3),...
        'adaptive','ForegroundPolarity','dark','Sensitivity',0.30);
    
    whole_note_template = imread('images/whole_note_template.png');
    whole_note_template_bw = imbinarize(whole_note_template(:,:,3),...
        'adaptive','ForegroundPolarity','dark','Sensitivity',0.30);
    
    
    subimg_temp = [];

    for i_img=1:n
        
        
        % Matching template by 2D normalized correlation
        if strcmp(note_type,'quarter')
            c = normxcorr2e(quarter_note_template_bw,subimg{i_img}, 'same');
            imcorr_bw = im2bw(c, 0.43);
            duration = 0.25;
        elseif strcmp(note_type,'half')
            % Using 2 images as template
            c = normxcorr2e(half_note_template_bw,subimg{i_img}, 'same');
            c1 = normxcorr2e(half_note_template_bw_1,subimg{i_img}, 'same');
            g = (c + c1) ./ 2;
            imcorr_bw = im2bw(g, 0.46);
            duration = 0.5;
        elseif strcmp(note_type,'whole')
            c = normxcorr2e(whole_note_template_bw,subimg{i_img}, 'same');
            imcorr_bw = im2bw(c, 0.5);
            duration = 1;
        else
            throw(Mexception('find_note_locations:BadInput',...
              'NOTE_TYPE must be ''quarter'' or ''half''.'));
        end

        
        subimg_temp{i_img} = imcorr_bw;
    

        
        % Get all objects areas 
        [L, n] = bwlabel(subimg_temp{i_img});
        note_heads = regionprops(L, 'Area');
        m_area = median([note_heads.Area]);

        % If the number of notes > 0
        if m_area > 0
            % Remove noise smaller than 40% of the maximal object
            subimg_temp{i_img} = xor(bwareaopen(subimg_temp{i_img}, round(m_area*0.8)),...
            bwareaopen(subimg_temp{i_img}, round(m_area*2)));

            % Merge close objects
            subimg_temp{i_img} = imdilate(subimg_temp{i_img},se_disk_large);
            subimg_temp{i_img} = subimg_temp{i_img} > 0.01;

            % Print detected notes as an overlay on the image
%             overlay = imoverlay(subimg{i_img}, subimg_temp{i_img}, [.3 1 .3]);
%             figure;
%             imshow(overlay);

            % Find locations of the note head based on their centroids
            note_heads = regionprops(subimg_temp{i_img}, 'Centroid');
            centroids = cat(1, note_heads.Centroid);
            locs_x{i_img} = centroids(:,1);
            locs_y{i_img} = centroids(:,2);
            
        else
            locs_x{i_img} = [];
            locs_y{i_img} = [];            
        end
        
        % Add note duration
        note_duration{i_img} = duration .* ones( size(locs_x{i_img}, 1), 1); 
        note_properties{i_img} = horzcat( locs_x{i_img}, locs_y{i_img}, note_duration{i_img} );
     
      
    end 
end

