function [ locs_bb, out_subimg_clean ] = get_bounding_boxes( locs_x, locs_y, subimg_clean, n )
% GET BOUNDING BOXES
%   Inputs, locations of notes and clean subimages
%   Outputs, locations of each bounding box and a cleaner set of subimages

    for i_img=1:n
        % Get all coherent regions
        L = bwlabel(subimg_clean{i_img});
        objects{i_img} = regionprops(L, 'BoundingBox');

        % Print the subimage to have something to draw the bounding boxes on
        %figure
        %imshow(subimg_clean{i_img})

        for i = 1:length(locs_x{i_img})
            for k = 1:length(objects{i_img})
                bb = objects{i_img}(k).BoundingBox;
                % Find right bounding box for each note head
                if locs_x{i_img}(i) > bb(1) && locs_x{i_img}(i) < bb(1)+bb(3) && locs_y{i_img}(i) > bb(2) && locs_y{i_img}(i) < bb(2)+bb(4)
                    % Draw and store bounding box
                    %rectangle('Position',bb,'EdgeColor','green');                
                    locs_bb{i_img}{i} = [bb(1), bb(2), bb(3), bb(4)];
                end
            end
        end
        
        out_subimg_clean = subimg_clean;
        % Clean up everything except the notes
        for k = 1:length(objects{i_img})
           bb_mat = cell2mat(locs_bb{i_img});
           bb = objects{i_img}(k).BoundingBox;
           if ~ (ismember(bb(2), bb_mat(2:4:end)) && ismember(bb(1), bb_mat(1:4:end)))
                out_subimg_clean{i_img}(round(bb(2)):round(bb(2)+bb(4)),round(bb(1)):round(bb(1)+bb(3))) = 0;
           end
        end 
    end
end

