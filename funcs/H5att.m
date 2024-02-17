function attributes = H5att(fname)

struct = h5info(fname);

info = struct.Attributes;
names = cell(length(info));

for i = 1:length(info)
    names{i} = info(i).Name;
end

for i = 1:length(names)
    attributes.(genvarname(names{i})) = h5readatt(fname, '/', names{i});
end

if isfield(attributes, 'dt')
else
    attributes.('dt') = 1e-8;
end

if isfield(attributes, 'alines')
elseif isfield(attributes, 'a_lines')
    attributes.('alines') = h5readatt(fname, '/', 'a_lines');
    attributes = rmfield(attributes, 'a_lines');
elseif isfield(attributes, 'Nx')
    attributes.('alines') = h5readatt(fname, '/', 'Nx');
    attributes = rmfield(attributes, 'Nx');
end

if isfield(attributes, 'dx')
elseif isfield(attributes, 'step')
    attributes.('dx') = h5readatt(fname, '/', 'step');
    attributes = rmfield(attributes, 'step');
else
    attributes.('dx') = h5readatt(fname, '/', 'length_mm')/h5readatt(fname, '/', 'alines');
end

if isfield(attributes, 'length_mm')
elseif isfield(attributes, 'length')
   attributes.('length_mm') = h5readatt(fname, '/', 'length');
   attributes = rmfield(attributes, 'length');
else
   attributes.('length_mm') = attributes.('dx')*attributes.('alines');
end

if isfield(attributes, 'depth_mm')
elseif isfield(attributes, 'depth')
   attributes = rmfield(attributes, 'depth');
   attributes.('depth_mm') = h5readatt(fname, '/', 'depth');
else
   attributes.('depth_mm') = attributes.('samples')*((attributes.('dt') * 1e6 * 1500/2)/1000);
end

if isfield(attributes, 'samples')
else
    attributes.('samples') = attributes.('depth_mm')/((attributes.('dt') * 1e6 * 1500/2)/1000);
end

save('attributes.mat', '-struct', 'attributes')