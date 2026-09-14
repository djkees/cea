function pylist = matlab2pylist(value)
%MATLAB2PYLIST Convert a MATLAB string array/cellstr/char row into a py.list of str.
if isempty(value)
    pylist = py.list();
    return
end
pylist = py.list(cellstr(value));
end
