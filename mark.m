cd ../hustle_01
files = dir('*.txt')


for i = 1:1 %later  1:size(files,1)
    files(i).name
    current_file = fopen(files(i).name)
    
    fclose(current_file)
end
cd /home/evgeny/lab/task