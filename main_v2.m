%% Initialize

clear; close all;
addpath("funcs\")

%% Settings

threshold = 70;
visibility = 100;
gain = 10;

[fileList, pathname] = uigetfile("*.h5", "Select files", "MultiSelect", "on");
if pathname == 0
    error("Choose files to proceed")
end
addpath(pathname)

%% Start loop to process all files in folder
if isa(fileList,'cell')
    num_files = length(fileList);
else
    num_files = 1;
end

for i = 1:num_files
    if isa(fileList,'cell')
        currentFile = fileList(i);
    else
        currentFile = fileList;
    end
    [~, name, format] = fileparts(char(currentFile));
    fname = [name, format];

%% Setup
disp("Processing " + fname + " at T:" + threshold + " V:" + visibility)
attributes = H5att(fname);
load('attributes.mat');
US_data = H5toUS(fname);
[FL_data, boundary, fyy] = H5toFL(fname);
dy = depth_mm / size(US_data, 1);
[data_rows, data_cols] = size(US_data);

%% Interpolate FL data to fit to US image for scans with different resolutions

factor = data_cols / length(FL_data);
query = linspace(1, length(FL_data), length(FL_data) * factor);% points to be interpolated
FL_data = interp1(FL_data, query);

%% Finding surface layer

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
depth = (depth .* depth_mm) ./ size(US_data, 1); % add dimensions

%% Fluorescence depth correction

FL_processed = modelFluorescence(depth);

FL_processed = rescale(FL_processed, boundary(1), boundary(2));
FL_processed = FL_processed./fyy;

depth_corrected = FL_data - FL_processed;
depth_corrected = depth_corrected .* gain;
depth_corrected = 0.5 - mean(depth_corrected) + depth_corrected;

FL_image = createFLcmap(depth_corrected, "jet");
FL_image = imresize(FL_image, [size(US_data, 1), size(US_data, 2)]);

%% Plotting

x_axis = dx:dx:length_mm;
y_axis = dy:dy:depth_mm;

figs = figure('Position', [50 50 1200 500],'visible','off');

subplot(2,4,[1, 2, 5, 6])
    imagesc(x_axis, y_axis, US_data);
    hold on
    colormap gray
    FL = imagesc(x_axis, y_axis, FL_image);
    %colorbar
    selection = US_data .* uint8(peakPos);
    set(FL, 'AlphaData', selection);
    title("Depth-corrected FL data over US image")
    xlabel("Distance (mm)"),
    ylabel("Depth (mm)")
    axis equal
    axis tight
subplot(2,4,3);
sgtitle("File: " + fname + ", Threshold: " + threshold + ", Visibility: " + visibility, " Gain:" + gain)
    plot(x_axis, depth_corrected)
    xlim("tight")
    if max(depth_corrected) > 1
        ylim([0 max(depth_corrected)])
    else 
        ylim([0 1])
    end
    title("Fluorescence, depth corrected")
    xlabel("Distance (mm)"),
    ylabel("Fluorescence (AU)")
subplot(2,4,7);
    scatter(x_axis, FL_data,".")
    title("Fluorescence, experimental vs model")
    hold on
    scatter(x_axis, FL_processed,".")
    hold off
    legend("Exp", "Model")
    xlabel("Distance (mm)"),
    ylabel("Fluorescence (AU)")
    axis tight
subplot(2,4,4);
    imagesc(FL_image)
    title("Colormap")
    axis tight
    axis off
subplot(2,4,8)
    plot(x_axis, depth)
    set ( gca, 'ydir', 'reverse' )
    title("Detected surface")
    xlabel("Distance (mm)"),
    ylabel("Depth (mm)")
    axis equal

fname = fullfile("processed_images", name + "t" + threshold + "v" + visibility + "g" + gain + ".png");
exportgraphics(figs, fname, "Resolution", 300)
disp("Image saved at " + fname)
end
disp("All images saved")