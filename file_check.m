load('corrupt_files.mat', '-mat')

files = transpose(corrupt_video_files);

for i = 2:2 %size(files,1) 
    cd /home/evgeny/lab/task
    [path, filename, ext] = fileparts(files{i});
    k = strfind(filename, '_') %здесь просто составляем имена необходимых файлов
    folder_name = filename(1:k(1)-1);
    folder_name = ['../clean_data/',folder_name];
    video_file_name = files{i}
    try
        cd (folder_name);
        load(video_file_name, 'stim_timecourse', 'timing');
    catch
        warning(['Video data not found, was searching for ',folder_name])
        continue
    end
    
    ann_file_name = [filename(1:k(2)-1),'.ann'];
    try
        cd /home/evgeny/lab/ann
        markers = readtable(ann_file_name, 'filetype', 'text');
        markers = table2array(markers);
    catch
        warning(['ann file not found ', ann_file_name])
        continue
    end
    ST = [11,12,21,22,211,212,221,222, 255]; 
    RS = [101,104];
    no_reaction_epochs = [];
    st_times_eeg = [];
    rs_times_eeg = [];
    j = 1;
    while j < size(markers,1) %проходимся по всем строкам файла разметки
        if ismember(markers(j,3),ST) %увидели стимул 
            st_times_eeg = [st_times_eeg; markers(j,1)]; 
            k = j + 1;
            reaction = 0;
            while not(ismember(markers(k, 3), ST))
                if ismember(markers(k,3), RS)
                    reaction = reaction + 1;
                    if reaction == 1
                        rs_times_eeg = [rs_times_eeg; markers(k,1)];
                    end
                end
                k = k + 1;
            end
            if reaction == 0 %если не было реакции то пишем нолик в тайминг
                rs_times_eeg = [rs_times_eeg; 0]
                no_reaction_epochs = [no_reaction_epochs; size(rs_times_eeg, 1)]
            end
            j = k - 1; %чтобы не делать лишних итераций
        end
        j = j + 1;
    end
    
    %смотрим когда были стимулы на видео
    st_times_vid = [];
    for j = 1:size(stim_timecourse,1)
         if stim_timecourse(j) == 1
             st_times_vid = [st_times_vid; timing(j)];
         end
    end   
    
   
end

cd /home/evgeny/lab/task