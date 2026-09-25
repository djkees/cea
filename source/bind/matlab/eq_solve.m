function result = eq_solve(eq_type, reactants, opts)
%EQ_SOLVE Solve a CEA equilibrium problem using plain MATLAB inputs/outputs.
%   RESULT = EQ_SOLVE(EQ_TYPE, REACTANTS, ...) wraps cea.matlab.eq_solve so
%   REACTANTS and every numeric argument accept plain MATLAB types (a
%   string array or cellstr, and double scalars/vectors) instead of
%   py.list/py.numpy.array, and returns RESULT as a plain MATLAB struct
%   instead of a Python namespace.
%
%   EQ_TYPE is the Python equilibrium-type enum from the cea module, e.g.
%   cea.HP, cea.TP, cea.SP, cea.UV — import cea first:
%       cea = py.importlib.import_module('cea');
%
%   REACTANTS is a string array or cellstr of species names, e.g.
%   ["H2","O2"] or {'H2','O2'}.
%
%   Name-value arguments mirror cea.matlab.eq_solve (see
%   docs/source/interfaces/matlab_api.rst for the full description of
%   each): T, H, S, U, P, V, T_reac, fuel_amounts, oxid_amounts, moles,
%   of_ratio, phi, r_eq, pct_fuel, only, omit, insert, trace, transport,
%   ions.
%
%   RESULT fields: last_error, converged, T, P, volume, density, M, MW,
%   enthalpy, energy, entropy, gibbs_energy, gamma_s, cp_fr, cp_eq, cp,
%   cv_fr, cv_eq, cv, viscosity, conductivity_fr, conductivity_eq, Pr_fr,
%   Pr_eq, nj, ln_nj, n, mass_fractions, mole_fractions. mass_fractions
%   and mole_fractions are containers.Map keyed by species name.
%
%   See also source/bind/matlab/samples/equilibrium_example.m

arguments
    eq_type
    reactants
    opts.T double = []
    opts.H double = []
    opts.S double = []
    opts.U double = []
    opts.P double = []
    opts.V double = []
    opts.T_reac double = []
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
end

ceam = py.importlib.import_module('cea.matlab');

kwargs = {};
kwargs = add_numeric_kwarg(kwargs, 'T', opts.T);
kwargs = add_numeric_kwarg(kwargs, 'H', opts.H);
kwargs = add_numeric_kwarg(kwargs, 'S', opts.S);
kwargs = add_numeric_kwarg(kwargs, 'U', opts.U);
kwargs = add_numeric_kwarg(kwargs, 'P', opts.P);
kwargs = add_numeric_kwarg(kwargs, 'V', opts.V);
kwargs = add_numeric_kwarg(kwargs, 'T_reac', opts.T_reac);
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

soln = ceam.eq_solve(eq_type, matlab2pylist(reactants), pyargs(kwargs{:}));

numericFields = ["T", "P", "volume", "density", "M", "MW", "enthalpy", ...
    "energy", "entropy", "gibbs_energy", "gamma_s", "cp_fr", "cp_eq", ...
    "cp", "cv_fr", "cv_eq", "cv", "viscosity", "conductivity_fr", ...
    "conductivity_eq", "Pr_fr", "Pr_eq", "nj", "ln_nj", "n"];
result = pysoln2struct(soln, numericFields);

end
