function m = pyfractions2map(pydict)
%PYFRACTIONS2MAP Convert a py.dict of species fractions into a containers.Map.
%   Species names (e.g. "e-") are not always valid MATLAB struct field
%   names, so a Map is used instead of a struct.
m = containers.Map('KeyType', 'char', 'ValueType', 'any');
keys = cell(py.list(pydict.keys()));
for k = 1:numel(keys)
    key = char(keys{k});
    m(key) = double(pydict{keys{k}});
end
end
