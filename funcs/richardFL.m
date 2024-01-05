function [norm_model_values] = richardFL(depth)
alpha = 12.71;  %in degrees
fdiameter = 0.4;    %fibre core diameter in mm
model_values = 1./(pi*(fdiameter+(depth*tan(deg2rad(alpha)))).^2);
norm_model_values = model_values/max(model_values);