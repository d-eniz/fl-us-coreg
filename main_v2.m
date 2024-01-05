clear
close all

%% Settings

fname = ["water45int100.h5"]; % file name

angle = 0; % if known, no impact on image processing
threshold = 100;
visibility = 50; % new setting, helps a lot with visibility

%% Setup

addpath(fileparts(mfilename('fullpath')));
US_data = H5toUS(fname);
FL_data = H5toFL(fname);
scan_depth = h5readatt(fname, '/', 'depth_mm');
scan_length = h5readatt(fname, '/', 'length_mm'); % scan length in mm
dx = h5readatt(fname, '/', 'dx'); % step size between the A-lines

%% Finding surface layer

[data_rows, data_cols] = size(US_data);
peakPos = zeros(data_rows, data_cols);
for col = 1:data_cols
    peakFound = false;
    for row = threshold + 1:data_rows
        if US_data(row, col) > threshold
            peakPos(row:row + visibility, col) = 1;
            peakFound = true;
        elseif peakFound
            break;
        end
    end
end

depth = zeros(1, size(peakPos, 2));
for col = 1:size(peakPos, 2)
    row_index = find(peakPos(:, col), 1, 'first');
    if ~isempty(row_index)
        depth(col) = row_index;
    end
end
depth = (depth .* scan_depth) ./ size(US_data, 1); % add dimensions

%% Fluorescence depth correction

FL_processed = richardFL(depth); % richard's method - works very well on 30 degrees, not as well on 45
%FL_processed = denizFL(depth); % my (old) method, i kept it because its useful to demonstrate a bad example

depth_corrected = sqrt((FL_data - FL_processed).^2);
depth_corrected = 1 - max(depth_corrected) + depth_corrected; % shift so that max is at 1
FL_image = createFLcmap(depth_corrected, "jet");
FL_image = imresize(FL_image, [size(US_data, 1), size(US_data, 2)]);

%% Plotting for fun

x_axis = dx:dx:scan_length;

figure;
subplot(2,2,1);
plot(x_axis, depth_corrected)
title("Fluorescence, depth corrected")
ylim([0 1])
subplot(2,2,3);
scatter(x_axis, FL_data,".")
title("Fluorescence, experimental vs model")
hold on
scatter(x_axis, FL_processed,".")
hold off
legend("Exp", "Model")
subplot(2,2,2);
imagesc(FL_image)
title("Fluorescence, depth corrected (colormap)")
colorbar
subplot(2,2,4)
plot(x_axis, depth)
title("Detected surface (" + angle + " degrees)")

%% Coregistration

figure
imagesc(US_data)
hold on
colormap gray
FL = imagesc(FL_image);
selection = US_data .* uint8(peakPos);
set(FL, 'AlphaData', selection);