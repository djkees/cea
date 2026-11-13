
add_library(cea_abort_support STATIC cea_abort_support.c)
target_include_directories(cea_abort_support PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)

add_installed_library(cea_bindc SHARED bindc.F90 cea_recovery.c cea_abort_support.c)
#include(../cmake/CompilerFlags.cmake)
project_enable_fortran_std(cea_bindc)
target_link_libraries(cea_bindc
    PRIVATE
        cea::core
        fbasics::core
)
target_include_directories(cea_bindc PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
install(FILES cea.h cea_enum.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/cea/bindc)

target_link_libraries(cea PRIVATE cea_abort_support)
if(TARGET cea_core_test)
    target_link_libraries(cea_core_test cea_abort_support)
endif()
if(WIN32)
    # on windows, several dll either need to be installed on the target
    # machine, or they need to be statically linked. linking seemed easier than
    # finding the path to the various DLLs and installing them.
    # If the intel compilers are used, static link the intel runtime
    # The appropriate intel flags are different on linux and windows, because

    if (CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM" OR CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
        target_link_options(cea_bindc
                            PRIVATE "-libs:static")
        set_target_properties(cea_bindc PROPERTIES
            WINDOWS_EXPORT_ALL_SYMBOLS ON
            PREFIX ""
            MSVC_RUNTIME_LIBRARY "MultiThreaded"
        )
    else()
        target_link_options(cea_bindc
                            PRIVATE "-static-libgfortran"
                            PRIVATE "-static-libgcc"
                            PRIVATE "-static-libquadmath")
    endif()
elseif (CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM" OR CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
    target_link_options(cea_bindc
                        PRIVATE "-static-intel")
endif()

if (CEA_BUILD_TESTING)

    add_executable(cea_bindc_reactant_temperature_range tests/reactant_temperature_range.c)
    target_link_libraries(cea_bindc_reactant_temperature_range PRIVATE cea::bindc)
    add_test(
        NAME cea_bindc_reactant_temperature_range
        COMMAND cea_bindc_reactant_temperature_range
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

    add_executable(cea_bindc_rp1311_ex1 samples/rp1311_example1.c)
    target_link_libraries(cea_bindc_rp1311_ex1 PRIVATE cea::bindc)
    add_test(
        NAME cea_bindc_rp1311_ex1
        COMMAND cea_bindc_rp1311_ex1
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

    add_executable(cea_bindc_rp1311_ex2 samples/rp1311_example2.c)
    target_link_libraries(cea_bindc_rp1311_ex2 PRIVATE cea::bindc)
    add_test(
        NAME cea_bindc_rp1311_ex2
        COMMAND cea_bindc_rp1311_ex2
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

    add_executable(cea_bindc_rp1311_ex3 samples/rp1311_example3.c)
    target_link_libraries(cea_bindc_rp1311_ex3 PRIVATE cea::bindc)
    add_test(
        NAME cea_bindc_rp1311_ex3
        COMMAND cea_bindc_rp1311_ex3
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

    add_executable(cea_bindc_rp1311_ex5 samples/rp1311_example5.c)
    target_link_libraries(cea_bindc_rp1311_ex5 PRIVATE cea::bindc)
    add_test(
        NAME cea_bindc_rp1311_ex5
        COMMAND cea_bindc_rp1311_ex5
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

    add_executable(cea_bindc_rp1311_ex6 samples/rp1311_example6.c)
    target_link_libraries(cea_bindc_rp1311_ex6 PRIVATE cea::bindc)
    add_test(
        NAME cea_bindc_rp1311_ex6
        COMMAND cea_bindc_rp1311_ex6
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

    add_executable(cea_bindc_rp1311_ex7 samples/rp1311_example7.c)
    target_link_libraries(cea_bindc_rp1311_ex7 PRIVATE cea::bindc)
    add_test(
        NAME cea_bindc_rp1311_ex7
        COMMAND cea_bindc_rp1311_ex7
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

    add_executable(cea_bindc_rp1311_ex8 samples/rp1311_example8.c)
    target_link_libraries(cea_bindc_rp1311_ex8 PRIVATE cea::bindc)
    add_test(
        NAME cea_bindc_rp1311_ex8
        COMMAND cea_bindc_rp1311_ex8
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

    add_executable(cea_bindc_rp1311_ex9 samples/rp1311_example9.c)
    target_link_libraries(cea_bindc_rp1311_ex9 PRIVATE cea::bindc)
    add_test(
        NAME cea_bindc_rp1311_ex9
        COMMAND cea_bindc_rp1311_ex9
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

    add_executable(cea_bindc_shock_last_valid samples/shock_last_valid.c)
    target_link_libraries(cea_bindc_shock_last_valid PRIVATE cea::bindc)
    add_test(
        NAME cea_bindc_shock_last_valid
        COMMAND cea_bindc_shock_last_valid
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

    # The RP-1311 samples only print results, so check key printed values
    # (leading digits, enough to catch a changed answer). PASS_REGULAR_EXPRESSION
    # replaces the exit-code check, and a crash prints no match, so it still fails.
    set_tests_properties(cea_bindc_rp1311_ex1 PROPERTIES PASS_REGULAR_EXPRESSION
        [=[3000\.00 +1\.01 +1\.00 +34\.2962.* 6\.637[0-9]*e\+02 +1\.681[0-9]*e\+00.*2000\.00 +0\.01 +1\.50 +22\.8525.* -1\.017[0-9]*e\+02 +6\.076[0-9]*e-01]=])
    set_tests_properties(cea_bindc_rp1311_ex2 PROPERTIES PASS_REGULAR_EXPRESSION
        [=[34\.30 +1\.00 +3000\.00 +6\.635[0-9]*e\+02 +1\.681[0-9]+ +0\.9357.*34\.30 +0\.01 +3000\.00 +2\.647[0-9]*e\+03 +3\.715[0-9]+ +0\.9482]=])
    set_tests_properties(cea_bindc_rp1311_ex5 PROPERTIES PASS_REGULAR_EXPRESSION
        [=[34\.473652 +2722\.9[0-9]* .*0\.344737 +2540\.8[0-9]* ]=])
    set_tests_properties(cea_bindc_rp1311_ex6 PROPERTIES PASS_REGULAR_EXPRESSION
        [=[3605\.0[0-9]* +18\.01[0-9]* +2775\.3[0-9]* ]=])
    set_tests_properties(cea_bindc_rp1311_ex7 PROPERTIES PASS_REGULAR_EXPRESSION
        [=[2268\.18[0-9]* +1\.92[0-9]* +537\.1[0-9]*.*3253\.28[0-9]* +6\.88[0-9]* +598\.7[0-9]*]=])
    set_tests_properties(cea_bindc_rp1311_ex8 PROPERTIES PASS_REGULAR_EXPRESSION
        [=[3383\.84[0-9]* +53\.31[0-9]* +1\.1447 +12\.7157 .* 2\.3323e\+03.*2567\.34[0-9]* +5\.331[0-9]* +1\.1725 +13\.1231 +2\.1487 +2\.3503e\+00 +2\.9674e\+03.*1468\.15[0-9]* +0\.204[0-9]* +1\.2428 +13\.2071 +3\.8482 +2\.5000e\+01 +4\.1244e\+03]=])
    set_tests_properties(cea_bindc_rp1311_ex9 PROPERTIES PASS_REGULAR_EXPRESSION
        [=[T, K +3383\.84 +3375\.90 +3341\.08 +3179\.57.*Isp, vac\. +0\.00 +0\.00 +3995\.48 +2877\.05 +3484\.16 +4149\.45 +4530\.88 +4347\.67 +4486\.63 +4554\.33]=])

endif()
