function y = smoothIf(x,lower_threshold,upper_threshold)
% Reformulate conditional statement to be compatible with algorithmic
% differentiation.
%
% if x <= lower_threshold
%   y = 0; % false
% elseif x >= upper_threshold
%   y = 1; % true
% else
%   y > 0 & y < 1; % transient
% end
%
% take lower_threshold > upper_threshold to flip the true and false outputs
%
%--------------------------------------------------------------------------

% range that is affected by smoothing
range = upper_threshold - lower_threshold;

% midpoint of  range
mid = (lower_threshold + upper_threshold)/2;

% scale x to range
x_scaled = (x - mid)/range + 1/2;

% apply tanh-smoothing
y = (tanh((2*x_scaled-1)*pi)+1)/2;

end