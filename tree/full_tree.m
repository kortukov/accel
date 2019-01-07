cd /home/evgeny/lab/accel_data

files = dir('*data.mat');

full_data_matrix = [];
full_test_matrix = [];
for i = 1:length(files)
    if ((i>=76)&&(i<=78))||((i>=148)&&(i<=150))
        continue
    end
    
    load(files(i).name);
    if(data.session ~= 0)
        clear('data');
        continue
    end
    if ~isfield(data.data_matrix, 'epoch_labels')
        clear('data');
        continue
    end
    
    
    %concatenating 0 and 1 session train on them
    if data.session == 0
        other_file_name = [data.subject '_1_accel_data.mat'];
    end
    try 
        other_data = load(other_file_name); 
        other_data = other_data.data;
        data.data_matrix = [data.data_matrix,other_data.data_matrix];
    catch
        warning('unable to load 1 session');
    end
    other_file_name = [data.subject '_2_accel_data.mat'];
    try 
        other_data = load(other_file_name); 
        other_data = other_data.data;
        data.data_matrix = [data.data_matrix,other_data.data_matrix];
    catch
        warning('unable to load 2 session');
    end
    other_file_name = [data.subject '_3_accel_data.mat'];
    try 
        other_data = load(other_file_name); 
        other_data = other_data.data;
        data.data_matrix = [data.data_matrix,other_data.data_matrix];
    catch
        warning('unable to load 3 session');
    end

    if isfield(data, 'optimal_threshold')
        threshold = data.optimal_threshold;
    else
        threshold = 7.00;
    end
    n_hustles = 0;
    n_nonhustles = 0;
    for j = 1:length(data.data_matrix)
        data.data_matrix(j).threshold = threshold;
        data.data_matrix(j).subject = data.subject;
        n_hustles = n_hustles + data.data_matrix(j).epoch_labels;
        n_nonhustles = n_nonhustles + ~data.data_matrix(j).epoch_labels;
    end
    
    part = 0;
    n_hold_hustles = floor(part*n_hustles);
    n_hold_nonhustles = floor(part*n_nonhustles);
    
    rand_matrix = data.data_matrix(randperm(length(data.data_matrix)));
    test_matrix = [];
    h_counter = 0; nh_counter = 0;
    for j = 1:length(rand_matrix)
        if rand_matrix(j).epoch_labels == 1 && h_counter < n_hold_hustles
            h_counter = h_counter + 1;
            test_matrix = [test_matrix,rand_matrix(j)];
            rand_matrix(j) = [];
        elseif rand_matrix(j).epoch_labels == 0 && nh_counter < n_hold_nonhustles
            nh_counter = nh_counter + 1;
            test_matrix = [test_matrix,rand_matrix(j)];
            rand_matrix(j) = [];
        end
        if h_counter == n_hold_hustles && nh_counter == n_hold_nonhustles
            break;
        end
        
    end
    full_test_matrix = [full_test_matrix,test_matrix];
    full_data_matrix = [full_data_matrix,rand_matrix];
end

% load('full_data.mat');



% ======== feature extraction ========
train_X = feature_extraction(full_data_matrix);
train_Y = label_extraction(full_data_matrix);
% ======== model creation ========
tree = fitctree(train_X, train_Y);

% test_X = feature_extraction(full_test_matrix);
% test_Y = label_extraction(full_test_matrix);
% test_L = loss(tree, test_X, test_Y)







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
        %optimal threshold
%         if length(abs(diff5(abs(diff5) > data_matrix(j).threshold))) < 3  X.crit_opt(j) = 0;
%         else X.crit_opt(j) = length(findpeaks(abs(diff5(abs(diff5) > data_matrix(j).threshold))));
%         end 
        %critical_time
%         if length(find(abs(diff5) > 4)) == 0
%             X.critical_time_low(j) = 0;
%         else
%             first_critical_index = find(abs(diff5) > 4,1);
%             first_critical_point = indices(first_critical_index - 1);%-1 because indices start with 6 and not 1
%             X.critical_time_low(j) = data_matrix(j).time(end) - data_matrix(j).time(first_critical_point);
%         end
%         if length(find(abs(diff5) > 7)) == 0
%             X.critical_time_med(j) = 0;
%         else
%             first_critical_index = find(abs(diff5) > 7,1);
%             first_critical_point = indices(first_critical_index - 1);%-1 because indices start with 6 and not 1
%             X.critical_time_med(j) = data_matrix(j).time(end) - data_matrix(j).time(first_critical_point);
%         end
%         if length(find(abs(diff5) > 13)) == 0
%             X.critical_time_high(j) = 0;
%         else
%             first_critical_index = find(abs(diff5) > 13,1);
%             first_critical_point = indices(first_critical_index - 1);%-1 because indices start with 6 and not 1
%             X.critical_time_high(j) = data_matrix(j).time(end) - data_matrix(j).time(first_critical_point);
%         end
%         if length(find(abs(diff5) > data_matrix(j).threshold)) == 0
%             X.critical_time(j) = 0;
%         else
%             first_critical_index = find(abs(diff5) > data_matrix(j).threshold,1);
%             first_critical_point = indices(first_critical_index - 1);%-1 because indices start with 6 and not 1
%             X.critical_time(j) = data_matrix(j).time(end) - data_matrix(j).time(first_critical_point);
%         end
        
        
        spectre = abs(fft(data_matrix(j).accel_diff))/(length(data_matrix(j).accel_diff));
        spectre = spectre(1:floor(end/2));
        if isempty(find(spectre == max(spectre),1))
            X.harmonic(j) = NaN;
        else
            X.harmonic(j) = find(spectre == max(spectre),1);
        end
    end

end

function [Y] = label_extraction(data_matrix)
    Y = [];
    for j = 1:length(data_matrix)
        Y(j) = data_matrix(j).epoch_labels;
    end
    Y = Y';
end

