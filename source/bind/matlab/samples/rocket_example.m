% Define the Python environment
pythonExe = '/Users/mleader/miniconda3/envs/cea/bin/python'; % Replace with your Python path
pyenv('Version', pythonExe);

clear; clc;

cea = py.importlib.import_module('cea');
addpath(char(cea.matlab_dir()));

reac_names = ["H2(L)", "O2(L)"];
t_reac = [20.27, 90.17];
fuel_amounts = [1.0, 0.0];
oxid_amounts = [0.0, 1.0];
pi_p = [10.0, 100.0];
subar = [1.58];
supar = [25.0];

solution = rocket_solve(reac_names, 53.3172, ...
    pi_p=pi_p, subar=subar, supar=supar, ...
    T_reac=t_reac, ...
    fuel_amounts=fuel_amounts, oxid_amounts=oxid_amounts, ...
    of_ratio=5.55157, iac=true);

fprintf('Converged: %d\n', solution.converged);
fprintf('Stations: %d\n', solution.num_pts);
fprintf('Chamber T [K]: %.3f\n', solution.T(1));
fprintf('Exit P [bar]: %.6f\n', solution.P(end));
fprintf('Exit Isp_vac [m/s]: %.3f\n', solution.Isp_vacuum(end));
