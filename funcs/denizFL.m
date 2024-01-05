function [normFL] = denizFL(depth)
normFL = zeros(1, length(depth));
for k = 1:length(depth)
normFL(k) = (0.06323*exp(-1.013*depth(k)) + 0.3203*exp(-0.002938*depth(k)));
end
normFL = (normFL - min(normFL)) / (max(normFL) - min(normFL));