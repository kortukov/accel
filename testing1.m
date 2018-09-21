%Второй вариант алгоритма синхронизации
%рассчитываем разницу между сигналами по ээг, пересчитываем её
%в тайминг видео и используем только первый стимул

%Неустойчив к отсутствию реакций
cd /home/evgeny/lab/ann
files = dir('*.ann');

for i = 2:2 %1:size(files,1) %bagina_1 = 32
    cd /home/evgeny/lab/ann
    markers = readtable(files(i).name, 'filetype', 'text');
    markers = table2array(markers);
    ST = [11,12,21,22,211,212,221,222]; %ещё 255 - конец записи
    RS = [101,104];
    
    %алгоритм пересчёта времени из ээг в видео
    %считаем расстояния между стимулами на ээг
    %переводим их в отсчёты на видео
    %с помощью этих расстояний и первого стимула на видео
    %рассчитаем правильные времена всех стимулов и реакций на видео
    eeg_stims = [];
    for j = 1:size(markers,1)
        if ismember(markers(j,3), ST) %ищем стимулы на ээг 
            eeg_stims = [eeg_stims;markers(j,1)];
        end
    end
    eeg_stim_diff = zeros(size(eeg_stims));
    for j = 2:size(eeg_stim_diff)
        eeg_stim_diff(j) = eeg_stims(j) - eeg_stims(j-1);
    end
    video_stim_diff = arrayfun(@(x) fix(x*30/1000), eeg_stim_diff);
    %на камере за то же время проходит 30/1000 от отсчётов ээг
    
    %считаем вектор разниц между реакциями
    %первый элемент это расстояние от первого стимула до первой реакции
    eeg_reacts = [];
    for j = 1:size(markers,1)
        if ismember(markers(j,3), RS)
            eeg_reacts = [eeg_reacts; markers(j,1)];
        end
    end
    eeg_react_diff = zeros(size(eeg_reacts));
    eeg_react_diff(1) = eeg_reacts(1) - eeg_stims(1);
    for j = 2:size(eeg_react_diff)
        eeg_react_diff(j) = eeg_reacts(j) - eeg_reacts(j-1);
    end
    video_react_diff = arrayfun(@(x) fix(x*30/1000), eeg_react_diff);
    
    %теперь открываем видео-файлы
    [path, filename, ext] = fileparts(files(i).name);
    k = strfind(filename, '_'); %здесь просто составляем имена необходимых файлов
    folder_name = filename(1:k(1)-1);
    folder_name = ['../clean_data/',folder_name];
    video_file_name = [filename,'_video_data.mat'];
    try
        cd (folder_name)
        load(video_file_name, 'stim_timecourse', 'timing', 'hustle_timing')
    catch
        warning(['Video data not found, was searching for ',folder_name])
        continue
    end
    
    %проверочный массив стимулов
    video_stimuli_check = [];
    for j = 1:size(stim_timecourse)
        if stim_timecourse(j) == 1
            video_stimuli_check = [video_stimuli_check;j];
        end     
    end 
    first_st = video_stimuli_check(1);
    %рассчитанные стимулы
    video_stimuli_eeg = zeros(size(video_stim_diff))
    video_stimuli_eeg(1) = first_st
    for j = 2:size(video_stimuli_eeg)
        video_stimuli_eeg(j) = video_stimuli_eeg(j-1) + video_stim_diff(j);
    end
    
    %рассчитанные реакции
    video_reactions_eeg = zeros(size(video_react_diff))
    video_reactions_eeg(1) = first_st + video_react_diff(1)
    for j = 2:size(video_reactions_eeg)
        video_reactions_eeg(j) = video_reactions_eeg(j-1) + video_react_diff(j);
    end
    
    
    video_stimuli_timing = transpose(timing(video_stimuli_eeg));
    video_reactions_timing = transpose(timing(video_reactions_eeg));
end
cd /home/evgeny/lab/task