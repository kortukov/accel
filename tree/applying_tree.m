
load('full_tree.mat', '-mat')

cd /home/evgeny/lab/accel_data
files = dir('*data.mat');
%numbers of files with labels

needed = [];
filename = {};
for i = 1: length(files)
    filename{i} = files(i).name;
end
filename = string(filename);
needed = contains(filename, ["4", "5", "6", "7"]);
needed = logical(needed);
files = files(needed);

for i = 5%1:length(files)
    cd /home/evgeny/lab/accel_data
    load(files(i).name);
    X = feature_extraction(data.data_matrix);
    Y_hat = predict(tree, X);
   
    
    cd /home/evgeny/lab/feat_tables_global
    table_name = [data.subject '_' num2str(data.session) '.txt'];
    try
        table = readtable(table_name);
    catch
        
        continue; 
    end
    table.hustle = Y_hat;
    writetable(table,table_name, 'Delimiter','\t')   
    
end

cd /home/evgeny/lab/task/tree

function [X] = feature_extraction(data_matrix)
    X = table;
    for j = 1:length(data_matrix)
        X.length(j) = length(data_matrix(j).accel); 
        [maximum, ind] = max(data_matrix(j).accel);
        X.max_amp(j) = maximum;
        X.max_amp_index(j) = ind;
        %counting the diff5
        indices = [6:5:length(data_matrix(j).accel)];
        diff5 = zeros(length(indices) + 1, 1);
        diff5(1) = 0;
        diff5(2:end) = data_matrix(j).accel(indices) - data_matrix(j).accel(indices - 5);
        if length(abs(diff5(abs(diff5) > 4))) < 3  X.crit_low(j) = 0;
        else X.crit_low(j) = length(findpeaks(abs(diff5(abs(diff5) > 4))));
        end
        if length(abs(diff5(abs(diff5) > 7))) < 3  X.crit_med(j) = 0;
        else X.crit_med(j) = length(findpeaks(abs(diff5(abs(diff5) > 7))));
        end
        if length(abs(diff5(abs(diff5) > 13))) < 3  X.crit_high(j) = 0;
        else X.crit_high(j) = length(findpeaks(abs(diff5(abs(diff5) > 13))));
        end 
    end

end