function result = pysoln2struct(soln, numericFields)
%PYSOLN2STRUCT Flatten a cea.matlab solution namespace into a plain MATLAB struct.
%   NUMERICFIELDS is a string array of attribute names on SOLN (besides
%   last_error/converged/mass_fractions/mole_fractions) to copy over as
%   double scalars/vectors/matrices.
result = struct();
result.last_error = double(py.getattr(soln, 'last_error'));
result.converged = logical(py.getattr(soln, 'converged'));
for name = numericFields
    result.(char(name)) = double(py.getattr(soln, char(name)));
end
result.mass_fractions = pyfractions2map(py.getattr(soln, 'mass_fractions'));
result.mole_fractions = pyfractions2map(py.getattr(soln, 'mole_fractions'));
end
