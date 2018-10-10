%Здесь делаю итоговую разметку по эпохам - есть ли метания
load('corrupt_files.mat', '-mat')
cd /home/evgeny/lab/hustle_01
files = dir('*txt')

for i = 20:20%size(files,1)
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
        load(video_file_name, 'st_timing', 'rs_timing','stim_timecourse','rs_timecourse','hustle_timecourse', 'hustle_timing', 'timing');
    catch
        warning(['Video data not found, was searching for ',folder_name])
        continue
    end
    video_file_name
    
    stem(stim_timecourse), hold on
    stem(rs_timecourse)
    stem(hustle_timecourse, 'g'), hold off
    
    
    
    error('stop here')
    cd /home/evgeny/lab/task
    hustle_timing = transpose(timing(hustle_timing));
    j = 1, k = 1;
    epoch_labels = zeros(size(st_timing))
    while j <= size(st_timing,1) & k <= size(hustle_timing,1)
        if st_timing(j) < hustle_timing(k)
            if rs_timing(j) < hustle_timing(k)
                epoch_labels(j) = 0;
                j = j+1;
            else 
                epoch_labels(j) = 1;
                j = j+1;
                k = k+1;
            end
                
        else
            j = j+1;
            k = k+1;
        end
    end
    
end



cd /home/evgeny/lab/task