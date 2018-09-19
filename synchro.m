%Первый вариант алгоритма синхронизации
%Рассчитываем по всем стимулам вектор разницы в тайминге ээг и видео
%Не работает на файлах с выпадающими стимулам
cd /home/evgeny/lab/ann
files = dir('*.ann')

corrupt_video_files = {} %Имена видео файлов, в которых потеряны стимулы
for i = 1:size(files,1)
    %считываем разметку даных 
    cd /home/evgeny/lab/ann
    markers = readtable(files(i).name, 'filetype', 'text');
    markers = table2array(markers);
    ST = [11,12,21,22,211,212,221,222, 255]; 
    RS = [101,104];
    
    %теперь открываем видео-файлы
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
        continue2
    end
    video_file_name
    %смотрим когда были стимулы на ээг
    %попутно помечаем эпохи где не было реакций
    %тут есть защита от нескольких реакций в одной эпохе
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
    save(video_file_name, 'no_reaction_epochs', '-append');
    
    %смотрим когда были стимулы на видео
    st_times_vid = [];
    for j = 1:size(stim_timecourse,1)
         if stim_timecourse(j) == 1
             st_times_vid = [st_times_vid; timing(j)];
         end
    end   
    
    if size(st_times_vid,1) ~= size(st_times_eeg,1)
        corrupt_video_files{end + 1} = video_file_name;
        continue
    end
    
    %здесь считаем вектор разницы. К этому моменту
    %должно быть гарантировано корректное совпадение стимулов
    %на ээг и видео, иначе пишем плохой файл в лог и идём дальше
    difference = zeros(size(st_times_vid));
    for j = 1:size(st_times_vid) 
        difference(j) = st_times_vid(j) - st_times_eeg(j)/1000;
    end
    
    %составляем векторы тайминга стимулов и реакций
    st_timing = zeros(size(st_times_eeg));
    rs_timing = zeros(size(rs_times_eeg));
    for j = 1:size(st_times_eeg)
       st_timing(j) = st_times_eeg(j)/1000 + difference(j);
       if ~(ismember(j, no_reaction_epochs))
           rs_timing(j) = rs_times_eeg(j)/1000 + difference(j);
       end
    end 
    save(video_file_name, 'st_timing', 'rs_timing', '-append')
end


'thats it'
cd /home/evgeny/lab/task
save('corrupt_files.mat', 'corrupt_video_files', '-mat')
'saved'
