% Define the Python environment
pythonExe = '/Users/mleader/miniconda3/envs/cea/bin/python'; % Replace with your Python path
pyenv('Version', pythonExe);

clear; clc;

cea = py.importlib.import_module('cea');
addpath(char(cea.matlab_dir()));

reac_names = ["H2", "O2", "Ar"];
fuel_amounts = [0.05, 0.0, 0.0];
oxid_amounts = [0.0, 0.05, 0.9];
p0 = cea.units.mmhg_to_bar(10.0);

solution = shock_solve(reac_names, 300.0, p0, ...
    u1=1100.0, ...
    fuel_amounts=fuel_amounts, oxid_amounts=oxid_amounts, ...
    moles=true, reflected=true);

fprintf('Converged: %d\n', solution.converged);
fprintf('Incident T [K]: %.3f\n', solution.T(2));
fprintf('Incident P [bar]: %.6f\n', solution.P(2));
fprintf('Reflected T [K]: %.3f\n', solution.T(3));
fprintf('P2/P1: %.6f\n', solution.P21);
fprintf('P5/P2: %.6f\n', solution.P52);
