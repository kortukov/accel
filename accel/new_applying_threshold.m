%This is the script to write feature tables for EEG-analysis
%here we construct the binary vector hustle and vector of 
%times when the hustle started - hustle_init

cd /home/evgeny/lab/accel_data
files = dir('*data.mat');
needed = [];
filename = {};
for i = 1: length(files)
    filename{i} = files(i).name;
end
filename = string(filename);
needed = contains(filename, ["4", "5", "6", "7"]);
needed = logical(needed);
files = files(needed);

%numbers of files with labels

%mean threshold was computed before
mean_threshold = 7.00;
mean_time = 400;
for i = 29%1:length(files)
    cd /home/evgeny/lab/accel_data
    load(files(i).name)
    
    %individual thresholds and cutoff times are stored in accel_data of 1st sessions
    labeled_file_name = [data.subject '_1_accel_data.mat'];

    try 
        labeled_data = load(labeled_file_name);
        threshold = labeled_data.data.optimal_threshold;
        time = labeled_data.data.optimal_time;

    catch
        warning('Even the 1st session doesn`t have labels');
        threshold = mean_threshold;
        time = mean_time;
    end
    clear('labeled_data')
    
    
    
    
    critical_times = [];
    critical_epochs = [];
    non_critical_epochs = [];
    %number_of_labeled = 0;
    %number_of_unlabeled = 0;
    for j = 1:length(data.data_matrix)
        indices = [6:5:length(data.data_matrix(j).accel)];
        data.data_matrix(j).diff5 = zeros(length(indices) + 1, 1);
        data.data_matrix(j).diff5(1) = 0;
        data.data_matrix(j).diff5(2:end) = data.data_matrix(j).accel(indices) - data.data_matrix(j).accel(indices - 5);

        
        if length(find(abs(data.data_matrix(j).diff5) > threshold)) == 0
            data.data_matrix(j).critical = 0;
            data.data_matrix(j).critical_time = 0;
             data.data_matrix(j).hustle_init = 0;
            non_critical_epochs = [non_critical_epochs, data.data_matrix(j).num];
        else 
            data.data_matrix(j).critical = 1;
            %counting the time from first diff5 > critical to end
            first_critical_index = find(abs(data.data_matrix(j).diff5) > threshold,1);
            first_critical_point = indices(first_critical_index - 1);%-1 because indices start with 6 and not 1
            data.data_matrix(j).hustle_init = first_critical_point - 20;
            critical_time = data.data_matrix(j).time(end) - data.data_matrix(j).time(first_critical_point);
            if critical_time < time
                data.data_matrix(j).critical = 0;
                data.data_matrix(j).critical_time = 0;
                 data.data_matrix(j).hustle_init = 0;
                continue
            end
            data.data_matrix(j).critical_time = critical_time;
            critical_epochs = [critical_epochs, data.data_matrix(j).num];
            
        end
        critical_times = [critical_times; data.data_matrix(j).critical_time];  
    end
    
    table_name = [data.subject '_' num2str(data.session) '.txt'];
    
    %forming the column vector
    hustle = [];
    hustle_init = [];
    for j = 1:length(data.data_matrix)
        hustle = [hustle; data.data_matrix(j).critical];
        hustle_init = [hustle_init; data.data_matrix(j).hustle_init];
    end
    cd /home/evgeny/lab/feat_tables_global
    try
        table = readtable(table_name);
    catch
        continue; 
    end
    table.hustle = hustle;
    table.hustle_init = hustle_init;
    
    %writetable(table,table_name, 'Delimiter','\t') 
    
    
end