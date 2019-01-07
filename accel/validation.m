%This script is for validation of our classfier(found time and accel
%thresholds) on 2nd and 3rd sessions for those subject that do have labels;
cd /home/evgeny/lab/accel_data
files = dir('*_accel_data.mat');

validation_table{1,1} = 'subject';
validation_table{1,2} = 'old_first_fpr_tpr';
validation_table{1,3} = 'old_first_accuracy';
validation_table{1,4} = 'new_first_fpr_tpr';
validation_table{1,5} = 'new_first_accuracy';
validation_table{1,6} = 'old 23 fpr_tpr';
validation_table{1,7} = 'old 23 accuracy';
validation_table{1,8} = 'new 23 fpr_tpr';
validation_table{1,9} = 'new 23 accuracy';
validation_table{1,10} = 'optimal_time';
l = 2;

load('table.mat', '-mat');
for i = 1:length(files)
    load(files(i).name);
    if (data.session ~= 2) && (data.session ~= 3)
        warning('wrong session');
        clear('data');
        continue
    end
    if ~isfield(data.data_matrix, 'epoch_labels')
        warning('no labels');
        clear('data');
        continue
    end
    
    %the 2nd or 3rd session is correct, starting validation
    labeled_file_name = [data.subject '_1_accel_data.mat'];
    
    try 
        labeled_data = load(labeled_file_name);
        optimal_threshold = labeled_data.data.optimal_threshold; 
        optimal_time = labeled_data.data.optimal_time;
        old_threshold = labeled_data.data.old_threshold;
        old_first_fpr_tpr = labeled_data.old_first_fpr_tpr;
        old_first_accuracy = labeled_data.old_first_accuracy;
        new_first_fpr_tpr = labeled_data.new_first_fpr_tpr;
        new_first_accuracy = labeled_data.new_first_accuracy;
    catch
        warning('Even the 1st session doesn`t have labels');
        continue
    end
    
   
    % ======= Using the old, unoptimal classifier =======
    critical_times = [];
    critical_epochs = [];
    non_critical_epochs = [];
    number_of_labeled = 0;
    number_of_unlabeled = 0;
    for k = 1:length(data.data_matrix)
         indices = [6:5:length(data.data_matrix(k).accel)];
         data.data_matrix(k).diff5 = zeros(length(indices) + 1, 1);
         data.data_matrix(k).diff5(1) = 0;
         data.data_matrix(k).diff5(2:end) = data.data_matrix(k).accel(indices) - data.data_matrix(k).accel(indices - 5);
        if length(find(abs(data.data_matrix(k).diff5) > old_threshold)) == 0

        else 
            %finding time threshold
            first_critical_index = find(abs(data.data_matrix(k).diff5) > old_threshold,1);
            first_critical_point = indices(first_critical_index - 1);%-1 because indices start with 6 and not 1
            critical_time = data.data_matrix(k).time(end) - data.data_matrix(k).time(first_critical_point);
            if critical_time < 0
                continue
            end


            critical_epochs = [critical_epochs, data.data_matrix(k).num];
            number_of_labeled = number_of_labeled + data.data_matrix(k).epoch_labels;
            number_of_unlabeled = number_of_unlabeled + ~ data.data_matrix(k).epoch_labels;

        end  
    end
    
    old_tpr = number_of_labeled/data.number_of_hustles;
    old_fpr = number_of_unlabeled/data.number_of_nonhustles;
    old_fpr_tpr = [old_fpr, old_tpr];
    old_tp = number_of_labeled;
    old_tn = data.number_of_nonhustles - number_of_unlabeled;
    old_accuracy = (old_tp + old_tn)/(data.number_of_hustles + data.number_of_nonhustles);
    
    
    
    
    
    
    % ======= Using the new, optimal classifier =======
    critical_times = [];
    critical_epochs = [];
    non_critical_epochs = [];
    number_of_labeled = 0;
    number_of_unlabeled = 0;
    for k = 1:length(data.data_matrix)
         indices = [6:5:length(data.data_matrix(k).accel)];
         data.data_matrix(k).diff5 = zeros(length(indices) + 1, 1);
         data.data_matrix(k).diff5(1) = 0;
         data.data_matrix(k).diff5(2:end) = data.data_matrix(k).accel(indices) - data.data_matrix(k).accel(indices - 5);
        if length(find(abs(data.data_matrix(k).diff5) > optimal_threshold)) == 0

        else 
            %finding time threshold
            first_critical_index = find(abs(data.data_matrix(k).diff5) > optimal_threshold,1);
            first_critical_point = indices(first_critical_index - 1);%-1 because indices start with 6 and not 1
            critical_time = data.data_matrix(k).time(end) - data.data_matrix(k).time(first_critical_point);
            if critical_time < optimal_time
                continue
            end


            critical_epochs = [critical_epochs, data.data_matrix(k).num];
            number_of_labeled = number_of_labeled + data.data_matrix(k).epoch_labels;
            number_of_unlabeled = number_of_unlabeled + ~ data.data_matrix(k).epoch_labels;

        end  
    end
    
    tpr = number_of_labeled/data.number_of_hustles;
    fpr = number_of_unlabeled/data.number_of_nonhustles;
    new_fpr_tpr = [fpr, tpr];
    tp = number_of_labeled;
    tn = data.number_of_nonhustles - number_of_unlabeled;
    new_accuracy = (tp + tn)/(data.number_of_hustles + data.number_of_nonhustles);
    
    validation_table{l,1} = files(i).name;
    validation_table{l,2} = labeled_data.old_first_fpr_tpr;
    validation_table{l,3} = labeled_data.old_first_accuracy;
    validation_table{l,4} = labeled_data.new_first_fpr_tpr;
    validation_table{l,5} = labeled_data.new_first_accuracy;
    validation_table{l,6} = old_fpr_tpr;
    validation_table{l,7} = old_accuracy;
    validation_table{l,8} = new_fpr_tpr;
    validation_table{l,9} = new_accuracy;
    validation_table{l,10} = optimal_time;
    l = l + 1;
    
end
validation_table{l,1} = 'mean';
validation_table{l,2} = mean(cell2mat(validation_table(2:end,2)));
validation_table{l,3} = mean(cell2mat(validation_table(2:end,3)));
validation_table{l,4} = mean(cell2mat(validation_table(2:end,4)));
validation_table{l,5} = mean(cell2mat(validation_table(2:end,5)));
validation_table{l,6} = mean(cell2mat(validation_table(2:end,6)));
validation_table{l,7} = mean(cell2mat(validation_table(2:end,7)));
validation_table{l,8} = mean(cell2mat(validation_table(2:end,8)));
validation_table{l,9} = mean(cell2mat(validation_table(2:end,9)));

cd /home/evgeny/lab/task/accel