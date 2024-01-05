function [data_plot] = H5toFL(fname)

FLdata = h5read(fname, '/FL'); % reading the fluorescence dataset
fyy = max(max(max(FLdata))); % getting the maximum value for normalising the fluorescence measurements
peak_pos = [575, 688]; % the upper and lower points of the part of the light spectra that changes when the target fluoresces, this corresponds to about 470 and 520 nm
data_plot = zeros(1,size(FLdata,2)/2);
for i = 1:size(FLdata, 2)/2 % this loop is normalising the data from the maximum value
    for j = 1
        data_plot(j,i) = mean(FLdata(peak_pos(1):peak_pos(2),i,j));
        data_plot(j,i) = data_plot(j,i)./fyy;
    end
end
data_plot = (data_plot - min(data_plot)) / (max(data_plot) - min(data_plot)); % deniz's addition to scale data between 0 and 1