cd ../hustle_01
files = dir('*.txt')

different_coding_files = {};

for i = 1:size(files,1)
    files(i).name
    
    try
        hustle_times = dlmread(files(i).name, ',',1,0)
    catch
        warning('different coding of file')  
        different_coding_files{end + 1}
        
        fileID = fopen(files(i).name); 
        
        text_scan = textscan(fileID,'%s%s', 'Delimiter',',');
        fclose(fileID);
        text_scan = text_scan{1,1}(2:end,:);

        hustle_times = [];
        for k = 1:length(text_scan)
            hustle_times(k,1) = str2double(text_scan{k,1});
        end
        
    end
    
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
    %and also hustle_timing
    if size(timing,2) == 1
        timing = timing';
    end
    
    hustle_timecourse = zeros(size(stim_timecourse));
    hustle_timing = [];
    for j = 1:length(hustle_times)
        delta = timing - hustle_times(j);
        min_delta_id = find(abs(delta) == min(abs(delta)),1,'first');
        hustle_timecourse(min_delta_id) = 1;
        hustle_timing = [hustle_timing; min_delta_id];
    end
    
    save(video_file_name, 'hustle_timing', 'hustle_timecourse', '-append')
    
    cd /home/evgeny/lab/hustle_01
end
cd /home/evgeny/lab/task
'done'