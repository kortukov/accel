cd /home/evgeny/lab/accel_data

files = dir('*data.mat');

check_table{1,1} = 'subject';
check_table{1,2} = 'ratio';
l = 0;
for i = 1:length(files)
    
    if ((i>=76)&&(i<=78))||((i>=148)&&(i<=150))
        continue
    end
    load(files(i).name);
    if ~isfield(data.data_matrix, 'epoch_labels')
        clear('data');
        continue
    end
    
    ratio = data.number_of_hustles / length(data.data_matrix);
    l = l + 1;
    check_table{l,1} = files(i).name;
    check_table{l,2} = ratio;
end

cd /home/evgeny/lab/task/tree