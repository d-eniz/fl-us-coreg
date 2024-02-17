function window = findwindow(FLdata)

wavelength_threshold = 0.01; % will tweak

err = sqrt(mean(diff(FLdata, 1, 2).^2, 1));
disp("STD: " + std(err) + " M: " + mean(err) + " T: " + 1.2*(mean(err) + std(err)))
figure;
plot(err)
if std(err) > mean(err)*0.1 % if standard deviation is more than 10% of mean
    threshold = 1.5*(mean(err) + std(err)); % cause of most errors
    [~,xmax] = findpeaks(err,'NPeaks',1,'MinPeakHeight',threshold);
    xmax = floor(xmax - 2*std(err));
else
    xmax = size(FLdata,2);
end

if xmax < 0
    window = [575, 688]; % force original window if there is an error in calculation
else
    normFLdata = normalize(FLdata, 'range');
    k = abs(min(normFLdata, [], 2) - normFLdata);
    k = k(:, 1:xmax);
    l = mean(k, 2)';
    plot(l)
    wavemin = find(l > wavelength_threshold, 1, 'first');
    wavemax = find(l(wavemin + 20:end) < wavelength_threshold, 1, 'first') + wavemin + 20;
    
    window = [wavemin wavemax];
end