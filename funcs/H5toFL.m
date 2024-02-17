function [data_plot] = H5toFL(fname)

FLdata = h5read(fname, '/FL'); % reading the fluorescence dataset
FLdata = FLdata(:,1:size(FLdata,2)/2);
window = findwindow(FLdata);
%window = [575, 688]; % force original window

data_plot(1:size(FLdata,2)) = mean(FLdata(window(1):window(2), 1:end));

data_plot = normalize(data_plot, 'range');