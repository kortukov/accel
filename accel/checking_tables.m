cd /home/evgeny/lab/feat_tables_global

files = dir('*.txt')

table_check = {};
table_check{1,1} = 'subject';
table_check{1,2} = 'trials';
table_check{1,3} = 'hustles';
table_check{1,4} = 'ratio';
for i = 9%:length(files)
    cd /home/evgeny/lab/feat_tables_global
    filename = files(i).name
    table = readtable(filename);
    
    incorrectness = table.miss + table.badkey + table.early + table.late;
    correctness = ~incorrectness;
    trials = length(find(correctness));
    
    session = table.individual_time;
    hustles = length(find(session > 400));
    
    ratio = hustles/trials;
    
    table_check{i+1,1} = filename;
    table_check{i+1,2} = trials;
    table_check{i+1,3} = hustles;
    table_check{i+1,4} = ratio;
    
    
    check = table_check()
    
end

cd /home/evgeny/lab/task/accel