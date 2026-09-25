#include "cea.h"

#include <stddef.h>

#define LEN(x) (sizeof(x) / sizeof((x)[0]))
#define R 8314.51

int main(void)
{
    // CEA_INVALID_FILENAME: thermo database file cannot be located, before any init.
    if (cea_init_thermo("not-a-real-thermo-file.inp") != CEA_INVALID_FILENAME) return 1;

    if (cea_init() != CEA_SUCCESS) return 2;

    // Equilibrium solver setup, reused by the eq_type/eq_size/property-type checks below.
    const cea_string reactants[] = {"H2", "O2"};
    const cea_string products[] = {"H2", "O2", "H2O", "H", "O", "OH"};
    cea_mixture reac = NULL;
    cea_mixture prod = NULL;
    if (cea_mixture_create(&reac, LEN(reactants), reactants) != CEA_SUCCESS) return 3;
    if (cea_mixture_create(&prod, LEN(products), products) != CEA_SUCCESS) return 4;

    cea_eqsolver solver = NULL;
    cea_solver_opts opts;
    cea_solver_opts_init(&opts);
    opts.reactants = reac;
    if (cea_eqsolver_create_with_options(&solver, prod, opts) != CEA_SUCCESS) return 5;

    cea_eqsolution soln = NULL;
    if (cea_eqsolution_create(&soln, solver) != CEA_SUCCESS) return 6;

    // CEA_INVALID_EQUILIBRIUM_TYPE: eq_type outside the CEA_TP..CEA_SV range.
    {
        const cea_real amounts[] = {1.0, 1.0};
        if (cea_eqsolver_solve(solver, 999, 3000.0, 1.0, amounts, soln) != CEA_INVALID_EQUILIBRIUM_TYPE) return 7;
    }

    // CEA_INVALID_EQUILIBRIUM_SIZE_TYPE: eq_variable outside CEA_NUM_REACTANTS..CEA_MAX_EQUATIONS.
    {
        cea_int value;
        if (cea_eqsolver_get_size(solver, 999, &value) != CEA_INVALID_EQUILIBRIUM_SIZE_TYPE) return 8;
    }

    // CEA_INVALID_PROPERTY_TYPE: prop_type outside the CEA_PROPERTY_TYPE_ENUM range.
    {
        cea_real value;
        if (cea_eqsolution_get_property(soln, 999, &value) != CEA_INVALID_PROPERTY_TYPE) return 9;
    }

    cea_eqsolution_destroy(&soln);
    cea_eqsolver_destroy(&solver);
    cea_mixture_destroy(&prod);
    cea_mixture_destroy(&reac);

    // CEA_FORTRAN_ABORT: a Fortran-side `call abort(...)` (rocket.f90's supersonic area
    // ratio check) is caught by the C recovery layer and surfaced as an error code instead
    // of terminating the process. Mirrors the rocket scenario in
    // source/bind/python/tests/test_abort_recovery.py.
    {
        const cea_string rocket_reactants[] = {"H2(L)", "O2(L)"};
        const cea_real reactant_temps[] = {20.27, 90.17};
        const cea_real fuel_weights[] = {1.0, 0.0};
        const cea_real oxidant_weights[] = {0.0, 1.0};
        const cea_int nr = LEN(rocket_reactants);
        const cea_string omitted_products[] = {""};

        cea_mixture rocket_reac = NULL;
        cea_mixture rocket_prod = NULL;
        if (cea_mixture_create(&rocket_reac, nr, rocket_reactants) != CEA_SUCCESS) return 10;
        if (cea_mixture_create_from_reactants(&rocket_prod, nr, rocket_reactants, 0, omitted_products) !=
            CEA_SUCCESS) {
            return 11;
        }

        cea_rocket_solver rocket_solver = NULL;
        if (cea_rocket_solver_create_with_reactants(&rocket_solver, rocket_prod, rocket_reac) != CEA_SUCCESS) {
            return 12;
        }

        cea_rocket_solution rocket_soln = NULL;
        if (cea_rocket_solution_create(&rocket_soln, rocket_solver) != CEA_SUCCESS) return 13;

        cea_real weights[2];
        cea_mixture_of_ratio_to_weights(rocket_reac, nr, oxidant_weights, fuel_weights, 5.55157, weights);

        cea_real hc;
        cea_mixture_calc_property_multitemp(rocket_reac, CEA_ENTHALPY, nr, weights, nr, reactant_temps, &hc);
        hc = hc / R;

        const cea_real pip[] = {10.0};
        const cea_real subar[] = {1.58};
        const cea_real supar[] = {1.0}; // <= 1.0 is invalid for a supersonic area ratio

        if (cea_rocket_solver_solve_iac(
                rocket_solver, rocket_soln, weights, 53.3172, pip, 1, subar, 1, supar, 1, 0, hc, true, 0.0, false) !=
            CEA_FORTRAN_ABORT) {
            return 14;
        }

        cea_rocket_solution_destroy(&rocket_soln);
        cea_rocket_solver_destroy(&rocket_solver);
        cea_mixture_destroy(&rocket_prod);
        cea_mixture_destroy(&rocket_reac);
    }

    return 0;
}
