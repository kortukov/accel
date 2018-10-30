cd /home/evgeny/lab/accel/data
files = dir('*data.mat');
a = [2,4,8,12,16,18,22,27,29,31,34];

for i = 8%length(files)
    
    load(files(i).name)
    figurename = [data.subject '_' char(string(data.session))];
    fig = figure('Name', figurename);
    subplot(3,1,1)
    
    %creating epoch number labels
    stim_markers = string(1:length(data.data_matrix));
    
    for j = 1:length(data.data_matrix)
       plot(data.data_matrix(j).begin:data.data_matrix(j).end, data.data_matrix(j).accel), hold on
       text(data.data_matrix(j).begin - 10, max(double(data.data_matrix(j).accel)), stim_markers(j));
       if (data.session == 0) || (data.session == 1)
           if data.data_matrix(j).epoch_labels == 1
              text(data.data_matrix(j).begin, min(double(data.data_matrix(j).accel)) , 'hustle'); 
           end
       end
       title('accelerometer');
    end
    hold off
    
    subplot(3,1,2)
    for j = 1:length(data.data_matrix)
       plot(data.data_matrix(j).begin:data.data_matrix(j).end, data.data_matrix(j).speed), hold on
       text(data.data_matrix(j).begin - 10, max(double(data.data_matrix(j).speed)), stim_markers(j));
       if (data.session == 0) || (data.session == 1)
           if data.data_matrix(j).epoch_labels == 1
               text(data.data_matrix(j).begin, min(double(data.data_matrix(j).speed)), 'hustle'); 
           end
       end
       title('speed');
    end
    hold off
    subplot(3,1,3)
    for j = 1:length(data.data_matrix)
       plot(data.data_matrix(j).begin:data.data_matrix(j).end, data.data_matrix(j).position), hold on
       text(data.data_matrix(j).begin - 10, max(double(data.data_matrix(j).position)), stim_markers(j));
       if (data.session == 0) || (data.session == 1)
            if data.data_matrix(j).epoch_labels == 1
              text(data.data_matrix(j).begin, min(double(data.data_matrix(j).position)), 'hustle'); 
            end
       end
       title('position');
    end
    hold off
    
end 