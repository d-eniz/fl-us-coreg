function [data_plot, boundary, fyy] = H5toFL(fname)

FLdata = h5read(fname, '/FL');
FLdata = FLdata(:,1:size(FLdata,2)/2);
window = [575, 688];
data_plot(1:size(FLdata,2)) = mean(FLdata(window(1):window(2), 1:end));
boundary = [min(data_plot) max(data_plot)];

fyy = max(max(max(FLdata)));
data_plot = data_plot./fyy;
