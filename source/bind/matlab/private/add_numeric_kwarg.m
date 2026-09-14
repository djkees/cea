function kwargs = add_numeric_kwarg(kwargs, name, value)
%ADD_NUMERIC_KWARG Append NAME/VALUE to KWARGS if VALUE was supplied.
%   A scalar VALUE is passed through as a plain MATLAB double, which MATLAB
%   auto-converts to a Python float. A vector VALUE is wrapped in
%   py.numpy.array, since MATLAB does not auto-convert numeric arrays to
%   NumPy arrays on its own (unlike scalars).
if isempty(value)
    return
end
if isscalar(value)
    kwargs = [kwargs, {name, double(value)}];
else
    kwargs = [kwargs, {name, py.numpy.array(double(value(:)'))}];
end
end
