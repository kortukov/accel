cd /home/evgeny/lab/accel_data

files = dir('*data.mat');

full_data_matrix = [];
for i = 1:length(files)
    if ((i>=76)&&(i<=78))||((i>=148)&&(i<=150))
        continue
    end
    
    load(files(i).name);
    if(data.session ~= 0) && (data.session ~=1)
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
    elseif data.session == 1
        other_file_name = [data.subject '_0_accel_data.mat'];
    end
    try 
        other_data = load(other_file_name); 
        other_data = other_data.data;
        data.data_matrix = [data.data_matrix,other_data.data_matrix];
    catch
        warning('unable to load 1 session');
    end
    clear ('other_data');
    
    
    
    if isfield(data, 'optimal_threshold')
        threshold = data.optimal_threshold;
    else
        threshold = 7.00;
    end
    for j = 1:length(data.data_matrix)
        data.data_matrix(j).threshold = threshold;
    end
    
    full_data_matrix = [full_data_matrix,data.data_matrix];
end


% ======== feature extraction ========
train_X = feature_extraction(full_data_matrix);
train_Y = label_extraction(full_data_matrix);
% ======== model creation ========
% tree = fitctree(train_X, train_Y);
% 
% train_L = loss(tree, train_X, train_Y);
% train_Y_pred = predict(tree, train_X);
% 
% train_accuracy = sum(train_Y_pred == train_Y)/length(full_data_matrix);

B = mnrfit(train_X, train_Y);


error();



validation_table{1,1} = 'subject';
validation_table{1,2} = 'train_loss';
validation_table{1,3} = 'train_accuracy';
validation_table{1,4} = 'TEST:';
validation_table{1,5} = 'test_loss';
validation_table{1,6} = 'test_accuracy';
validation_table{1,7} = 'test_session';
m = 1;    
    
for i = 1:length(files)
    % ======== testing on the second or third session
    if ((i>=76)&&(i<=78))||((i>=148)&&(i<=150))
        continue
    end
    
    load(files(i).name);
    if(data.session ~= 0) && (data.session ~=1)
        clear('data');
        continue
    end
    if ~isfield(data.data_matrix, 'epoch_labels')
        clear('data');
        continue
    end
    if isfield(data, 'optimal_threshold')
        threshold = data.optimal_threshold;
    else
        threshold = 7.00;
    end
    
    try
        test_filename = [data.subject '_2_accel_data.mat'];
        test_data = load(test_filename);
        test_data = test_data.data
        test_session = test_data.session;
    catch 
        warning('Failed to load test data');
        continue
    end
    for j = 1:length(test_data.data_matrix)
        test_data.data_matrix(j).threshold = threshold;
    end
    
    test_X = feature_extraction(test_data.data_matrix);
    test_Y = label_extraction(test_data.data_matrix);
    
    test_L = loss(tree, test_X, test_Y);
    
    test_Y_pred = predict(tree, test_X);
    test_accuracy = sum(test_Y_pred == test_Y)/length(test_data.data_matrix);
    m = m + 1;
    validation_table{m,1} = files(i).name;
    validation_table{m,2} = train_L;
    validation_table{m,3} = train_accuracy;
    validation_table{m,4} = 'TEST:';
    validation_table{m,5} = test_L;
    validation_table{m,6} = test_accuracy;
    validation_table{m,7} = test_session;
    % ======== testing on the third session
    try
        test_filename = [data.subject '_3_accel_data.mat'];
        test_data = load(test_filename);
        test_data = test_data.data
        test_session = test_data.session;
    catch 
        warning('Failed to load test data');
        continue
    end
    for j = 1:length(test_data.data_matrix)
        test_data.data_matrix(j).threshold = threshold;
    end
    test_X = feature_extraction(test_data.data_matrix);
    test_Y = label_extraction(test_data.data_matrix);
    
    test_L = loss(tree, test_X, test_Y);
    
    test_Y_pred = predict(tree, test_X);
    test_accuracy = sum(test_Y_pred == test_Y)/length(test_data.data_matrix);
    m = m + 1;
    validation_table{m,1} = files(i).name;
    validation_table{m,2} = train_L;
    validation_table{m,3} = train_accuracy;
    validation_table{m,4} = 'TEST:';
    validation_table{m,5} = test_L;
    validation_table{m,6} = test_accuracy;
    validation_table{m,7} = test_session;
    
end

m = m+1;
validation_table{m,1} = ' MEAN: ';
validation_table{m,3} = mean(cell2mat(validation_table(2:end,3)))
validation_table{m,6} = mean(cell2mat(validation_table(2:end,6)))

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
        spectre = spectre(1:end/2);
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
