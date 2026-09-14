function result = rocket_solve(reactants, pc, opts)
%ROCKET_SOLVE Solve a CEA rocket-performance problem using plain MATLAB inputs/outputs.
%   RESULT = ROCKET_SOLVE(REACTANTS, PC, ...) wraps cea.matlab.rocket_solve
%   so REACTANTS and every numeric argument accept plain MATLAB types (a
%   string array or cellstr, and double scalars/vectors) instead of
%   py.list/py.numpy.array, and returns RESULT as a plain MATLAB struct
%   instead of a Python namespace.
%
%   REACTANTS is a string array or cellstr of species names, e.g.
%   ["H2(L)","O2(L)"] or {'H2(L)','O2(L)'}. PC is the chamber pressure.
%
%   Name-value arguments mirror cea.matlab.rocket_solve (see
%   docs/source/interfaces/matlab_api.rst for the full description of
%   each): pi_p, subar, supar, T_reac, fuel_amounts, oxid_amounts, moles,
%   of_ratio, phi, r_eq, pct_fuel, only, omit, insert, trace, transport,
%   ions, iac, n_frz, hc, tc, mdot, ac_at, tc_est.
%
%   RESULT fields (each a double vector over the solved stations, unless
%   noted): last_error, converged, num_pts, T, P, volume, density, M, MW,
%   enthalpy, energy, entropy, gibbs_energy, gamma_s, cp_fr, cp_eq, cp,
%   cv_fr, cv_eq, cv, Mach, sonic_velocity, ae_at, c_star,
%   coefficient_of_thrust, Isp, Isp_vacuum, viscosity, conductivity_fr,
%   conductivity_eq, Pr_fr, Pr_eq, nj, ln_nj, n, mass_fractions,
%   mole_fractions. mass_fractions and mole_fractions are containers.Map
%   keyed by species name, each value a double vector over stations.
%
%   See also source/bind/matlab/samples/rocket_example.m

arguments
    reactants
    pc (1,1) double
    opts.pi_p double = []
    opts.subar double = []
    opts.supar double = []
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
    opts.iac (1,1) logical = true
    opts.n_frz double = []
    opts.hc double = []
    opts.tc double = []
    opts.mdot double = []
    opts.ac_at double = []
    opts.tc_est double = []
end

ceam = py.importlib.import_module('cea.matlab');

kwargs = {};
kwargs = add_numeric_kwarg(kwargs, 'pi_p', opts.pi_p);
kwargs = add_numeric_kwarg(kwargs, 'subar', opts.subar);
kwargs = add_numeric_kwarg(kwargs, 'supar', opts.supar);
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
kwargs = [kwargs, {'iac', opts.iac}];
if ~isempty(opts.n_frz)
    kwargs = [kwargs, {'n_frz', int32(opts.n_frz)}];
end
kwargs = add_numeric_kwarg(kwargs, 'hc', opts.hc);
kwargs = add_numeric_kwarg(kwargs, 'tc', opts.tc);
kwargs = add_numeric_kwarg(kwargs, 'mdot', opts.mdot);
kwargs = add_numeric_kwarg(kwargs, 'ac_at', opts.ac_at);
kwargs = add_numeric_kwarg(kwargs, 'tc_est', opts.tc_est);

soln = ceam.rocket_solve(matlab2pylist(reactants), pc, pyargs(kwargs{:}));

numericFields = ["T", "P", "volume", "density", "M", "MW", "enthalpy", ...
    "energy", "entropy", "gibbs_energy", "gamma_s", "cp_fr", "cp_eq", ...
    "cp", "cv_fr", "cv_eq", "cv", "Mach", "sonic_velocity", "ae_at", ...
    "c_star", "coefficient_of_thrust", "Isp", "Isp_vacuum", "viscosity", ...
    "conductivity_fr", "conductivity_eq", "Pr_fr", "Pr_eq", "nj", ...
    "ln_nj", "n", "num_pts"];
result = pysoln2struct(soln, numericFields);

end
