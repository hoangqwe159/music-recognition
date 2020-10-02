function [ locs_x, locs_y ] = find_note_locations( subimg, n )
% FIND NOTE LOCATIONS 
%   Inputs, binary images and number of subimages
%   Outputs, subimages stored in cells

    % Structuring elements that looks like note heads
    se_disk_small = strel('disk', 1);
    se_disk = strel('disk', 4);
    se_disk_large = strel('disk', 5);
    half_note_template = imread('images/half_note_template.png');
    half_note_template_bw = imbinarize(half_note_template(:,:,3),...
        'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);

    note_template = imread('images/note_template_1.png');
    note_template_bw = imbinarize(note_template(:,:,3),...
        'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);
    subimg_temp = [];

    for i_img=1:n
        
        

        c = normxcorr2e(note_template_bw,subimg{i_img}, 'same');
        c1 = normxcorr2e(half_note_template_bw,subimg{i_img}, 'same');
        
        imcorr_bw = im2bw(c, 0.55);
        subimg_temp{i_img} = imcorr_bw;
    
        
        [L, n] = bwlabel(subimg_temp{i_img});
        
        % Get all objects areas        
        note_heads = regionprops(L, 'Area');
        m_area = median([note_heads.Area]);


        
        % Remove noise smaller than 40% of the maximal object
        subimg_temp{i_img} = xor(bwareaopen(subimg_temp{i_img}, round(m_area*0.8)),...
            bwareaopen(subimg_temp{i_img}, round(m_area*2)));

        % Merge close objects
        subimg_temp{i_img} = imdilate(subimg_temp{i_img},se_disk_large);
        subimg_temp{i_img} = subimg_temp{i_img} > 0.01;
        
        % Print detected notes as an overlay on the image
        overlay = imoverlay(subimg{i_img}, subimg_temp{i_img}, [.3 1 .3]);
        figure;
        imshow(overlay);
        
        % Find locations of the note head based on their centroids
        note_heads = regionprops(subimg_temp{i_img}, 'Centroid');
        centroids = cat(1, note_heads.Centroid);
        locs_x{i_img} = centroids(:,1);
        locs_y{i_img} = centroids(:,2);
    end 
end

