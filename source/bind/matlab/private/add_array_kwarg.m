function kwargs = add_array_kwarg(kwargs, name, value)
%ADD_ARRAY_KWARG Append NAME/VALUE to KWARGS as a py.numpy.array if VALUE was supplied.
%   Unlike ADD_NUMERIC_KWARG, VALUE is always wrapped as a 1-D NumPy array,
%   even when it has only one element. Use this for arguments the Python
%   side treats as a per-species vector (fuel_amounts, oxid_amounts) rather
%   than a true scalar-or-array value.
%
%   MATLAB collapses any 1x1 numeric array to a Python scalar when it
%   crosses into a Python call, regardless of how it was reshaped on the
%   MATLAB side (py.numpy.array(double(x(:)')) with x scalar still yields
%   a 0-d array, which breaks callers expecting len()). Routing through
%   num2cell forces MATLAB to marshal the value as a genuine Python list
%   (which preserves its length even at 1 element) before py.numpy.array
%   sees it.
if isempty(value)
    return
end
kwargs = [kwargs, {name, py.numpy.array(num2cell(double(value(:)')))}];
end
