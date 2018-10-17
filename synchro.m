%First synchronizing algorithm
%Counting a vector of differences between all stimuli on video and eeg
%Works only if all stimuli on video and eeg are present 
cd /home/evgeny/lab/ann
files = dir('*.ann')

corrupt_video_files = {}%Video files with lost stimuli
normal_video_files = {}
for i = 317:317%1:size(files,1)
    %reading eeg_data
    cd /home/evgeny/lab/ann
    markers = readtable(files(i).name, 'filetype', 'text');
    markers = table2array(markers);
    ST = [11,12,21,22,211,212,221,222]; %stimuli
    RS = [101,104]; %responses
    FB = [85,88,89,255]; % feedback
    %opening video_data files
    [path, filename, ext] = fileparts(files(i).name);
    k = strfind(filename, '_') %здесь просто составляем имена необходимых файлов
    folder_name = filename(1:k(1)-1);
    folder_name = ['../clean_data/',folder_name];
    video_file_name = [filename,'_video_data.mat'];
    try
        cd (folder_name);
        load(video_file_name, 'stim_timecourse', 'timing');
    catch
        warning(['Video data not found, was searching for ',folder_name])
        continue
    end
    video_file_name 
    %all files ready
    
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
    
    'privet'
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
    
    %now checking from which stimulus the eeg recording started
    %3 different options - 50, 100 and 200 epochs
    %assuming error in time is less than 20 epochs
    len = length(stim_indices);
    if (30 <= len) && (len <= 50)
       first_recorded_stimulus = 50 - length(stim_indices) + 1; 
    elseif (80 <= len) && (len <= 100)
       first_recorded_stimulus = 100 - length(stim_indices) + 1;
    elseif (180 <= len) && (len <= 200)
        first_recorded_stimulus = 200 - length(stim_indices) + 1;
    end
    %вектор сделать 
    
    %finding timing of reactions on eeg
    rs_times_eeg = markers(rs_indices);
    %finding timing of stimuli on video and eeg 
    st_times_eeg = markers(stim_indices);
    st_times_vid = timing(stim_timecourse == 1)';
    %if their numbers don't match = some stimuli are lost
    if size(st_times_vid,1) ~= size(st_times_eeg,1)
        corrupt_video_files{end + 1} = video_file_name;
        continue
    end
    normal_video_files{end + 1} = video_file_name;

    %countin the timing difference vector
    difference = st_times_vid - st_times_eeg/1000;
    
    %creating correct stimuli and responses vectors in video timing
    st_timing = st_times_eeg/1000 + difference;
    rs_timing = rs_times_eeg/1000 + difference;

    %now creating rs_timecourse vector
    rs_timecourse = zeros(size(stim_timecourse));
    for j = 1:length(rs_timing)
        delta = timing - rs_timing(j);
        min_delta_id = find(abs(delta) == min(abs(delta)),1,'first');
        rs_timecourse(min_delta_id) = 1;
    end
    
    %save(video_file_name, 'first_recorded_stimulus', 'st_timing', 'rs_timing', 'rs_timecourse', '-append')
end


'thats it'
cd /home/evgeny/lab/task
corrupt_video_files = corrupt_video_files'
normal_video_files = normal_video_files'
%save('corrupt_files.mat', 'corrupt_video_files', '-mat')
%save('normal_files.mat', 'normal_video_files', '-mat')
'saved'
