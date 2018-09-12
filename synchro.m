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
        load(video_file_name, 'stim_timecourse', 'timing', 'hustle_timing')
    catch
        warning(['Video data not found, was searching for ',folder_name])
        continue
    end
    
    %считаем разницу в показаниях времени камеры и ээг
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
     
    %составляем векторы тайминга стимулов и реакций
    st_timing = [], rs_timing = [], k = 1
    for j = 1:size(markers,1)
        if ismember(markers(j,3), ST)
            st_timing = [st_timing; markers(j,1)/1000 + difference(k)]
        elseif ismember(markers(j,3), RS)
            rs_timing = [rs_timing; markers(j,1)/1000 + difference(k)]
            k = k+1
        end
    end 
    save(video_file_name, 'st_timing', 'rs_timing')
end



cd /home/evgeny/lab/task

