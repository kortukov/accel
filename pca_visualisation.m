cd /home/evgeny/lab/ann
files = dir('*.ann')

for i = 328:328%size(files,1)
    %opening video_data files
    [path, filename, ext] = fileparts(files(i).name);
    k = strfind(filename, '_') %здесь просто составляем имена необходимых файлов
    folder_name = filename(1:k(1)-1);
    folder_name = ['../clean_data/',folder_name];
    video_file_name = [filename,'_video_data.mat'];
    try
        cd (folder_name);
        load(video_file_name, 'cent_cords', 'fing_cords', 'timing');
    catch
        warning(['Video data not found, was searching for ',folder_name])
        continue
    end
    video_file_name 
    clear('path','filename','ext','k','folder_name')
    %all files ready
    
    %first - finding the difference between cords and timing so that
    %visualisation is correct
    delta = length(timing) - length(cent_cords);
    left = floor(delta/2);
    right = ceil(delta/2);
    
    
    %visualising vectors and pca with no correction
    f1 = figure('Name', video_file_name)
    subplot(4,1,1)
    suptitle([video_file_name, ' no correction']);
    plot(timing(1 + left :end-right), cent_cords(:,1)), hold on
    plot(timing(1 + left :end-right), fing_cords(:,1))
    hold off
    legend('cent X','fing X')
    subplot(4,1,2)
    plot(timing(1 + left :end-right), cent_cords(:,2)), hold on
    plot(timing(1 + left :end-right), fing_cords(:,2))
    hold off
    legend('cent Y','fing Y')
    
    %adding coordinate differece without correction to second figure
    f2 = figure('Name','coordinate difference before and after correction');
    dif = (cent_cords - fing_cords)./max(cent_cords - fing_cords);
    subplot(2,1,1)
    plot(timing(1+left :end-right), dif(:,1)); hold on
    plot(timing(1+left: end-right), dif(:,2)); hold off
    legend('dif X', 'dif Y')
    
    %adding pca plot to first figure
    M = pca(dif);
    dif = dif * M;
    
    figure(f1)
    subplot(4,1,3)
    plot(timing(1 + left :end-right), dif(:,1)), hold on
%     stem(timing,stim_timecourse)
%     stem(timing,rs_timecourse)
%     stem(timing, hustle_timecourse)
    hold off
    legend('1st PC')
    subplot(4,1,4)
    plot(timing(1 + left :end-right), dif(:,2)), hold on
%     stem(timing,stim_timecourse)
%     stem(timing,rs_timecourse)
%     stem(timing, hustle_timecourse), hold off
    legend('2nd PC')
    
    
    
    
    %correcting the coordinate difference 
    dif = (cent_cords - fing_cords)./max(cent_cords - fing_cords);
    
    correction = isoutlier(dif);
    
    correction(:,1) = bitor(correction(:,1),correction(:,2));
    correction(:,2) = correction(:,1);
    dif(find(correction)) = NaN;
    dif = dif - nanmean(dif);
    olddif = dif;
    
    figure(f2);
    subplot(2,1,2)
    plot(timing(1+left :end-right), dif(:,1)); hold on
    plot(timing(1+left: end-right), dif(:,2)); hold off
    legend('dif X', 'dif Y')
    suptitle('difference before and after correction');
    
    
    %new corrected pca
    
    [M, score, latent] = pca(dif);
    newdif = dif * M;
    
    f3 = figure('Name', 'Correction: removed all outliers from difference')
    subplot(4,1,1)
    plot(timing(1 + left :end-right), cent_cords(:,1)), hold on
    plot(timing(1 + left :end-right), fing_cords(:,1))
    hold off
    legend('cent X','fing X')
    subplot(4,1,2)
    plot(timing(1 + left :end-right), cent_cords(:,2)), hold on
    plot(timing(1 + left :end-right), fing_cords(:,2))
    hold off
    legend('cent Y','fing Y')
    subplot(4,1,3)
    suptitle([video_file_name, 'removed all outliers']);
    plot(timing(1 + left :end-right), newdif(:,1))
    legend('1st PC')
    subplot(4,1,4)
    plot(timing(1 + left :end-right), newdif(:,2))
    legend('2nd PC')
    
    
    
end

cd /home/evgeny/lab/task