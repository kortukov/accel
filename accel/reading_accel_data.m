cd /home/evgeny/lab/accel
files = dir('*.ann')


for i = 3%1:size(files,1)
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
    session = str2num(filename(k(1)+1));
    
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
    for j = 1:length(ST)
        markers(find(markers(:,3)==ST(j)),3)= 1;
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
    
    if length(st_times_eeg)~=length(rs_times_eeg)
       warning('stim_reaction disbalance!');
    end
    
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
    else
        warning('multiple stimuli lost')
    end
    
    
    %now forming the needed data matrix
    accel_full = EEG.data(45, :);
    dead_time = 250 %ms - before this time we will not analyze acel signal
    data_matrix = []
    for j = 1:length(epoch_number)
        
        data_matrix(j).num = epoch_number(j);
        if rs_times_eeg(j)-st_times_eeg(j) > dead_time % if not omission or false alarm
            data_matrix(j).accel = accel_full(st_times_eeg(j)+dead_time:rs_times_eeg(j))';
            data_matrix(j).accel_diff = [0; diff(data_matrix(j).accel)]
            data_matrix(j).time = [st_times_eeg(j)+dead_time:rs_times_eeg(j)]';
            data_matrix(j).begin = double(st_times_eeg(j)+dead_time);
            data_matrix(j).end = double(rs_times_eeg(j));
            data_matrix(j).response = markers(rs_indices(j),3);
        else %omission or false alarm
            data_matrix(j).accel = NaN;
            data_matrix(j).accel_diff = NaN;
            data_matrix(j).time = NaN;
            data_matrix(j).begin = double(st_times_eeg(j));
            data_matrix(j).end = double(rs_times_eeg(j));
            data_matrix(j).response = 0;
        end
        % NOT INFORMATIVE
        %data_matrix(j).speed = cumtrapz(data_matrix(j).accel);
        %data_matrix(j).position = cumtrapz(data_matrix(j).speed);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %here we will add data_matrix(j).hustle made with 
        %final_labels.m,when the labels for 0,1,2,3 sessions are ready
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    data.data_matrix = data_matrix;
    data.subject = subject;
    data.session = session;
    
    try
        if (session == 0) || (session == 1)
            cd /home/evgeny/lab/clean_data
            cd(subject);
            load([filename '_video_data.mat'], '-mat', 'hustle_timecourse', 'epoch_labels');
            for j = 1:length(epoch_number)
                data.data_matrix(j).epoch_labels = epoch_labels(j); 
            end
            data.number_of_hustles = length(find(epoch_labels));
            data.number_of_nonhustles = length(stim_indices) - data.number_of_hustles;
        end
    catch
        warning('Was unable to find labels');
    end
    
    cd /home/evgeny/lab/accel/data
    save([filename '_accel_data.mat'], '-mat', 'data');
end

cd /home/evgeny/lab/task/accel