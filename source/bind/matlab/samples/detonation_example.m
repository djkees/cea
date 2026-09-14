% Define the Python environment
pythonExe = '/Users/mleader/miniconda3/envs/cea/bin/python'; % Replace with your Python path
pyenv('Version', pythonExe);

clear; clc;

cea = py.importlib.import_module('cea');
addpath(char(cea.matlab_dir()));

reac_names = ["H2", "O2"];
fuel_amounts = [2.0, 0.0];
oxid_amounts = [0.0, 1.0];

solution = detonation_solve(reac_names, 298.15, 1.0, ...
    fuel_amounts=fuel_amounts, oxid_amounts=oxid_amounts, ...
    r_eq=1.0);

fprintf('Converged: %d\n', solution.converged);
fprintf('Detonation T [K]: %.3f\n', solution.T);
fprintf('Detonation P [bar]: %.6f\n', solution.P);
fprintf('Velocity [m/s]: %.3f\n', solution.velocity);
fprintf('P/P1: %.6f\n', solution.P_P1);
