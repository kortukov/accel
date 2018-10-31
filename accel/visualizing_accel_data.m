cd /home/evgeny/lab/accel/data
files = dir('*data.mat');
a = [2,4,8,12,16,18,22,27,29,31,34];

for i = 8%length(files)
    
    load(files(i).name)
    figurename = [data.subject '_' char(string(data.session))];
    fig = figure('Name', figurename);
    
    subplot(2,1,1);
    
    %creating epoch number labels
    stim_markers = string(1:length(data.data_matrix));
    
    for j = 1:length(data.data_matrix)
       plot(data.data_matrix(j).begin:data.data_matrix(j).end, data.data_matrix(j).accel, 'b'), hold on
       text(double(data.data_matrix(j).begin), 0, num2str(data.data_matrix(j).num)); 
       title('accel');
    end
    hold off
    
    
    subplot(2,1,2)
    for j = 1:length(data.data_matrix)
       plot(data.data_matrix(j).begin:data.data_matrix(j).end, data.data_matrix(j).accel_diff, 'b'), hold on
       text(double(data.data_matrix(j).begin), 0, num2str(data.data_matrix(j).num)); 
       title('accel_diff');
    end
    hold off   
    
%     for j = 1:length(data.data_matrix)
%        plot(data.data_matrix(j).begin:data.data_matrix(j).end, data.data_matrix(j).accel), hold on
%        text(data.data_matrix(j).begin - 10, max(double(data.data_matrix(j).accel)), stim_markers(j));
%        if (data.session == 0) || (data.session == 1)
%            if data.data_matrix(j).epoch_labels == 1
%               text(data.data_matrix(j).begin, min(double(data.data_matrix(j).accel)) , 'hustle'); 
%            end
%        end
%        title('accelerometer');
%     end
%     hold off
    
    
end 
cd /home/evgeny/lab/task/accel