load('corrupt_files.mat', '-mat')
load('clean_files.mat', '-mat')
% load('okay_files.mat', '-mat')
% load('dirty_files.mat', '-mat')

files = clean_video_files;

bad_coord_files = {}
for i = 1:length(files)
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
        load(video_file_name, 'cent_cords', 'fing_cords', 'timing');
    catch
        warning(['Video data not found, was searching for ',folder_name])
        continue
    end
    video_file_name 
    clear('path','filename','ext','k','folder_name')
    %all files ready

    %correcting the coordinate difference 
    try
        dif = (cent_cords - fing_cords)./max(cent_cords - fing_cords);
    catch
        bad_coord_files{end + 1} = video_file_name;
    end
    olddif = dif;
%     
%     correction = isoutlier(dif,'movmedian', length(dif)/4);
%     correction(:,1) = bitor(correction(:,1),correction(:,2));
%     correction(:,2) = correction(:,1);
%     dif(find(correction)) = NaN;
%     
%     dif = dif - nanmean(dif);
    
    %new corrected pca
    M = pca(dif);
    principal_components = dif * M;
    
    save(video_file_name, 'principal_components', '-append');
    'saved'
    copyfile(video_file_name, '/home/evgeny/lab/clean_files/');
    
end

cd /home/evgeny/lab/task