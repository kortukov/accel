load('corrupt_files.mat', '-mat')
load('clean_files.mat', '-mat')
% load('okay_files.mat', '-mat')
% load('dirty_files.mat', '-mat')

files = clean_video_files;

bad_coord_files = {}
for i = 4:4%length(files)
    %opening video_data files
    [path, filename, ext] = fileparts(files{i});
    k = strfind(filename, '_') %здесь просто составляем имена необходимых файлов
    folder_name = filename(1:k(1)-1);
    folder_name = ['/home/evgeny/lab/clean_data/',folder_name];
    video_file_name = [filename,'.mat'];
    if ismember(video_file_name, corrupt_video_files)
        warning('Corrupt video file')
        video_file_name
        continue
    end
    try
        cd (folder_name);
        load(video_file_name, 'cent_cords', 'fing_cords', 'timing', 'stim_timecourse', 'rs_timecourse', 'hustle_timecourse','principal_components');
    catch
        warning(['Video data not found, was searching for ',folder_name])
        continue
    end
    video_file_name 
    clear('path','filename','ext','k','folder_name')
    %all files ready
    
    %first - finding the difference between cords and timing so that
    %visualisation is correct
    delta = length(timing) - length(cent_cords);
    left = floor(delta/2);
    right = ceil(delta/2);
    
    figure('Name', 'Clean data visualisation')
    subplot(3,1,1)
    plot(timing(1 + left :end-right), principal_components(:,1)), hold on
    stem(timing,stim_timecourse*1.04)
    stem(timing,rs_timecourse)
    stem(timing, hustle_timecourse*1.1), hold off
    legend('dif','Stimuli', 'Responses', 'Hustles')

    
end

cd /home/evgeny/lab/task