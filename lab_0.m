file = dir('*.set')
load(file.name, '-mat');
session = EEG.data(45, :);
[pathname, name, ext] = fileparts(file.name)
markers = readtable([name,'.ann'], 'filetype', 'text');
markers = table2array(markers);
ST = [11,12,21,22,211,212,221,222,255];
RS = [101,104]; 
%stim_ind = find(ismember(markers(:,3), ST))
%re_ind = find(ismember(markers(:,3), RS))
epochs = {};
i = 1
while i < size(markers,1) %проходимся по всем строкам файла разметки
    if ismember(markers(i, 3), ST) %увидели стимул 
        if markers(i,3) == 255
            break
        end
        a = markers(i,1); %начало эпохи
        j = i + 1;
        
        reaction = false;
        while not(ismember(markers(j, 3), ST))
            if ismember(markers(j,3), RS)
                k = j
                reaction = true;
            end
            j = j + 1;
        end
        if reaction == false %если была реакция то эпоха до неё, если нет то до следующего стимула
            k = j
        end
        i = j - 1 %чтобы не делать лишних итераций
        b = markers(k ,1); %отмечаем конец эпохи
        %выбрал точкой конца эпохи время следующего стимула
%         if reaction
%             epochs{end + 1} =  session(a:b);
%         end
        epochs{end + 1} = session(a:b);
    end
    i = i + 1;
end

fig1 = figure('NumberTitle', 'off', 'Name', strcat(name,' acceleration plot'));
for i = 1:size(epochs,2)
    subplot(10,5,i)
    plot(epochs{i})
    title(string(i))
end


 
% fig3 = figure();
% for i = 1:size(epochs, 2)
%     subplot(10,5,i)
%     absolute_epoch = arrayfun(@(x)abs(x), epochs{i});
%     integrated_epoch = cumsum(absolute_epoch);
%     plot(integrated_epoch)
% end


    
    
    
