function [FL_image] = createFLcmap(FL, cmap)

norm = imagesc(FL, [0 1]); % Create scaled colourmap
colormap(cmap);
cdata = norm.CData; % Colourmap data
cmap = colormap(norm.Parent);
num = size(cmap, 1); % Number of colours in colourmap
c = linspace(norm.Parent.CLim(1), norm.Parent.CLim(2), num); % Intensity range
idx = reshape(interp1(c, 1:num, cdata(:), 'nearest'), size(cdata)); % Indexed image
FL_image = ind2rgb(idx, cmap);
close