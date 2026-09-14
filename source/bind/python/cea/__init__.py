__version__ = "3.3.4"

# initialize libcea, loading in the default data files
from cea.lib.libcea import init as libcea_init
import os as _os
import warnings as _warnings

if not _os.environ.get("CEA_SKIP_INIT"):
    libcea_init()

# cleanup the root namespace
del libcea_init
del _os

# expose all public methods in the library to the root package.
from cea.lib.libcea import *
from cea.lib.libcea import __all__ as _libcea_all
from cea.lib.libcea import _version as lib_version
from cea.lib.libcea import _version_major as lib_version_major
from cea.lib.libcea import _version_minor as lib_version_minor
from cea.lib.libcea import _version_patch as lib_version_patch

from .constants import R
# Allow attribute-style access (e.g., `cea.units.atm_to_bar`)
from . import units as units


def eq_solve(*args, **kwargs):
    from .lib.libcea import eq_solve as _libcea_eq_solve

    _warnings.warn(
        "cea.eq_solve is deprecated; use cea.matlab.eq_solve instead.",
        DeprecationWarning,
        stacklevel=2,
    )
    return _libcea_eq_solve(*args, **kwargs)


def matlab_dir():
    """
    Return the path to CEA's native MATLAB wrapper functions.

    Add the returned directory to the MATLAB path to call ``eq_solve``,
    ``rocket_solve``, ``shock_solve``, and ``detonation_solve`` directly
    with plain MATLAB types, instead of using ``cea.matlab`` with
    ``py.list``/``py.numpy.array``::

        cea = py.importlib.import_module('cea');
        addpath(char(cea.matlab_dir()));

    Resolves the packaged ``cea/matlab`` directory (present when installed
    via pip) if found, otherwise falls back to ``source/bind/matlab`` for
    a source checkout that hasn't been installed.

    Returns
    -------
    str
        Path to the directory containing the MATLAB wrapper functions.

    Raises
    ------
    FileNotFoundError
        If no MATLAB wrapper directory can be found.
    """
    import importlib.resources as _resources
    import os as _os_local

    try:
        pkg_matlab = _resources.files("cea").joinpath("matlab")
        with _resources.as_file(pkg_matlab) as pkg_path:
            if _os_local.path.isfile(_os_local.path.join(pkg_path, "eq_solve.m")):
                return str(pkg_path)
    except Exception:
        pass

    # Dev-tree fallback: walk up from this package looking for
    # source/bind/matlab (mirrors the thermo.lib dev-tree search in CEA.pyx).
    search_root = _os_local.path.dirname(_os_local.path.abspath(__file__))
    for _ in range(6):
        dev_candidate = _os_local.path.join(search_root, "source", "bind", "matlab")
        if _os_local.path.isfile(_os_local.path.join(dev_candidate, "eq_solve.m")):
            return dev_candidate
        search_root = _os_local.path.dirname(search_root)

    raise FileNotFoundError(
        "CEA MATLAB wrapper directory not found. Expected either a "
        "packaged 'cea/matlab' directory or 'source/bind/matlab' in a "
        "source checkout."
    )


__all__ = list(_libcea_all)
__all__.extend([
    "__version__",
    "lib_version",
    "lib_version_major",
    "lib_version_minor",
    "lib_version_patch",
    "R",
    "units",
    "matlab_dir",
])

del _libcea_all
