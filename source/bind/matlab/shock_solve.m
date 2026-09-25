function result = shock_solve(reactants, T0, p0, opts)
%SHOCK_SOLVE Solve a CEA incident/reflected shock problem using plain MATLAB inputs/outputs.
%   RESULT = SHOCK_SOLVE(REACTANTS, T0, P0, ...) wraps cea.matlab.shock_solve
%   so REACTANTS and every numeric argument accept plain MATLAB types (a
%   string array or cellstr, and double scalars/vectors) instead of
%   py.list/py.numpy.array, and returns RESULT as a plain MATLAB struct
%   instead of a Python namespace.
%
%   REACTANTS is a string array or cellstr of species names, e.g.
%   ["H2","O2","Ar"] or {'H2','O2','Ar'}. T0 and P0 are the unshocked gas
%   temperature and pressure.
%
%   Name-value arguments mirror cea.matlab.shock_solve (see
%   docs/source/interfaces/matlab_api.rst for the full description of
%   each): u1, Mach1, fuel_amounts, oxid_amounts, moles, of_ratio, phi,
%   r_eq, pct_fuel, only, omit, insert, trace, transport, ions,
%   reflected, incident_frozen, reflected_frozen.
%
%   RESULT fields: last_error, converged, T, P, velocity, Mach,
%   sonic_velocity, rho12, rho52, P21, P52, T21, T52, M21, M52, v2,
%   u5_p_v2, volume, density, M, MW, enthalpy, energy, entropy,
%   gibbs_energy, gamma_s, cp_fr, cp_eq, cp, cv_fr, cv_eq, cv, viscosity,
%   conductivity_fr, conductivity_eq, Pr_fr, Pr_eq, nj, ln_nj, n,
%   mass_fractions, mole_fractions. mass_fractions and mole_fractions are
%   containers.Map keyed by species name. Several fields (T, P, ...) come
%   back as vectors indexed by shock state (incident, then reflected if
%   requested) rather than scalars.
%
%   See also source/bind/matlab/samples/shock_example.m

arguments
    reactants
    T0 (1,1) double
    p0 (1,1) double
    opts.u1 double = []
    opts.Mach1 double = []
    opts.fuel_amounts double = []
    opts.oxid_amounts double = []
    opts.moles (1,1) logical = false
    opts.of_ratio double = []
    opts.phi double = []
    opts.r_eq double = []
    opts.pct_fuel double = []
    opts.only = []
    opts.omit = []
    opts.insert = []
    opts.trace double = []
    opts.transport (1,1) logical = false
    opts.ions (1,1) logical = false
    opts.reflected (1,1) logical = true
    opts.incident_frozen (1,1) logical = false
    opts.reflected_frozen (1,1) logical = false
end

ceam = py.importlib.import_module('cea.matlab');

kwargs = {};
kwargs = add_numeric_kwarg(kwargs, 'u1', opts.u1);
kwargs = add_numeric_kwarg(kwargs, 'Mach1', opts.Mach1);
kwargs = add_array_kwarg(kwargs, 'fuel_amounts', opts.fuel_amounts);
kwargs = add_array_kwarg(kwargs, 'oxid_amounts', opts.oxid_amounts);
kwargs = [kwargs, {'moles', opts.moles}];
kwargs = add_numeric_kwarg(kwargs, 'of_ratio', opts.of_ratio);
kwargs = add_numeric_kwarg(kwargs, 'phi', opts.phi);
kwargs = add_numeric_kwarg(kwargs, 'r_eq', opts.r_eq);
kwargs = add_numeric_kwarg(kwargs, 'pct_fuel', opts.pct_fuel);
kwargs = add_str_list_kwarg(kwargs, 'only', opts.only);
kwargs = add_str_list_kwarg(kwargs, 'omit', opts.omit);
kwargs = add_str_list_kwarg(kwargs, 'insert', opts.insert);
kwargs = add_numeric_kwarg(kwargs, 'trace', opts.trace);
kwargs = [kwargs, {'transport', opts.transport}];
kwargs = [kwargs, {'ions', opts.ions}];
kwargs = [kwargs, {'reflected', opts.reflected}];
kwargs = [kwargs, {'incident_frozen', opts.incident_frozen}];
kwargs = [kwargs, {'reflected_frozen', opts.reflected_frozen}];

soln = ceam.shock_solve(matlab2pylist(reactants), T0, p0, pyargs(kwargs{:}));

numericFields = ["T", "P", "velocity", "Mach", "sonic_velocity", "rho12", ...
    "rho52", "P21", "P52", "T21", "T52", "M21", "M52", "v2", "u5_p_v2", ...
    "volume", "density", "M", "MW", "enthalpy", "energy", "entropy", ...
    "gibbs_energy", "gamma_s", "cp_fr", "cp_eq", "cp", "cv_fr", "cv_eq", ...
    "cv", "viscosity", "conductivity_fr", "conductivity_eq", "Pr_fr", ...
    "Pr_eq", "nj", "ln_nj", "n"];
result = pysoln2struct(soln, numericFields);

end
