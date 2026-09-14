CEA MATLAB Binding
==================
MATLAB support is provided through the Python package namespace rather than a
separate compiled MATLAB extension. Point MATLAB at a Python interpreter with
the installed ``cea`` package, then add this directory (``source/bind/matlab``)
to your MATLAB path to use the native-MATLAB wrapper functions below.

Recommended approach:
- Import the root package for constants and units:
  ``py.importlib.import_module('cea')``
- Add its MATLAB wrapper directory to the MATLAB path with
  ``addpath(char(cea.matlab_dir()))`` — this resolves the packaged
  ``cea/matlab`` directory (installed via pip) or, in a source checkout,
  falls back to this directory. No path to find or type.
- Then call the plain-MATLAB wrapper functions:
  ``eq_solve(...)``
  ``rocket_solve(...)``
  ``shock_solve(...)``
  ``detonation_solve(...)``
- Each wrapper accepts species names as a MATLAB string array or cellstr and
  numeric arguments as plain MATLAB doubles/vectors (no ``py.list`` or
  ``py.numpy.array`` needed), and returns a plain MATLAB struct — numeric
  fields as doubles, ``mass_fractions``/``mole_fractions`` as a
  ``containers.Map`` keyed by species name — instead of a Python namespace.
  These wrappers call through to ``cea.matlab.eq_solve`` and its siblings
  (see ``source/bind/python/cea/matlab.py``), which return the same flat
  namespace of scalars, NumPy arrays, and dictionaries these wrappers unwrap.
- The wrapper module is pure Python/MATLAB. The ``CEA_ENABLE_BIND_MATLAB``
  CMake option is a compatibility knob for MATLAB-via-Python workflows; it
  does not build a separate native MATLAB extension.
- Example scripts live in ``source/bind/matlab/samples/``:
  ``equilibrium_example.m``, ``rocket_example.m``, ``shock_example.m``,
  ``detonation_example.m``.

If you need a native MATLAB interface, please open an issue or contribute fixes.
