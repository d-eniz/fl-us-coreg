function [coregImage,dataPlots] = imageCoregistration(currentFile, threshold, visibility, gain)

[~, name, format] = fileparts(char(currentFile));
fname = [name, format];

attributes = H5att(fname);
load('attributes.mat');
US_data = H5toUS(fname);
[FL_data, boundary, fyy] = H5toFL(fname);
dy = depth_mm / size(US_data, 1);
[data_rows, data_cols] = size(US_data);

factor = data_cols / length(FL_data);
query = linspace(1, length(FL_data), length(FL_data) * factor);
FL_data = interp1(FL_data, query);

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
depth = (depth .* depth_mm) ./ size(US_data, 1);

FL_processed = modelFluorescence(depth);
FL_processed = rescale(FL_processed, boundary(1), boundary(2));
FL_processed = FL_processed./fyy;
depth_corrected = FL_data - FL_processed;
depth_corrected = depth_corrected .* gain;
depth_corrected = 0.5 - mean(depth_corrected) + depth_corrected;
FL_image = createFLcmap(depth_corrected, "jet");
FL_image = imresize(FL_image, [size(US_data, 1), size(US_data, 2)]);

x_axis = dx:dx:length_mm;
y_axis = dy:dy:depth_mm;

figure('Position', [50 50 1000 750], 'visible','off');
pbaspect([length_mm depth_mm 1])
imagesc(x_axis, y_axis, US_data);
hold on
colormap gray
FL = imagesc(x_axis, y_axis, FL_image);
selection = US_data .* uint8(peakPos);
set(FL, 'AlphaData', selection);
title("Depth-corrected FL data over US image")
xlabel("Distance (mm)"),
ylabel("Depth (mm)")
axis equal
axis tight

coregImage = frame2im(getframe(gca));
close;

fig2 = figure('Position', [50 50 1000 750], 'visible','off');
subplot(2,2,1);
sgtitle("File: " + fname + ", Threshold: " + threshold + ", Visibility: " + visibility)
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
subplot(2,2,3);
    scatter(x_axis, FL_data,".")
    title("Fluorescence, experimental vs model")
    hold on
    scatter(x_axis, FL_processed,".")
    hold off
    legend("Exp", "Model")
    xlabel("Distance (mm)"),
    ylabel("Fluorescence (AU)")
    axis tight
subplot(2,2,2);
    imagesc(FL_image)
    title("Colormap")
    %colorbar
    axis tight
    axis off
subplot(2,2,4)
    plot(x_axis, depth)
    set ( gca, 'ydir', 'reverse' )
    title("Detected surface")
    xlabel("Distance (mm)"),
    ylabel("Depth (mm)")
    axis equal

dataPlots = frame2im(getframe(fig2));

end