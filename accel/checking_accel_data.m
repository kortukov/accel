cd /home/evgeny/lab/accel/data
files = dir('*data.mat');
a = [2,4,8,12,16,18,22,27,29,31,34];

for i = 4%length(files)
    
    load(files(i).name)
    
    
    critical_point = 16;
    critical_times = [];
    critical_epochs = [];
    non_critical_epochs = [];
    for j = 1:length(data.data_matrix)
        indices = [6:5:length(data.data_matrix(j).accel)];
        data.data_matrix(j).diff5 = zeros(length(indices) + 1, 1);
        data.data_matrix(j).diff5(1) = 0;
        data.data_matrix(j).diff5(2:end) = data.data_matrix(j).accel(indices) - data.data_matrix(j).accel(indices - 5);
        
        
        if length(find(abs(data.data_matrix(j).diff5) > critical_point)) == 0
            data.data_matrix(j).critical = 0;
            data.data_matrix(j).critical_time = 0;
            non_critical_epochs = [non_critical_epochs, data.data_matrix(j).num];
        else 
            data.data_matrix(j).critical = 1;
            %counting the time from first diff5 > critical to end
            first_critical_index = find(data.data_matrix(j).diff5 > critical_point,1);
            first_critical_point = indices(first_critical_index - 1);%-1 because indices start with 6 and not 1
            data.data_matrix(j).critical_time = data.data_matrix(j).time(end) - data.data_matrix(j).time(first_critical_point);
            critical_epochs = [critical_epochs, data.data_matrix(j).num];
        end
        
        critical_times = [critical_times; data.data_matrix(j).critical_time];  
        
    end
    
    
    
    figurename = [data.subject '_' char(string(data.session))];
    fig = figure('Name', figurename);
    
    subplot(2,1,1)
    for j = critical_epochs
        if data.data_matrix(j).critical_time > 0
            if data.data_matrix(j).epoch_labels == 0
                plot(data.data_matrix(j).accel_diff(first_critical_point:end), 'Color', 'blue'); hold on
            elseif data.data_matrix(j).epoch_labels == 1
                plot(data.data_matrix(j).accel_diff(first_critical_point:end), 'Color', 'red'); hold on
            end
        end  
    end
    hold off
    title(['With critical points, threshold is: ', num2str(critical_point)]);
    
    subplot(2,1,2)
    for j = non_critical_epochs
         if data.data_matrix(j).epoch_labels == 0
             plot(data.data_matrix(j).accel_diff, 'Color', 'blue'); hold on
         elseif data.data_matrix(j).epoch_labels == 1
             plot(data.data_matrix(j).accel_diff, 'Color', 'red'); hold on
         end
    end
    hold off
    title('Without critical points');
    
    
    
    
    
end 
cd /home/evgeny/lab/task/accel