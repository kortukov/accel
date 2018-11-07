cd /home/evgeny/lab/ann
files = dir('*.ann')

incorrect_ann = {};
for i = 1:size(files,1)
    cd /home/evgeny/lab/ann
    markers = readtable(files(i).name, 'filetype', 'text');
    markers = table2array(markers);
    ST = [11,12,21,22,211,212,221,222]; %stimuli
    RS = [101,104]; %responses
    FB = [85,88,89,255]; % feedback
    
    for j = 1:length(ST)
        markers(find(markers(:,3)==ST(j)),3)= 1;
    end
    stim_indices = find(markers(:,3) == 1);
    len = length(stim_indices);
    if ~((len == 50) || (len == 100) || (len == 200))
        incorrect_ann{end + 1} = files(i).name;
    end
end
incorrect_ann = incorrect_ann';

cd /home/evgeny/lab/task