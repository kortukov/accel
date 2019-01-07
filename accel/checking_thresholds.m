cd /home/evgeny/lab/accel/data
files = dir('*_accel_data.mat');

thresholds = {}
for i = 1:length(files)
    
    load(files(i).name)
    
    if ~isfield(data, 'threshold')
        continue
    end
    thresholds{i,1} = files(i).name ;
    thresholds{i,2} = threshold;
end