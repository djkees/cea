"""Check that the legacy .inp interface converts shock initial temperatures to kelvin.

The same shock case is run with the initial temperature written as 300 K in
kelvin, Celsius, Rankine and Fahrenheit, both on the reactants and as a
``problem`` ``t`` schedule. Every variant must print T = 300.000 K for the
initial gas and produce output identical to the kelvin case.

The case requests incident and reflected shocks in both equilibrium and frozen
modes so every shock branch in the legacy interface is exercised.

Usage: python temperature_units.py <cea executable> <thermo.lib> <trans.lib>
"""

import subprocess
import sys
import tempfile
from pathlib import Path

REACTANTS = ("H2", 0.050), ("O2", 0.050), ("Ar", 0.900)

# Temperature expressions equal to 300 K
T_EXPRESSIONS = {
    "k": "t(k)=300",
    "c": "t(c)=26.85",
    "r": "t(r)=540",
    "f": "t,f=80.33",
}

BRANCH_HEADERS = (
    "SHOCKED GAS (2)--INCIDENT--EQUILIBRIUM",
    "SHOCKED GAS (2)--INCIDENT--FROZEN",
    "SHOCKED GAS (5)--REFLECTED--EQUILIBRIUM",
    "SHOCKED GAS (5)--REFLECTED--FROZEN",
)


def make_input(reactant_t, problem_t=None):
    lines = ["reac"]
    for name, moles in REACTANTS:
        lines.append(f"  name= {name}  moles= {moles:.3f}  {reactant_t}")
    problem_t_field = f" {problem_t}," if problem_t else ""
    lines.append(f"problem case=7 p,mmhg=10,{problem_t_field} shock u1=1100,1400,")
    lines.append("  incd eql froz refl eql froz")
    lines.append("output siunits")
    lines.append("end")
    return "\n".join(lines) + "\n"


def run_case(cea_exe, thermo, trans, work_dir, name, text):
    inp = work_dir / f"{name}.inp"
    inp.write_text(text)
    subprocess.run([cea_exe, "-t", thermo, "-r", trans, name], cwd=work_dir, check=True)
    out = inp.with_suffix(".out").read_text()
    # Drop the echoed input, which differs between variants by construction
    start = out.find("SHOCK WAVE PARAMETERS")
    if start < 0:
        raise RuntimeError(f"{name}: no shock results found in output")
    return out[start:]


def initial_temperatures(results):
    temps = []
    lines = results.splitlines()
    for i, line in enumerate(lines):
        if line.startswith("INITIAL GAS (1)"):
            for block_line in lines[i + 1:]:
                if block_line.startswith("T, K"):
                    temps.extend(block_line.split()[2:])
                    break
    return temps


def main():
    if len(sys.argv) != 4:
        print(__doc__)
        return 2
    cea_exe, thermo, trans = (str(Path(arg).resolve()) for arg in sys.argv[1:])

    cases = {}
    for unit, expr in T_EXPRESSIONS.items():
        cases[f"reac_{unit}"] = make_input(expr)
        cases[f"prob_{unit}"] = make_input(T_EXPRESSIONS["k"], problem_t=expr)

    failures = []
    with tempfile.TemporaryDirectory() as tmp:
        work_dir = Path(tmp)
        results = {name: run_case(cea_exe, thermo, trans, work_dir, name, text)
                   for name, text in cases.items()}

    reference = results["reac_k"]
    for header in BRANCH_HEADERS:
        if header not in reference:
            failures.append(f"reac_k: missing branch '{header}'")

    for name, result in results.items():
        temps = initial_temperatures(result)
        if not temps or any(t != "300.000" for t in temps):
            failures.append(f"{name}: initial T, K = {temps}, expected 300.000")
        if result != reference:
            failures.append(f"{name}: shock results differ from reac_k")
        print(f"{name:8s} initial T, K = {' '.join(temps)}")

    if failures:
        print("FAILED:")
        for failure in failures:
            print(f"  {failure}")
        return 1
    print(f"All {len(results)} temperature-unit variants match the kelvin case.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
