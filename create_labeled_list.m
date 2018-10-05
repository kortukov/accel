load('corrupt_files.mat', '-mat');
corrupt_video_files = transpose(corrupt_video_files);

cd /home/evgeny/lab/hustle_01
files = dir('*.txt');

labeled_video_files = {}
for i = 1:size(files,1)
    k = strfind(files(i).name, '_'); %здесь просто составляем имена необходимых файлов
    folder_name = files(i).name(1:k(1)-1);
    folder_name = ['../clean_data/',folder_name];
    video_file_name = [files(i).name(1:k(2)-1),'_video_data.mat'];
    if ismember(video_file_name, corrupt_video_files)
        continue
    end
    labeled_video_files{end + 1} = video_file_name;
end
labeled_video_files = transpose(labeled_video_files);
cd /home/evgeny/lab/task
save('labeled_files.mat', '-mat', 'labeled_video_files')