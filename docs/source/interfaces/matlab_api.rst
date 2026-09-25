MATLAB
******

CEA provides two layers of MATLAB support, both reached through MATLAB's
Python bridge rather than a separate compiled MATLAB extension:

* A native-MATLAB wrapper layer (``.m`` functions in
  ``source/bind/matlab/``) — the recommended entry point. It accepts plain
  MATLAB types (string arrays/cellstr for species names, double
  scalars/vectors for numeric arguments) and returns a plain MATLAB struct,
  so no ``py.*`` syntax is needed beyond the one-time ``pyenv``/import setup.
* The underlying :mod:`cea.matlab` Python module, which the ``.m`` wrappers
  call into. It can also be called directly from MATLAB using ``py.*``
  syntax, if you need something the ``.m`` wrappers don't expose.

Native MATLAB Wrappers
=======================

Install the Python package first, point MATLAB at that Python interpreter
with ``pyenv(...)``, then import :mod:`cea` (for enums/constants such as
``cea.TP`` and for :mod:`cea.units`) and add its MATLAB wrapper directory to
the MATLAB path with :func:`cea.matlab_dir`::

    pyenv('Version', 'C:\path\to\python.exe');
    cea = py.importlib.import_module('cea');
    addpath(char(cea.matlab_dir()));

:func:`cea.matlab_dir` resolves the wrapper directory from the installed
``cea`` package — no folder path to find or type, whether ``cea`` was
installed via ``pip`` or built from source.

.. autofunction:: cea.matlab_dir

Available wrapper functions:

* ``eq_solve`` for equilibrium problems
* ``rocket_solve`` for rocket performance problems
* ``shock_solve`` for incident/reflected shock problems
* ``detonation_solve`` for detonation problems

Each function accepts species names as a MATLAB string array or cellstr
(e.g. ``["H2","O2"]`` or ``{'H2','O2'}``) and every numeric argument as a
plain MATLAB double scalar or vector — the wrapper converts these to
``py.list``/``py.numpy.array`` internally before calling into
:mod:`cea.matlab`. Name-value arguments match the corresponding
:mod:`cea.matlab` function's keyword arguments documented below.

The returned value is a plain MATLAB struct: numeric fields (scalars,
vectors, or matrices, matching the shape :mod:`cea.matlab` returns) come
back as MATLAB ``double``, and ``mass_fractions``/``mole_fractions`` come
back as a ``containers.Map`` keyed by species name (species names such as
``"e-"`` are not always valid MATLAB struct field names, hence the Map).

See ``help eq_solve`` (or ``rocket_solve``, ``shock_solve``,
``detonation_solve``) in MATLAB for each function's full argument and
result-field list, and ``source/bind/matlab/samples/`` for complete
examples: ``equilibrium_example.m``, ``rocket_example.m``,
``shock_example.m``, ``detonation_example.m``.

Underlying Python Module
=========================

The :mod:`cea.matlab` module provides a MATLAB-friendly compatibility layer
on top of the Python package, returning flat namespace-style results
composed of Python scalars, NumPy arrays, and dictionaries. The native
``.m`` wrapper functions above call this module directly and are the
recommended way to use it from MATLAB; call it directly with ``py.*``
syntax only if you need lower-level access.

.. autofunction:: cea.matlab.eq_solve

.. autofunction:: cea.matlab.rocket_solve

.. autofunction:: cea.matlab.shock_solve

.. autofunction:: cea.matlab.detonation_solve
