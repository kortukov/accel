cd /home/evgeny/lab/ann
files = dir('*.ann')

for i = 1:1
    markers = readtable(files(i).name, 'filetype', 'text')
    markers = table2array(markers)
    ST = [11,12,21,22,211,212,221,222,255];
    RS = [101,104];
    
    j = 1
    while ~(ismember(markers(j,3), ST)) %ищем первый стимул
        j = j + 1
    end
    first_st = markers(j,1)
end



cd /home/evgeny/lab/task

