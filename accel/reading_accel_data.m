cd /home/evgeny/lab/accel
files = dir('*.ann')


for i = 1:1%size(files,1)
    %reading set file
    cd /home/evgeny/lab/accel/set
    [path, filename, ext] = fileparts(files(i).name); 
    set_filename = [filename '.set'];
    try
        load(set_filename, '-mat');
    catch
        warning('.set file not found');
        continue
    end
    %creating subject and session fields
    k = strfind(filename, '_') 
    subject = filename(1:k(1)-1);
    session = filename(k(1)+1);
    
    %reading ann_data
    cd /home/evgeny/lab/accel
    markers = readtable(files(i).name, 'filetype', 'text');
    markers = table2array(markers);
    ST = [11,12,21,22,211,212,221,222]; %stimuli
    RS = [101,104]; %responses
    FB = [85,88,89,255]; % feedback
    
    %cleaning eeg data
    % clear unused marker
    for j = 1:length(FB)
        markers(find(markers(:,3)==FB(j)),:)=[];
    end
    %replace stimuli marks with ones
    for i = 1:length(ST)
        markers(find(markers(:,3)==ST(i)),3)= 1;
    end
    %replace resp marks with [2, -2] for [101, 104] correspondingly
    markers(find(markers(:,3)==RS(1)),3)= 2;
    markers(find(markers(:,3)==RS(2)),3)= -2;
    
    %searching for absent and then double (or more) responses
    stim_indices = find(markers(:,3) == 1);
    for j = 1:length(stim_indices)
        if (markers(stim_indices(j),3) == 1) && (markers(stim_indices(j)+1,3) == 1)
            markers = [markers(1:stim_indices(j),:);markers(stim_indices(j),1),1,2; markers(stim_indices(j)+1:end,:)];
            stim_indices(j+1:end) = stim_indices(j+1:end) + 1;
            %added a synthetic response at the time of the stimulus
            %and changed all consequent stimuli indices
        end
    end

    rs_indices = find(abs(markers(:,3)) == 2);

    for j = 1:length(rs_indices)-1
        if (abs(markers(rs_indices(j),3)) == 2) && (abs(markers(rs_indices(j)+1,3)) == 2)
            markers = [markers(1:rs_indices(j),:);markers(rs_indices(j)+2:end,:)];
            rs_indices(j+1:end) = rs_indices(j+1:end) - 1;
        end
    end
    stim_indices = find(markers(:,3) == 1);
    rs_indices = find(abs(markers(:,3)) == 2);
    st_times_eeg = markers(stim_indices);
    rs_times_eeg = markers(rs_indices);
    
    
    %now checking from which stimulus the eeg recording started
    %3 different options - 50, 100 and 200 epochs
    %assuming error in time is less than 20 epochs
    len = length(stim_indices);
    if (30 <= len) && (len <= 50)
       first_recorded_stimulus_eeg = 50 - length(stim_indices) + 1; 
       epoch_number = [first_recorded_stimulus_eeg: 50]';
    elseif (80 <= len) && (len <= 100)
       first_recorded_stimulus_eeg = 100 - length(stim_indices) + 1;
       epoch_number = [first_recorded_stimulus_eeg: 100]';
    elseif (180 <= len) && (len <= 200)
        first_recorded_stimulus_eeg = 200 - length(stim_indices) + 1;
        epoch_number = [first_recorded_stimulus_eeg: 200]';
    end
    
    %now forming the needed data matrix
    accel_full = EEG.data(45, :);
    accel = {};
    time = {};
    speed = {};
    position = {};
    for j = 1:length(epoch_number)
        accel{end + 1} = accel_full(st_times_eeg(j):rs_times_eeg(j))';
        time{end + 1} = [st_times_eeg(j):rs_times_eeg(j)]';
    end
    accel = accel';
    time = time';
    
    
end

cd /home/evgeny/lab/task/accel