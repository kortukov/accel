%Здесь делаю итоговую разметку по эпохам - есть ли метания
load('corrupt_files.mat', '-mat')
cd /home/evgeny/lab/hustle_01
files = dir('*txt')

lost_hustle_files = {}
for i = 28:28%size(files,1)
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
        load(video_file_name, 'principal_components','st_timing', 'rs_timing','stim_timecourse','rs_timecourse','hustle_timecourse', 'hustle_timing', 'timing', 'cent_cords', 'fing_cords');
    catch
        warning(['Video data not found, was searching for ',folder_name])
        continue
    end
    video_file_name
    
    %first - finding the difference between cords and timing so that
    %visualisation is correct
    delta = length(timing) - length(cent_cords);
    left = floor(delta/2);
    right = ceil(delta/2);
    
    figure('Name', video_file_name)
    subplot(3,1,1)
    plot(timing(1 + left :end-right), cent_cords(:,1)), hold on
    plot(timing(1 + left :end-right), fing_cords(:,1))
    stem(timing,stim_timecourse*max(fing_cords(:,1)))
    stem(timing,rs_timecourse*max(fing_cords(:,1)))
    stem(timing, hustle_timecourse*max(fing_cords(:,1))), hold off
    legend('cent','fing','Stimuli', 'Responses', 'Hustles')
    subplot(3,1,2)
    plot(timing(1 + left :end-right), cent_cords(:,2)), hold on
    plot(timing(1 + left :end-right), fing_cords(:,2))
    stem(timing,stim_timecourse*max(fing_cords(:,2)))
    stem(timing,rs_timecourse*max(fing_cords(:,2)))
    stem(timing, hustle_timecourse*max(fing_cords(:,2))), hold off
    legend('cent','fing','Stimuli', 'Responses', 'Hustles')
    
    
    
    
    hustle_timing = transpose(timing(hustle_timing));
    j = 1, k = 1;
    epoch_labels = zeros(size(st_timing))
    while j <= size(st_timing,1) & k <= size(hustle_timing,1)
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
    lost_hustles = length(hustle_timing) - length(find(epoch_labels));
    if lost_hustles > 10
        lost_hustle_files{end+1} = video_file_name;
    end
    
end

subplot(3,1,3)
stem(epoch_labels)


figure('Name', 'Principal component analysis')
subplot(3,1,1)
    plot(timing(1 + left :end-right), principal_components(:,1)), hold on
    stem(timing,stim_timecourse*1.04)
    stem(timing,rs_timecourse)
    stem(timing, hustle_timecourse*1.5), hold off
    legend('dif','Stimuli', 'Responses', 'Hustles')
subplot(3,1,2)
stem(epoch_labels)

dif = (cent_cords - fing_cords)./max(cent_cords - fing_cords);
subplot(3,1,3)
plot(timing(1+left :end-right), dif(:,1)); hold on
plot(timing(1+left: end-right), dif(:,2)); hold off

cd /home/evgeny/lab/task
lost_hustle_files = lost_hustle_files';
%save('lost_hustle_files.mat', 'lost_hustle_files', '-mat');