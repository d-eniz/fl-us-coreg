function data = TGC(Y_new, varargin)

i_max = round(0.2*size(Y_new,1),0);
lamda = 2.5;

num_req_inputs = 1;
if nargin < num_req_inputs
    error('Not enough input variables');
elseif ~isempty(varargin)
    for input_index = 1:2:length(varargin)
        switch varargin{input_index}
            case 'i_max'
                i_max = varargin{input_index + 1};
            case 'lamda'
                lamda = varargin{input_index + 1};
            otherwise
                error('Unknown input')
        end
    end
end
data = zeros(size(Y_new));
for y = 1:size(Y_new,2)
    for x = 1:size(Y_new,1)
        gain_factor = (min(x, i_max)/ i_max)^lamda;
        data(x,y) = Y_new(x,y)*gain_factor;
    end
end