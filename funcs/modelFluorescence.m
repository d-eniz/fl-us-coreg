function [model_values] = modelFluorescence(depth)
alpha = 12.71; % In degrees
fdiameter = 0.4; % Fibre core diameter in mm
model_values = 1 ./ (pi * (fdiameter + (depth * tan(deg2rad(alpha)))) .^ 2);