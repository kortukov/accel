%this will be the main classification testing script
cd /home/evgeny/lab/accel/data
files = dir('*data.mat');

for i = 4:4 %length(files)
    load(files(i).name);
    if data.session ~= 1
        clear data
        continue
    end
    %first we need to extract features and labels from our accel data
    for j = 1:4%length(data.data_matrix)
        %extracting the features from each training sample
        %trying squared distance from normal path
        normal_path = zeros(length(data.data_matrix(j).time),1);
        normal_path([1,end]) = data.data_matrix(j).position([1,end]);
        
        xy = normal_path(end) - normal_path(1);
        ms = data.data_matrix(j).time(end) - data.data_matrix(j).time(1);
        step = xy/ms;
        
        normal_path(2:end-1) = normal_path(1) + step* (1:length(data.data_matrix(j).time) - 2);
        deviation = (data.data_matrix(j).position - normal_path).^2
        
        X(j) = var(data.data_matrix(j).accel);
        %extracting labels
        y(j) = data.data_matrix(j).epoch_labels;
    end
    X = X';
    y = y';
%     %scatter(X(:,1), X(:,2));
%    
%     %calculating predictions
%     y_predicted= (X > .5);
%     %checking accuracy 
%     accuracy = sum(y & y_predicted)/100;
end