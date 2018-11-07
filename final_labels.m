%Здесь делаю итоговую разметку по эпохам - есть ли метания
load('corrupt_files.mat', '-mat')
cd /home/evgeny/lab/hustle_01
files = dir('*txt')

lost_hustle_files = {}
for i = 1:size(files,1)
    cd /home/evgeny/lab/hustle_01
    [path, filename, ext] = fileparts(files(i).name);
    k = strfind(filename, '_'); %здесь просто составляем имена необходимых файлов
    folder_name = filename(1:k(1)-1); 
    folder_name = ['../clean_data/',folder_name];
    video_file_name = [filename(1:k(2)-1),'_video_data.mat'];
    if ismember(video_file_name, corrupt_video_files)
        warning('Corrupt video file')
        video_file_name
        continue
    end
    try
        cd (folder_name);
        load(video_file_name,'st_timing', 'rs_timing','stim_timecourse','rs_timecourse','hustle_timecourse', 'hustle_timing', 'timing', 'cent_cords', 'fing_cords', 'first_recorded_stimulus');
    catch
        warning(['Video data not found, was searching for ',folder_name])
        continue
    end
    video_file_name
    
    hustle_timing = transpose(timing(hustle_timing));
    j = 1; k = 1;
    epoch_labels = zeros(size(st_timing));
    while j <= length(st_timing) & k <= length(hustle_timing)
        if st_timing(j) <= hustle_timing(k)
            if rs_timing(j) < hustle_timing(k)
                j = j+1;
            else 
                epoch_labels(j) = 1;
                k = k+1;
            end
                
        else
            k = k+1;
        end
    end
    
    %fixing the video starting from 7th stimulus
    if video_file_name == 'manuhina_0_video_data.mat'
        epoch_labels = [zeros(first_recorded_stimulus-1,1);epoch_labels];
    end
    
    lost_hustles = length(hustle_timing) - length(find(epoch_labels));
    if lost_hustles > 10
        lost_hustle_files{end+1} = video_file_name;
    end
    save(video_file_name, 'epoch_labels', '-append');
end

cd /home/evgeny/lab/task

lost_hustle_files = lost_hustle_files';
%save('lost_hustle_files.mat', 'lost_hustle_files', '-mat');