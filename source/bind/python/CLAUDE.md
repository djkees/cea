## Python Binding Development

When modifying Python bindings:
1. Changes to `*.pyx` or `*.pxd` files require rebuild
2. Editable installs do not auto-rebuild
3. Rebuild command: `make py-rebuild` (requires Ninja on PATH)
4. Test command: `pytest source/bind/python/tests`
5. Ensure `numpy` is installed in the active Python environment
