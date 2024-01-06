%% Initialize

clear
close all
addpath("funcs\")

%% Settings

threshold = 100;
visibility = 50; % new setting, helps a lot with visibility

data_folder = "C:\Users\Deniz\Desktop\data";
addpath(data_folder);
fileList = dir(fullfile(data_folder, "*.h5"));

%% Start loop to process all files in folder

for i = 1:length(fileList)
    currentFile = fullfile(data_folder, fileList(i).name);
    [~, name, format] = fileparts(char(currentFile));
    fname = [name, format];

%% Setup

US_data = H5toUS(fname);
FL_data = H5toFL(fname);
scan_depth = h5readatt(fname, '/', 'depth_mm');
scan_length = h5readatt(fname, '/', 'length_mm'); % scan length in mm
dx = h5readatt(fname, '/', 'dx'); % step size between the A-lines
dy = scan_depth / size(US_data, 1);

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

FL_processed = richardFL(depth); % richard's method - works generally well
%FL_processed = denizFL(depth); % my (old) method, doesn't work at all but
% i kept it because it's useful to demonstrate a bad example

% This part is about displaying how much the experimental data deviates
% from the model values calculated using depth data. I will experiment on
% which mode to use to display this deviation.
depth_corrected = sqrt((FL_data - FL_processed).^2);
depth_corrected = 0.5 - mean(depth_corrected) + depth_corrected; % shift median to 0.5
%depth_corrected = 1 - max(depth_corrected) + depth_corrected; % shift max to 1

FL_image = createFLcmap(depth_corrected, "jet");
FL_image = imresize(FL_image, [size(US_data, 1), size(US_data, 2)]);

%% Plotting

x_axis = dx:dx:scan_length;
y_axis = dy:dy:scan_depth;

data_plots = figure;
subplot(2,2,1);
sgtitle(fname)
    plot(x_axis, depth_corrected)
    xlim("tight")
    if max(depth_corrected) > 1
        ylim([0 max(depth_corrected)])
    else 
        ylim([0 1])
    end
    title("Fluorescence, depth corrected")
    xlabel("Distance (cm)"),
    ylabel("Fluorescence (AU)")
subplot(2,2,3);
    scatter(depth, FL_data,".")
    title("Fluorescence, experimental vs model")
    hold on
    scatter(depth, FL_processed,".")
    hold off
    legend("Exp", "Model")
    xlabel("Depth (cm)"),
    ylabel("Fluorescence (AU)")
    axis tight
subplot(2,2,2);
    imagesc(FL_image)
    title("Colormap")
    colorbar
    axis tight
subplot(2,2,4)
    plot(x_axis, depth)
    set ( gca, 'ydir', 'reverse' )
    title("Detected surface")
    xlabel("Distance (cm)"),
    ylabel("Depth (cm)")
    axis equal
    axis tight

%% Coregistration

coregistered_img = figure;
    imagesc(x_axis, y_axis, US_data)
    hold on
    colormap gray
    FL = imagesc(x_axis, y_axis, FL_image);
    colorbar
    selection = US_data .* uint8(peakPos);
    set(FL, 'AlphaData', selection);
    title("Depth-corrected FL data over US image")
    subtitle(fname)
    xlabel("Distance (cm)"),
    ylabel("Depth (cm)")
    axis equal
    axis tight

%% Save images

if ~exist("processed_images", "dir")
    mkdir("processed_images");
end
filename = fullfile("processed_images", name + "_data_plots_t" + threshold + "v" + visibility + ".png");
saveas(data_plots, filename, "png");
disp("Image saved at: " + filename);
filename = fullfile("processed_images", name + "_coregistered_img_t" + threshold + "v" + visibility + ".png");
saveas(coregistered_img, filename, "png");
disp("Image saved at: " + filename);

clf
close all

end % Image processing loop end
disp("All images saved")

%}