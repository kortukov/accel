%this scriptc finds optimal threshold value for accelerometer data:
%which trials have no 'big events'(big enough accel difference spikes) and
%which have some. Optimal means best in roc-curve for labeled data. (true -
%positive is critical and labeled, false positive is critical and
%unlabeled.
%it also defines time from the first 'big event' till the reaction
%'big event' is a term coined by Sasha

cd /home/evgeny/lab/accel/data
files = dir('*_accel_data.mat');

sum_threshold = 0;
k = 0;
for i = 4%:length(files)
    
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
    other_data = []
%     %concatenating 2nd session
%     other_file_name = [data.subject '_2_accel_data.mat'];
%     try 
%         other_data = load(other_file_name); 
%         other_hustles = other_data.data.number_of_hustles;
%         other_nonhustles = other_data.data.number_of_nonhustles;
%         other_data = other_data.data;
%         data.data_matrix = [data.data_matrix,other_data.data_matrix];
%     catch
%         warning('errors with loading 2 session');
%        other_hustles = 0;
%        other_nonhustles = 0;
%     end
%     
%     common_hustles = common_hustles + other_hustles;
%     common_nonhustles = common_nonhustles + other_nonhustles;
    
    % Figuring out the threshold value for critical_point
    % maximizing number of labeled epochs in critical epochs
    number_of_labeled = [];
    number_of_unlabeled = [];
    threshold = 0:0.05:20;
    for j = 2:length(threshold)

        critical_times = [];
        critical_epochs = [];
        non_critical_epochs = [];
        number_of_labeled(j) = 0;
        number_of_unlabeled(j) = 0;
        for k = 1:length(data.data_matrix)
            indices = [6:5:length(data.data_matrix(k).accel)];
            data.data_matrix(k).diff5 = zeros(length(indices) + 1, 1);
            data.data_matrix(k).diff5(1) = 0;
            data.data_matrix(k).diff5(2:end) = data.data_matrix(k).accel(indices) - data.data_matrix(k).accel(indices - 5);
            if length(find(abs(data.data_matrix(k).diff5) > threshold(j))) == 0
               
            else 
                critical_epochs = [critical_epochs, data.data_matrix(k).num];
                number_of_labeled(j) = number_of_labeled(j) + data.data_matrix(k).epoch_labels;
                number_of_unlabeled(j) = number_of_unlabeled(j) + ~ data.data_matrix(k).epoch_labels;
                
            end  
        end
    end
    
    
%      fig1 = figure;
%      k = 1:length(number_of_labeled);
    
    tpr = number_of_labeled/common_hustles;
    fpr = number_of_unlabeled/common_nonhustles;
%     scatter(fpr, tpr); hold on
%     text(fpr, tpr, num2str(k'));
%     scatter(fpr, fpr); hold off
%     text(fpr, fpr, num2str(k'));
    
    %finding optimal threshold
    
    perpendicular = []
    for j = 1:length(threshold)
        distance = []
        for k = 1:length(fpr)
           distance(k) = sqrt((fpr(j) - fpr(k))^2 + (tpr(j) - fpr(k))^2 );
        end
        perpendicular(j) = distance(find(distance == min(distance),1));
    end
    optimum = find(perpendicular == max(perpendicular), 1)
    threshold = threshold(optimum);
    optimum = [fpr(optimum),tpr(optimum)];
    
    
    critical_times = [];
    critical_epochs = [];
    non_critical_epochs = [];
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
        end
        critical_times = [critical_times; data.data_matrix(j).critical_time];  
    end
    
    
    
%     figurename = [data.subject '_' char(string(data.session)) ' accelerometer differentiantion'];
%     fig1 = figure('Name', figurename);
%     k = 0;
%     subplot(2,1,1)
%     for j = critical_epochs
% %         if data.data_matrix(j).critical_time > 0
%             if data.data_matrix(j).epoch_labels == 0
%                 plot(data.data_matrix(j).accel_diff(first_critical_point:end), 'Color', 'blue'); hold on
%                 k = k+1
%             elseif data.data_matrix(j).epoch_labels == 1
%                 plot(data.data_matrix(j).accel_diff(first_critical_point:end), 'Color', 'red'); hold on
%                 k = k + 1
%             end
% %         end  
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
    %savefig(figurename);
    
%     figurename = [data.subject '_' char(string(data.session)) ' reaction time histogram'];
%     fig2 = figure('Name', figurename);
%     critical_times = critical_times(find(critical_times));
%     hist(critical_times);
%     title('Without nulls');
    
    %savefig(figurename);
    
    %data.threshold = threshold;
    %data.optimum = optimum;
    %save(files(i).name, 'threshold', '-append');
    sum_threshold = sum_threshold + threshold;
    k = k + 1;
end 
if k ~= 0
    sum_threshold = sum_threshold/ k;
end
cd /home/evgeny/lab/task/accel

% %%Histogram made by Sasha, 
% th_hh =  th_h(~cellfun('isempty',th_h));
% th_hh(1:32)=[]; 
% th_hh(1:2:end-1)=[];
% th_hh = cell2mat(th_hh);
% th_mean = mean(th_hh);
