%script to load all optimal threshold from table to accel_data
cd /home/evgeny/lab/accel_data
files = dir('*_accel_data.mat');

load('table.mat', '-mat');
times = []
for i = 1:length(files)
    load(files(i).name);
    
    found_in_table = 0;
    for index = 1:length(table)
        if strcmp(table{index,1},files(i).name)
            found_in_table = index;
        end
    end
    
    if found_in_table == 0
        warning('no thresholds found');
        continue
    else
        index = found_in_table;
    end
        
    data.optimal_threshold = table{index,7};
    data.optimal_time = table{index,8};
    data.training_fpr_tpr = table{index,6};
    data.old_threshold = table{index,4};
    data.first_fpr_tpr = table{index,3};
    times(end+1) = data.optimal_time;
    save(files(i).name, 'data');
end


hist(times, 0:10:500);
cd /home/evgeny/lab/task/accel