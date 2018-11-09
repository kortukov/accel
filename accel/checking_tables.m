cd /home/evgeny/lab/feat_tables_global

files = dir('*.txt')

table_accel_correction = {};
table_accel_correction{1,1} = 'subject';
table_accel_correction{1,2} = 'table';
table_accel_correction{1,3} = 'accel';
table_accel_correction{1,4} = 'correct';
for i = 1:length(files)
    cd /home/evgeny/lab/feat_tables_global
    filename = files(i).name
    table = readtable(filename);
    table_columns = size(table,1);
    k = strfind(filename, '_') 
    accel_data_name = [filename(1:k(1)+1) '_accel_data.mat'];
    cd /home/evgeny/lab/accel/data
    try
        load(accel_data_name);
    catch
        warning('Unable to load accel data');
        table_accel_correction{i+1,1} = filename;
        continue
    end
    accel_columns = length(data.data_matrix);
    table_accel_correction{i+1,1} = filename;
    table_accel_correction{i+1,2} = table_columns;
    table_accel_correction{i+1,3} = accel_columns;
    table_accel_correction{i+1,4} = accel_columns == table_columns;
    
end

cd /home/evgeny/lab/task/accel