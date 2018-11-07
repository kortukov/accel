%First, run this script with data.threshold (mean threshold commented)
%on all the accel_data_files and write it to table.
%Then change the individual threshold to mean threshold 
%changes on lines 29-30 and 71-72
%and run script on all the files again

cd /home/evgeny/lab/accel/data
files = dir('*data.mat');
%numbers of files with labels

%mean threshold was computed in threshold_accel_data.m
mean_threshold = 12.136363636363637;
for i = 3%1:length(files)
    load(files(i).name)
    
    %individual thresholds are stored in accel_data of 1st sessions
    
    if (data.session ~= 1)
        labeled_file_name = [data.subject '_1_accel_data.mat'];
        labeled_data = load(labeled_file_name);
        try 
            data.threshold = labeled_data.data.threshold;
        catch
            %warning('Even the 1st session doesn`t have labels');
            data.threshold = mean_threshold;
        end
        clear('labeled_data')
    end
    %threshold = mean_threshold;
    threshold = data.threshold;
    
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
            non_critical_epochs = [non_critical_epochs, data.data_matrix(j).num];
        else 
            data.data_matrix(j).critical = 1;
            %counting the time from first diff5 > critical to end
            first_critical_index = find(abs(data.data_matrix(j).diff5) > threshold,1);
            first_critical_point = indices(first_critical_index - 1);%-1 because indices start with 6 and not 1
            data.data_matrix(j).critical_time = data.data_matrix(j).time(end) - data.data_matrix(j).time(first_critical_point);
            critical_epochs = [critical_epochs, data.data_matrix(j).num];
            %number_of_labeled = number_of_labeled + data.data_matrix(j).epoch_labels;
            %number_of_unlabeled = number_of_unlabeled + ~ data.data_matrix(j).epoch_labels;
        end
        critical_times = [critical_times; data.data_matrix(j).critical_time];  
    end
    
    table_name = [data.subject '_' num2str(data.session) '.txt'];
    
    %forming the column vector
    times_column = [];
    for j = 1:length(data.data_matrix)
        times_column = [times_column; data.data_matrix(j).critical_time];
    end
    cd ../../feat_tables_global
    table = readtable(table_name);
    
    %table.mean_time = times_column
    table.individual_time = times_column;
    
    writetable(table, table_name);
    
    
    
%     fpr = number_of_unlabeled/data.number_of_nonhustles;
%     tpr = number_of_labeled/data.number_of_hustles;
%     optimum = [fpr, tpr]
%     
%     figurename = [data.subject '_' char(string(data.session)) ' accelerometer differentiantion'];
%     fig1 = figure('Name', figurename);
%     k = 0;
%     subplot(2,1,1)
%     for j = critical_epochs
%          if data.data_matrix(j).critical_time > 500
%             if data.data_matrix(j).epoch_labels == 0
%                 plot(data.data_matrix(j).accel_diff(first_critical_point:end), 'Color', 'blue'); hold on
%                 k = k+1
%             elseif data.data_matrix(j).epoch_labels == 1
%                 plot(data.data_matrix(j).accel_diff(first_critical_point:end), 'Color', 'red'); hold on
%                 k = k + 1
%             end
%          end  
%     end
%     hold off
%     title(['With critical points, threshold is: ', num2str(threshold)]);
%     
%     subplot(2,1,2)
%     for j = non_critical_epochs
%          if data.data_matrix(j).epoch_labels == 0
%              plot(data.data_matrix(j).accel_diff, 'Color', 'blue'); hold on
%          elseif data.data_matrix(j).epoch_labels == 1
%              plot(data.data_matrix(j).accel_diff, 'Color', 'red'); hold on
%          end
%     end
%     hold off
%     title('Without critical points');
%     %title(['fpr;tpr on 0 session (' num2str(optimum(1)) '; ' num2str(optimum(2)) ')  ' 'fpr;ptr on 1 session was (' num2str(labeled_optimum(1)) '; ' num2str(labeled_optimum(2)) ')']);
%     
%     
%     figurename = [data.subject '_' char(string(data.session)) ' reaction time histogram labeled'];
%     fig2 = figure('Name', figurename);
%     subplot(2,1,1);
%     critical_times_labeled = critical_times(find(critical_times(:,2)));
%     critical_times_labeled = critical_times_labeled(find(critical_times_labeled > 500));
%     critical_times_unlabeled = critical_times(find(~critical_times(:,2)));
%     critical_times_unlabeled = critical_times_unlabeled(find(critical_times_unlabeled > 500));
%     histogram(critical_times_labeled, 150, 'FaceColor', 'r'); hold on
%     title('Labeled');
%     figurename = [data.subject '_' char(string(data.session)) ' reaction time histogram unlabeled'];
% 
%     histogram(critical_times_unlabeled, 150,  'FaceColor', 'b');
%     title('Hustle - red, no hustle - blue'); hold off
    
end