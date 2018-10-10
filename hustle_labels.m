cd ../hustle_01
files = dir('*.txt')


for i = 1:size(files,1)
    files(i).name
    hustle_times = dlmread(files(i).name, ',',1,0)
    hustle_times = hustle_times(:,1);
    for j = 1:size(hustle_times,1)
        hustle_times(j) = 60*(fix(hustle_times(j))) + 100*(hustle_times(j) - fix(hustle_times(j)));
    end %translated to seconds
    
    
    %now we got times in seconds when there were hustles
    %now we put them into video_dat
    k = strfind(files(i).name, '_') %making filenames
    folder_name = files(i).name(1:k(1)-1)
    folder_name = ['../clean_data/',folder_name]
    video_file_name = [files(i).name(1:k(2)-1),'_video_data.mat']
    try
        cd (folder_name)
        load(video_file_name, '-mat')
    catch
        warning(['Video data not found, was searching for ',folder_name])
        continue
    end
    %creating hustle timecourse binary vector
    %with ones in those indexes when there were hustles
    hustle_timecourse = zeros(size(stim_timecourse));
    
    %another option - hustle_timing vector with frames with hustles
    hustle_timing = []
    j = 1;
    k = 1;
    while (j <= size(hustle_times,1) ) & (k <= size(timing,2))
        %absarr = [absarr, abs(timing(k) - hustle_times(j))];
        if hustle_times(j) - timing(k) > 0.05
            k = k+1;
        elseif timing(k) - hustle_times(j) > 0.05
            j = j + 1
        else
            hustle_timecourse(k) = 1;
            hustle_timing = [hustle_timing; k];
            j = j+1;
            k = k+1;
        end
    end
    save(video_file_name, 'hustle_timing', 'hustle_timecourse', '-append')
    
    cd /home/evgeny/lab/hustle_01
end
cd /home/evgeny/lab/task
'done'