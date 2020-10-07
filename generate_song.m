function song = generate_song(note_array, Fs, octave)
    song = [];
  
    for i_note = 1:size(note_array, 2)
        
        % Extract duration and frequency information
        duration = note_array(2, i_note);
        frequency = note_array(1, i_note);
        
        % Time array
        t = linspace(0, duration, Fs * duration);
        
        % Generate song array
        note = sin(2*pi*octave*frequency*t);
        song = [song note];
    end

end
