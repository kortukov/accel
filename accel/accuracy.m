cd /home/evgeny/lab/accel_data
files = dir('*_accel_data.mat');

for i = 1:length(files)
    
    if ((i>=76)&&(i<=78))||((i>=148)&&(i<=150))
        continue
    end
    
    load(files(i).name)
    if(data.session ~= 0) && (data.session ~=1)
        clear('data');
        continue
    end
    
    if ~isfield(data.data_matrix, 'epoch_labels')
        clear('data');
        continue
    end
    %there is lymar 0 without hustles, but we concatenate her 0 session
    %with 1st session 
    
    %concatenating 0 and 1 session to find optimal threshold
    if data.session == 0
        other_file_name = [data.subject '_1_accel_data.mat'];
    elseif data.session == 1
        other_file_name = [data.subject '_0_accel_data.mat'];
    end
    try 
        other_data = load(other_file_name); 
        other_hustles = other_data.data.number_of_hustles;
        other_nonhustles = other_data.data.number_of_nonhustles;
        other_data = other_data.data;
        data.data_matrix = [data.data_matrix,other_data.data_matrix];
    catch
        warning('unable to load 1 session');
       other_hustles = 0;
       other_nonhustles = 0;
    end
    
    common_hustles = data.number_of_hustles + other_hustles;
    common_nonhustles = data.number_of_nonhustles + other_nonhustles;
    other_data = [];
    
    % ======= Old accuracy 1st session
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
        if length(find(abs(data.data_matrix(k).diff5) > data.old_threshold)) == 0

        else 
            %finding time threshold
            first_critical_index = find(abs(data.data_matrix(k).diff5) > data.old_threshold,1);
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
    
    tpr = number_of_labeled/common_hustles;
    fpr = number_of_unlabeled/common_nonhustles;
    old_first_fpr_tpr = [fpr, tpr];
    tp = number_of_labeled;
    tn = common_nonhustles - number_of_unlabeled;
    old_first_accuracy = (tp + tn)/(common_hustles + common_nonhustles);
    
    
    
    
    
    
    % ======= New accuracy 1st session ======
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
        if length(find(abs(data.data_matrix(k).diff5) > data.optimal_threshold)) == 0

        else 
            %finding time threshold
            first_critical_index = find(abs(data.data_matrix(k).diff5) > data.optimal_threshold,1);
            first_critical_point = indices(first_critical_index - 1);%-1 because indices start with 6 and not 1
            critical_time = data.data_matrix(k).time(end) - data.data_matrix(k).time(first_critical_point);
            if critical_time < data.optimal_time
                continue
            end


            critical_epochs = [critical_epochs, data.data_matrix(k).num];
            number_of_labeled = number_of_labeled + data.data_matrix(k).epoch_labels;
            number_of_unlabeled = number_of_unlabeled + ~ data.data_matrix(k).epoch_labels;

        end  
    end
    
    tpr = number_of_labeled/common_hustles;
    fpr = number_of_unlabeled/common_nonhustles;
    new_first_fpr_tpr = [fpr, tpr];
    tp = number_of_labeled;
    tn = common_nonhustles - number_of_unlabeled;
    new_first_accuracy = (tp + tn)/(common_hustles + common_nonhustles);
    
    save(files(i).name, 'new_first_accuracy', 'new_first_fpr_tpr', 'old_first_accuracy', 'old_first_fpr_tpr', '-append');
    
end