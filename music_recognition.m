
    

% ------ PREPROCESSING  
% Load image (avaiable images to load: duck.png, jingle_bells.png,
% mary.png)
image = imread("images/half_note_template.png");

% Convert to binary image with the size of the cropped image
% (Background is black)
bw = 1-imbinarize(image(:,:,3),'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);

% ------ DETECT STAFF LINES     
staff_lines = detect_staff_lines(bw);

if isempty(staff_lines)
    throw(MException('music_recognition:BadImage',...
              'Music sheet image is requried'));
end

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

% ------ DETECT NOTES 
% Find note location
quarter_note_properties = find_note_locations(subimg, n, 'quarter');
half_note_properties = find_note_locations(subimg_no_sl, n, 'half');        
whole_note_properties = find_note_locations(subimg_no_sl, n, 'whole');

% Sort the note based on x-axis
sorted_note_properties = sort_note(quarter_note_properties, half_note_properties, whole_note_properties, n);       

% Detect note type
note_array = detect_note(sorted_note_properties, subimg_staff_lines, n);

% ------ PLAY NOTES 
% Play the song from note array
Fs = 24000;
song = generate_song(note_array, Fs, 2);
soundsc(song, Fs);

    
