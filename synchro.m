cd /home/evgeny/lab/ann
files = dir('*.ann')

for i = 4:4 %size(files,1)
    markers = readtable(files(i).name, 'filetype', 'text')
    markers = table2array(markers)
    ST = [11,12,21,22,211,212,221,222]; %255 - конец записи
    RS = [101,104];
    j = 1
    while ~(ismember(markers(j,3), ST)) %ищем первый стимул
        j = j + 1
    end
    first_st = markers(j,1)
    
    %теперь открываем видео-файлы
    [path, filename, ext] = fileparts(files(i).name)
    k = strfind(filename, '_') %здесь просто составляем имена необходимых файлов
    folder_name = filename(1:k(1)-1)
    folder_name = ['../clean_data/',folder_name]
    video_file_name = [filename,'_video_data.mat']
    try
        cd (folder_name)
    catch
        warning(['Video data not found, was searching for ',folder_name])
        continue
    end
    load(video_file_name, 'stim_timecourse', 'timing', 'hustle_timing')
    %debug - counting differences
    st_times_vid = []
    for j = 1:size(stim_timecourse,1)
         if stim_timecourse(j) == 1
             st_times_vid = [st_times_vid; timing(j)]
         end
    end
    st_times_eeg = []
    for j = 1:size(markers,1)
        if ismember(markers(j,3), ST)
            st_times_eeg = [st_times_eeg; markers(j,1)]
        end
    end
    
    difference = zeros(size(st_times_vid))
    for j = 1:size(st_times_vid)
        difference(j) = st_times_vid(j) - st_times_eeg(j)/1000
    end
    
    
    error()
    %ищем первый стимул на видео
    j = 1
    while stim_timecourse(j) == 0
        j = j+1;
    end
    video_first_st = timing(j)
    %считаем разницу для синхронизации
    difference = video_first_st - (first_st/1000)
    
    
    st_timing = [], rs_timing = []
    for j = 1:size(markers,1)
        if ismember(markers(j,3), ST)
            st_timing = [st_timing; markers(j,1)/1000 + difference]
        elseif ismember(markers(j,3), RS)
            rs_timing = [rs_timing; markers(j,1)/1000 + difference]
        end
    end
    for j = 1:size(hustle_timing)
        hustle_timing(j) = timing(hustle_timing(j))
    end
    
    test_st_timing = []
    for j = 1:size(stim_timecourse,1)
        if stim_timecourse(j) == 1
            test_st_timing = [test_st_timing; timing(j)]
        end
    end
    
end



cd /home/evgeny/lab/task

