function result = detonation_solve(reactants, T1, p1, opts)
%DETONATION_SOLVE Solve a CEA detonation problem using plain MATLAB inputs/outputs.
%   RESULT = DETONATION_SOLVE(REACTANTS, T1, P1, ...) wraps
%   cea.matlab.detonation_solve so REACTANTS and every numeric argument
%   accept plain MATLAB types (a string array or cellstr, and double
%   scalars/vectors) instead of py.list/py.numpy.array, and returns
%   RESULT as a plain MATLAB struct instead of a Python namespace.
%
%   REACTANTS is a string array or cellstr of species names, e.g.
%   ["H2","O2"] or {'H2','O2'}. T1 and P1 are the unburned gas
%   temperature and pressure.
%
%   Name-value arguments mirror cea.matlab.detonation_solve (see
%   docs/source/interfaces/matlab_api.rst for the full description of
%   each): fuel_amounts, oxid_amounts, moles, of_ratio, phi, r_eq,
%   pct_fuel, only, omit, insert, trace, transport, ions, frozen.
%
%   RESULT fields: last_error, converged, P1, T1, H1, M1, gamma1,
%   sonic_velocity1, P, T, density, enthalpy, energy, gibbs_energy,
%   entropy, Mach, velocity, sonic_velocity, gamma_s, P_P1, T_T1, M_M1,
%   rho_rho1, cp_fr, cv_fr, cp_eq, cv_eq, M, MW, viscosity,
%   conductivity_fr, conductivity_eq, Pr_fr, Pr_eq, nj, ln_nj, n,
%   mass_fractions, mole_fractions. mass_fractions and mole_fractions are
%   containers.Map keyed by species name.
%
%   See also source/bind/matlab/samples/detonation_example.m

arguments
    reactants
    T1 (1,1) double
    p1 (1,1) double
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
    opts.frozen (1,1) logical = false
end

ceam = py.importlib.import_module('cea.matlab');

kwargs = {};
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
kwargs = [kwargs, {'frozen', opts.frozen}];

soln = ceam.detonation_solve(matlab2pylist(reactants), T1, p1, pyargs(kwargs{:}));

numericFields = ["P1", "T1", "H1", "M1", "gamma1", "sonic_velocity1", ...
    "P", "T", "density", "enthalpy", "energy", "gibbs_energy", ...
    "entropy", "Mach", "velocity", "sonic_velocity", "gamma_s", "P_P1", ...
    "T_T1", "M_M1", "rho_rho1", "cp_fr", "cv_fr", "cp_eq", "cv_eq", "M", ...
    "MW", "viscosity", "conductivity_fr", "conductivity_eq", "Pr_fr", ...
    "Pr_eq", "nj", "ln_nj", "n"];
result = pysoln2struct(soln, numericFields);

end
