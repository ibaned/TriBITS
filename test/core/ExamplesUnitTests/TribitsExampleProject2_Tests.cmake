########################################################################
# TribitsExampleProject2
########################################################################


set(TribitsExampleProject2_COMMON_CONFIG_ARGS
  ${SERIAL_PASSTHROUGH_CONFIGURE_ARGS}
  -DTribitsExProj2_TRIBITS_DIR=${${PROJECT_NAME}_TRIBITS_DIR}
  -DTribitsExProj2_ENABLE_Fortran=${${PROJECT_NAME}_ENABLE_Fortran}
  )


########################################################################


if (NOT "$ENV{TRIBITS_ADD_ENV_PATH_HACK_FOR_TPL1}" STREQUAL "")
  set(TRIBITS_ADD_ENV_PATH_HACK_FOR_TPL1_DEFAULT
    $ENV{TRIBITS_ADD_ENV_PATH_HACK_FOR_TPL1})
else()
  set($ENV{TRIBITS_ADD_ENV_PATH_HACK_FOR_TPL1} OFF)
endif()
advanced_set(TRIBITS_ADD_ENV_PATH_HACK_FOR_TPL1
  ${TRIBITS_ADD_ENV_PATH_HACK_FOR_TPL1_DEFAULT} CACHE BOOL
  "Set to TRUE to add LD_LIBRARY_PATH to libtpl1.so for platforms where RPATH not working")

function(set_ENV_PATH_HACK_FOR_TPL1_ARG sharedOrStatic)
  if (sharedOrStatic STREQUAL "SHARED")
    if (WIN32)
      set(ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG_ON
        ENVIRONMENT
	LD_LIBRARY_PATH=${TribitsExampleProject2_Tpls_install_${sharedOrStatic}_DIR}/install_tpl1/lib)
    else()
      set(ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG_ON
        ENVIRONMENT
	PATH=${TribitsExampleProject2_Tpls_install_${sharedOrStatic}_DIR}/install_tpl1/bin:$ENV{PATH})
    endif()
  else()
    set(ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG_ON "")
  endif()
  if (TRIBITS_ADD_ENV_PATH_HACK_FOR_TPL1)
    set(ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG
      ${ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG_ON})
  else()
    set(ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG "")
  endif()
  set(ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG_ON
    ${ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG_ON}
    PARENT_SCOPE)
  set(ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG
    ${ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG}
    PARENT_SCOPE)
endfunction()
set_ENV_PATH_HACK_FOR_TPL1_ARG(STATIC)
set_ENV_PATH_HACK_FOR_TPL1_ARG(SHARED)
# NOTE: Above, we have to set LD_LIBRARY_PATH to pick up the
# libtpl1.so because CMake 3.17.5 and 3.21.2 with the GitHub Actions
# Umbuntu build is refusing to put in the RPATH for libtpl1.so into
# libsimplecxx.so even through CMAKE_INSTALL_RPATH_USE_LINK_PATH=ON is
# set.  This is not needed for the RHEL 7 builds that I have tried where
# CMake is behaving correctly and putting in RPATH correctly.  But because
# I can't log into this system, it is very hard and time consuming to
# debug this so I am just giving up at this point.


########################################################################


macro(TribitsExampleProject2_test_setup_header)
  if (sharedOrStatic STREQUAL "SHARED")
    set(buildSharedLibsArg -DBUILD_SHARED_LIBS=ON)
    if (CYGWIN)
      set(libext ".dll.a")
      set(libextregex "[.]dll.a")
    else()
      set(libext ".so")
      set(libextregex "[.]so")
    endif()
  elseif (sharedOrStatic STREQUAL "STATIC")
    set(buildSharedLibsArg -DBUILD_SHARED_LIBS=OFF)
    set(libext ".a")
    set(libextregex "[.]a")
  else()
    message(FATAL_ERROR "Invalid value for sharedOrStatic='${sharedOrStatic}'!")
  endif()
endmacro()


########################################################################


function(TribitsExampleProject2_find_tpl_parts  sharedOrStatic  findingTplsMethod)

  TribitsExampleProject2_test_setup_header()

  set(tplInstallBaseDir
    "${TribitsExampleProject2_Tpls_install_${sharedOrStatic}_DIR}")

  set(testNameSuffix "")
  set(tplLibAndIncDirsArgs "")
  set(cmakePrefixPathCacheArg "")
  set(cmakePrefixPathEnvArg "")

  set(cmakePrefixPath
    "${tplInstallBaseDir}/install_tpl4<semicolon>${tplInstallBaseDir}/install_tpl3<semicolon>${tplInstallBaseDir}/install_tpl2<semicolon>${tplInstallBaseDir}/install_tpl1"
    )

  set(allTplsNoPrefindArgs
    "-DTpl1_ALLOW_PACKAGE_PREFIND=OFF"
    "-DTpl2_ALLOW_PACKAGE_PREFIND=OFF"
    "-DTpl3_ALLOW_PACKAGE_PREFIND=OFF"
    "-DTpl4_ALLOW_PACKAGE_PREFIND=OFF"
    )

  if (findingTplsMethod STREQUAL "TPL_LIBRARY_AND_INCLUDE_DIRS")
    set(tplLibAndIncDirsArgs
      "-DTpl1_INCLUDE_DIRS=${tplInstallBaseDir}/install_tpl1/include"
      "-DTpl1_LIBRARY_DIRS=${tplInstallBaseDir}/install_tpl1/lib"
      "-DTpl2_INCLUDE_DIRS=${tplInstallBaseDir}/install_tpl2/include"
      "-DTpl2_LIBRARY_DIRS=${tplInstallBaseDir}/install_tpl2/lib"
      "-DTpl3_INCLUDE_DIRS=${tplInstallBaseDir}/install_tpl3/include"
      "-DTpl3_LIBRARY_DIRS=${tplInstallBaseDir}/install_tpl3/lib"
      "-DTpl4_INCLUDE_DIRS=${tplInstallBaseDir}/install_tpl4/include"
      )
    set(searchingTplLibAndINcDirsRegexes
      "Searching for libs in Tpl1_LIBRARY_DIRS='${tplInstallBaseDir}/install_tpl1/lib'"
      "Searching for headers in Tpl1_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl1/include'"
      "Searching for libs in Tpl2_LIBRARY_DIRS='${tplInstallBaseDir}/install_tpl2/lib'"
      "Searching for headers in Tpl2_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl2/include'"
      "Searching for libs in Tpl3_LIBRARY_DIRS='${tplInstallBaseDir}/install_tpl3/lib'"
      "Searching for headers in Tpl3_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl3/include'"
      "Searching for headers in Tpl4_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl4/include"
      )
  elseif (findingTplsMethod STREQUAL "CMAKE_PREFIX_PATH_CACHE")
    set(testNameSuffix "_CMAKE_PREFIX_PATH_CACHE")
    set(cmakePrefixPathCacheArg "-DCMAKE_PREFIX_PATH=${cmakePrefixPath}")
    set(tplLibAndIncDirsArgs "${allTplsNoPrefindArgs}")
    set(searchingTplLibAndINcDirsRegexes "")
  elseif (findingTplsMethod STREQUAL "CMAKE_PREFIX_PATH_ENV")
    set(testNameSuffix "_CMAKE_PREFIX_PATH_ENV")
    string(REPLACE "<semicolon>" ":" cmakePrefixPathEnv "${cmakePrefixPath}")
    set(cmakePrefixPathEnvArg ENVIRONMENT CMAKE_PREFIX_PATH=${cmakePrefixPathEnv})
    set(tplLibAndIncDirsArgs "${allTplsNoPrefindArgs}")
    set(searchingTplLibAndINcDirsRegexes "")
  else()
    message(FATAL_ERROR
      "Error, findingTplsMethod='${findingTplsMethod}' is invalid!")
  endif()

  # Allow skipping delete of src and build dirs to aid in debugging
  if (TribitsExampleProject2_Tests_SKIP_DELETE_SRC_AND_BUILD)
    set(deleteSrcAndBuildDirsCmndArgs
      CMND ${CMAKE_COMMAND} ARGS -E echo "Skip deleting src and build dirs!")
  else()
    set(deleteSrcAndBuildDirsCmndArgs
      CMND ${CMAKE_COMMAND} ARGS -E rm -rf TribitsExampleProject2 BUILD)
  endif()

  set(testNameBase ${CMAKE_CURRENT_FUNCTION}_${sharedOrStatic}${testNameSuffix})
  set(testName ${PACKAGE_NAME}_${testNameBase})
  set(testDir "${CMAKE_CURRENT_BINARY_DIR}/${testName}")

  tribits_add_advanced_test( ${testNameBase}
    OVERALL_WORKING_DIRECTORY TEST_NAME
    OVERALL_NUM_MPI_PROCS 1
    EXCLUDE_IF_NOT_TRUE  NINJA_EXE
    LIST_SEPARATOR "<semicolon>"

    ${cmakePrefixPathEnvArg}

    TEST_0
      MESSAGE "Copy TribitsExampleProject2 so we can delete it after the install"
      CMND cp
      ARGS -r ${${PROJECT_NAME}_TRIBITS_DIR}/examples/TribitsExampleProject2 .

    TEST_1
      MESSAGE "Configure TribitsExampleProject2 against pre-installed Tpl1"
      WORKING_DIRECTORY  BUILD
      CMND ${CMAKE_COMMAND}
      ARGS
        ${TribitsExampleProject2_COMMON_CONFIG_ARGS}
        -GNinja
        -DCMAKE_BUILD_TYPE=DEBUG
        -DTPL_ENABLE_Tpl1=ON
        -DTPL_ENABLE_Tpl2=ON
        -DTPL_ENABLE_Tpl3=ON
        -DTPL_ENABLE_Tpl4=ON
        ${tplLibAndIncDirsArgs}
        ${cmakePrefixPathCacheArg}
        -DTribitsExProj2_ENABLE_TESTS=ON
        -DCMAKE_INSTALL_PREFIX=${testDir}/install
        -DTribitsExProj2_ENABLE_ALL_PACKAGES=ON
        ../TribitsExampleProject2
      PASS_REGULAR_EXPRESSION_ALL
        "Final set of enabled top-level packages:  Package1 Package2 Package3"
        "Final set of enabled external packages/TPLs:  Tpl1 Tpl2 Tpl3 Tpl4 4"

        "Tpl1_LIBRARY_NAMES='tpl1'"
        "Found lib '${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}'"
        "TPL_Tpl1_LIBRARIES='${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}'"
        "Found header '${tplInstallBaseDir}/install_tpl1/include/?/Tpl1.hpp'"
        "TPL_Tpl1_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl1/include'"

        "Tpl2_LIBRARY_NAMES='tpl2b[;]tpl2a'"
        "    Found lib '${tplInstallBaseDir}/install_tpl2/lib/libtpl2b${libextregex}'"
        "    Found lib '${tplInstallBaseDir}/install_tpl2/lib/libtpl2a${libextregex}'"
        "TPL_Tpl2_LIBRARIES='${tplInstallBaseDir}/install_tpl2/lib/libtpl2b${libextregex}[;]${tplInstallBaseDir}/install_tpl2/lib/libtpl2a${libextregex}'"
        "    Found header '${tplInstallBaseDir}/install_tpl2/include/?/Tpl2a.hpp'"
        "Found TPL 'Tpl2' include dirs '${tplInstallBaseDir}/install_tpl2/include'"
        "TPL_Tpl2_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl2/include'"

	"Tpl3_LIBRARY_NAMES='tpl3'"
        "    Found lib '${tplInstallBaseDir}/install_tpl3/lib/libtpl3${libextregex}'"
        "TPL_Tpl3_LIBRARIES='${tplInstallBaseDir}/install_tpl3/lib/libtpl3${libextregex}'"
        "    Found header '${tplInstallBaseDir}/install_tpl3/include/?/Tpl3.hpp'"
	"TPL_Tpl3_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl3/include'"

	"    Found header '${tplInstallBaseDir}/install_tpl4/include/?/Tpl4.hpp'"
	"TPL_Tpl4_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl4/include'"

        ${searchingTplLibAndINcDirsRegexes}

        "-- Configuring done"
        "-- Generating done"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_2
      MESSAGE "Check Package3Config.cmake for build tree"
      CMND cat ARGS BUILD/cmake_packages/Package3/Package3Config.cmake
      PASS_REGULAR_EXPRESSION_ALL
        "set[(]Package3_ENABLE_Package1 ON[)]"
        "set[(]Package3_ENABLE_Package2 ON[)]"
        "set[(]Package3_ENABLE_Tpl2 ON[)]"
        "set[(]Package3_ENABLE_Tpl4 ON[)]"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_3
      MESSAGE "Build verbose to check the link lines"
      WORKING_DIRECTORY  BUILD
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND ${CMAKE_COMMAND} ARGS --build . -v
      PASS_REGULAR_EXPRESSION_ALL
        "[-]o packages/package1/src/package1-prg .* ${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}"
        "[-]o packages/package2/src/package2-prg .* ${tplInstallBaseDir}/install_tpl3/lib/libtpl3${libextregex} +${tplInstallBaseDir}/install_tpl2/lib/libtpl2b${libextregex} +${tplInstallBaseDir}/install_tpl2/lib/libtpl2a${libextregex} +${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}"
        "[-]o packages/package3/src/package3-prg .* ${tplInstallBaseDir}/install_tpl3/lib/libtpl3${libextregex} +${tplInstallBaseDir}/install_tpl2/lib/libtpl2b${libextregex} +${tplInstallBaseDir}/install_tpl2/lib/libtpl2a${libextregex} +${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}"

    TEST_4
      MESSAGE "Run tests"
      WORKING_DIRECTORY  BUILD
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND ${CMAKE_CTEST_COMMAND} ARGS -VV
      PASS_REGULAR_EXPRESSION_ALL
        "Test.*Package1_Prg.*Passed"
        "Test.*Package2_Prg.*Passed"
        "Test.*Package3_Prg.*Passed"
        "100% tests passed, 0 tests failed out of 3"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_5
      MESSAGE "Install"
      WORKING_DIRECTORY BUILD
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND ${CMAKE_COMMAND} ARGS --build . --target install
      PASS_REGULAR_EXPRESSION_ALL
        "Tpl1Config.cmake"
        "Tpl2Config.cmake"
        "Tpl3Config.cmake"
        "Tpl4Config.cmake"
        "Package1Config.cmake"
        "Package1Targets.cmake"
        "Package2Config.cmake"
        "Package2Targets.cmake"
        "Package3Config.cmake"
        "Package3Targets.cmake"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_6
      MESSAGE "Check Package3Config.cmake in install tree"
      CMND cat ARGS install/lib/cmake/Package3/Package3Config.cmake
      PASS_REGULAR_EXPRESSION_ALL
        "set[(]Package3_ENABLE_Package1 ON[)]"
        "set[(]Package3_ENABLE_Package2 ON[)]"
        "set[(]Package3_ENABLE_Tpl2 ON[)]"
        "set[(]Package3_ENABLE_Tpl4 ON[)]"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_7
      MESSAGE "Delete source and build directory for TribitsExampleProject2"
      ${deleteSrcAndBuildDirsCmndArgs}

    ${ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG}

    ADDED_TEST_NAME_OUT ${testNameBase}_NAME
    )
  # NOTE: The above test ensures that the basic TriBITS TPL find operations
  # work and it does not call find_package().  It also ensures that the found
  # TPL libraries appear on the link line in the correct order.

  if (${testNameBase}_NAME)
    set(${testNameBase}_NAME ${${testNameBase}_NAME} PARENT_SCOPE)
    set(${testNameBase}_INSTALL_DIR "${testDir}/install" PARENT_SCOPE)
    set_tests_properties(${${testNameBase}_NAME}
      PROPERTIES DEPENDS ${TribitsExampleProject2_Tpls_install_${sharedOrStatic}_NAME} )
  endif()

endfunction()


TribitsExampleProject2_find_tpl_parts(STATIC  TPL_LIBRARY_AND_INCLUDE_DIRS)
TribitsExampleProject2_find_tpl_parts(SHARED  TPL_LIBRARY_AND_INCLUDE_DIRS)
TribitsExampleProject2_find_tpl_parts(STATIC  CMAKE_PREFIX_PATH_CACHE)
TribitsExampleProject2_find_tpl_parts(SHARED  CMAKE_PREFIX_PATH_CACHE)
TribitsExampleProject2_find_tpl_parts(STATIC  CMAKE_PREFIX_PATH_ENV)
TribitsExampleProject2_find_tpl_parts(SHARED  CMAKE_PREFIX_PATH_ENV)


########################################################################


function(TribitsExampleProject2_find_tpl_parts_no_optional_packages_tpls  sharedOrStatic)

  TribitsExampleProject2_test_setup_header()

  set(tplInstallBaseDir
    "${TribitsExampleProject2_Tpls_install_${sharedOrStatic}_DIR}")

  set(cmakePrefixPath
    "${tplInstallBaseDir}/install_tpl4<semicolon>${tplInstallBaseDir}/install_tpl3<semicolon>${tplInstallBaseDir}/install_tpl2<semicolon>${tplInstallBaseDir}/install_tpl1"
    )

  set(testNameBase ${CMAKE_CURRENT_FUNCTION}_${sharedOrStatic})
  set(testName ${PACKAGE_NAME}_${testNameBase})
  set(testDir "${CMAKE_CURRENT_BINARY_DIR}/${testName}")

  tribits_add_advanced_test( ${testNameBase}
    OVERALL_WORKING_DIRECTORY TEST_NAME
    OVERALL_NUM_MPI_PROCS 1
    EXCLUDE_IF_NOT_TRUE  NINJA_EXE
    LIST_SEPARATOR "<semicolon>"

    TEST_0
      MESSAGE "Configure TribitsExampleProject2 with all optional packages/tpls disabled"
      CMND ${CMAKE_COMMAND}
      ARGS
        ${TribitsExampleProject2_COMMON_CONFIG_ARGS}
        -GNinja
        -DCMAKE_BUILD_TYPE=DEBUG
	"-DCMAKE_PREFIX_PATH=${cmakePrefixPath}"
	-DTpl1_ALLOW_PACKAGE_PREFIND=OFF
	-DTpl2_ALLOW_PACKAGE_PREFIND=OFF
	-DTpl3_ALLOW_PACKAGE_PREFIND=OFF
	-DTpl4_ALLOW_PACKAGE_PREFIND=OFF
        -DTribitsExProj2_ENABLE_ALL_OPTIONAL_PACKAGES=OFF
        -DPackage3_ENABLE_Package2=OFF
        -DTribitsExProj2_ENABLE_TESTS=ON
        -DCMAKE_INSTALL_PREFIX=install
        -DTribitsExProj2_ENABLE_ALL_PACKAGES=ON
        ${${PROJECT_NAME}_TRIBITS_DIR}/examples/TribitsExampleProject2
      PASS_REGULAR_EXPRESSION_ALL
        "NOTE: Package3_ENABLE_Package2=OFF is already set so not enabling even though TribitsExProj2_ENABLE_Package2=ON is set"
        "Final set of enabled top-level packages:  Package1 Package2 Package3"
        "Final set of enabled external packages/TPLs:  Tpl1 Tpl2 2"
	"Final set of non-enabled external packages/TPLs:  Tpl3 Tpl4 2"

        "TPL_Tpl1_LIBRARIES='${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}'"
        "TPL_Tpl1_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl1/include'"

        "TPL_Tpl2_LIBRARIES='${tplInstallBaseDir}/install_tpl2/lib/libtpl2b${libextregex}[;]${tplInstallBaseDir}/install_tpl2/lib/libtpl2a${libextregex}'"
        "TPL_Tpl2_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl2/include'"

        "-- Configuring done"
        "-- Generating done"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_1
      MESSAGE "Check Package3Config.cmake for build tree"
      CMND cat ARGS cmake_packages/Package3/Package3Config.cmake
      PASS_REGULAR_EXPRESSION_ALL
        "set[(]Package3_ENABLE_Package1 ON[)]"
        "set[(]Package3_ENABLE_Package2 OFF[)]"
        "set[(]Package3_ENABLE_Tpl2 ON[)]"
        "set[(]Package3_ENABLE_Tpl4 OFF[)]"

    TEST_2
      MESSAGE "Build verbose to check the link line of Package3"
      CMND ${CMAKE_COMMAND} ARGS --build . -v
      PASS_REGULAR_EXPRESSION_ALL
        "[-]o packages/package1/src/package1-prg .* ${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}"
        "[-]o packages/package2/src/package2-prg .* ${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}"
        "[-]o packages/package3/src/package3-prg .* ${tplInstallBaseDir}/install_tpl2/lib/libtpl2b${libextregex} +${tplInstallBaseDir}/install_tpl2/lib/libtpl2a${libextregex} +${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}"

    TEST_3
      MESSAGE "Run tests"
      CMND ${CMAKE_CTEST_COMMAND} ARGS -VV
      PASS_REGULAR_EXPRESSION_ALL
        "Test.*Package1_Prg.*Passed"
        "Test.*Package2_Prg.*Passed"
        "Test.*Package3_Prg.*Passed"
        "100% tests passed, 0 tests failed out of 3"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_4
      MESSAGE "Install"
      CMND ${CMAKE_COMMAND} ARGS --build . --target install

    TEST_5
      MESSAGE "Check Package3Config.cmake in install tree"
      CMND cat ARGS install/lib/cmake/Package3/Package3Config.cmake
      PASS_REGULAR_EXPRESSION_ALL
        "set[(]Package3_ENABLE_Package1 ON[)]"
        "set[(]Package3_ENABLE_Package2 OFF[)]"
        "set[(]Package3_ENABLE_Tpl2 ON[)]"
        "set[(]Package3_ENABLE_Tpl4 OFF[)]"

    ADDED_TEST_NAME_OUT ${testNameBase}_NAME
    )
  # NOTE: The above test checks that things work with all optional packages
  # and TPLs disabled.

  if (${testNameBase}_NAME)
    set(${testNameBase}_NAME ${${testNameBase}_NAME} PARENT_SCOPE)
    set(${testNameBase}_INSTALL_DIR "${testDir}/install" PARENT_SCOPE)
    set_tests_properties(${${testNameBase}_NAME}
      PROPERTIES DEPENDS ${TribitsExampleProject2_Tpls_install_${sharedOrStatic}_NAME} )
  endif()

endfunction()

TribitsExampleProject2_find_tpl_parts_no_optional_packages_tpls(STATIC)
TribitsExampleProject2_find_tpl_parts_no_optional_packages_tpls(SHARED)


########################################################################


function(TribitsExampleProject2_explicit_tpl_vars  sharedOrStatic)

  TribitsExampleProject2_test_setup_header()

  set(testNameBase ${CMAKE_CURRENT_FUNCTION}_${sharedOrStatic})
  set(testName ${PACKAGE_NAME}_${testNameBase})
  set(testDir "${CMAKE_CURRENT_BINARY_DIR}/${testName}")

  set(tplInstallBaseDir
    "${TribitsExampleProject2_Tpls_install_${sharedOrStatic}_DIR}")

  tribits_add_advanced_test( ${testNameBase}
    OVERALL_WORKING_DIRECTORY TEST_NAME
    OVERALL_NUM_MPI_PROCS 1
    EXCLUDE_IF_NOT_TRUE  NINJA_EXE
    LIST_SEPARATOR "<semicolon>"

    TEST_0
      MESSAGE "Configure TribitsExampleProject2 against pre-installed Tpl1"
      CMND ${CMAKE_COMMAND}
      ARGS
        ${TribitsExampleProject2_COMMON_CONFIG_ARGS}
        -GNinja
        -DTPL_ENABLE_Tpl1=ON
        "-DTPL_Tpl1_INCLUDE_DIRS=${tplInstallBaseDir}/install_tpl1/include"
        "-DTPL_Tpl1_LIBRARIES=${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libext}"
        -DTPL_ENABLE_Tpl2=ON
        "-DTPL_Tpl2_INCLUDE_DIRS=${tplInstallBaseDir}/install_tpl2/include"
        "-DTPL_Tpl2_LIBRARIES=${tplInstallBaseDir}/install_tpl2/lib/libtpl2b${libext}<semicolon>${tplInstallBaseDir}/install_tpl2/lib/libtpl2a${libext}"
        -DTPL_ENABLE_Tpl3=ON
        "-DTPL_Tpl3_INCLUDE_DIRS=${tplInstallBaseDir}/install_tpl3/include"
        "-DTPL_Tpl3_LIBRARIES=${tplInstallBaseDir}/install_tpl3/lib/libtpl3${libext}"
        -DTPL_ENABLE_Tpl4=ON
        "-DTPL_Tpl4_INCLUDE_DIRS=${tplInstallBaseDir}/install_tpl4/include"
        -DCMAKE_BUILD_TYPE=DEBUG
        -DTribitsExProj2_ENABLE_ALL_PACKAGES=ON
        -DTribitsExProj2_ENABLE_TESTS=ON
        -DCMAKE_INSTALL_PREFIX=install
        ${${PROJECT_NAME}_TRIBITS_DIR}/examples/TribitsExampleProject2
      PASS_REGULAR_EXPRESSION_ALL
        "TPL_Tpl1_LIBRARIES='${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}'"
        "TPL_Tpl1_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl1/include'"
        "TPL_Tpl2_LIBRARIES='${tplInstallBaseDir}/install_tpl2/lib/libtpl2b${libextregex}[;]${tplInstallBaseDir}/install_tpl2/lib/libtpl2a${libextregex}'"
        "TPL_Tpl2_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl2/include'"
        "TPL_Tpl3_LIBRARIES='${tplInstallBaseDir}/install_tpl3/lib/libtpl3${libextregex}'"
	"TPL_Tpl3_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl3/include'"
	"TPL_Tpl4_INCLUDE_DIRS='${tplInstallBaseDir}/install_tpl4/include'"
        "-- Configuring done"
        "-- Generating done"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_1
      MESSAGE "Build verbose to check the link line of Package3"
      CMND ${CMAKE_COMMAND} ARGS --build . -v
      PASS_REGULAR_EXPRESSION_ALL
        "[-]o packages/package1/src/package1-prg .* ${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}"
        "[-]o packages/package2/src/package2-prg .* ${tplInstallBaseDir}/install_tpl3/lib/libtpl3${libextregex} +${tplInstallBaseDir}/install_tpl2/lib/libtpl2b${libextregex} +${tplInstallBaseDir}/install_tpl2/lib/libtpl2a${libextregex} +${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}"
        "[-]o packages/package3/src/package3-prg .* ${tplInstallBaseDir}/install_tpl3/lib/libtpl3${libextregex} +${tplInstallBaseDir}/install_tpl2/lib/libtpl2b${libextregex} +${tplInstallBaseDir}/install_tpl2/lib/libtpl2a${libextregex} +${tplInstallBaseDir}/install_tpl1/lib/libtpl1${libextregex}"

    TEST_2
      MESSAGE "Run tests"
      CMND ${CMAKE_CTEST_COMMAND} ARGS -VV
      PASS_REGULAR_EXPRESSION_ALL
        "Test.*Package1_Prg.*Passed"
        "Test.*Package2_Prg.*Passed"
        "Test.*Package3_Prg.*Passed"
        "100% tests passed, 0 tests failed out of 3"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_3
      MESSAGE "Install"
      CMND make ARGS install
      PASS_REGULAR_EXPRESSION_ALL
        "Tpl1Config.cmake"
        "Tpl2Config.cmake"
        "Tpl3Config.cmake"
        "Tpl4Config.cmake"
        "Package1Config.cmake"
        "Package1Targets.cmake"
        "Package2Config.cmake"
        "Package2Targets.cmake"
        "Package3Config.cmake"
        "Package3Targets.cmake"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    ${ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG}

    ADDED_TEST_NAME_OUT ${testNameBase}_NAME
    )
  # NOTE: The above test ensures that setting TPL_<tplName>_INCLUDE_DIRS and
  # TPL_<tplName>_LIBRARIES bypasses calling the inner find_package().

  if (${testNameBase}_NAME)
    set(${testNameBase}_NAME ${${testNameBase}_NAME} PARENT_SCOPE)
    set(${testNameBase}_INSTALL_DIR "${testDir}/install" PARENT_SCOPE)
    set_tests_properties(${${testNameBase}_NAME}
      PROPERTIES DEPENDS ${TribitsExampleProject2_Tpls_install_${sharedOrStatic}_NAME} )
  endif()

endfunction()


TribitsExampleProject2_explicit_tpl_vars(STATIC)
TribitsExampleProject2_explicit_tpl_vars(SHARED)


########################################################################


function(TribitsExampleProject2_find_package  sharedOrStatic)

  TribitsExampleProject2_test_setup_header()

  # Allow skipping delete of src and build dirs to aid in debugging
  if (TribitsExampleProject2_Tests_SKIP_DELETE_SRC_AND_BUILD)
    set(deleteSrcAndBuildDirsCmndArgs
      CMND ${CMAKE_COMMAND} ARGS -E echo "Skip deleting src and build dirs!")
  else()
    set(deleteSrcAndBuildDirsCmndArgs
      CMND ${CMAKE_COMMAND} ARGS -E rm -rf TribitsExampleProject2 BUILD)
  endif()

  set(testNameBase ${CMAKE_CURRENT_FUNCTION}_${sharedOrStatic})
  set(testName ${PACKAGE_NAME}_${testNameBase})
  set(testDir "${CMAKE_CURRENT_BINARY_DIR}/${testName}")

  set(tplInstallBaseDir "${TribitsExampleProject2_Tpls_install_${sharedOrStatic}_DIR}")

  tribits_add_advanced_test( ${testNameBase}
    OVERALL_WORKING_DIRECTORY TEST_NAME
    OVERALL_NUM_MPI_PROCS 1
    LIST_SEPARATOR "<semicolon>"

    TEST_0
      MESSAGE "Copy TribitsExampleProject2 so we can delete it after the install"
      CMND cp
      ARGS -r ${${PROJECT_NAME}_TRIBITS_DIR}/examples/TribitsExampleProject2 .

    TEST_1
      MESSAGE "Configure TribitsExampleProject2 against pre-installed TPLs"
      WORKING_DIRECTORY  BUILD
      CMND ${CMAKE_COMMAND}
      ARGS
        ${TribitsExampleProject2_COMMON_CONFIG_ARGS}
        -DCMAKE_BUILD_TYPE=DEBUG
        -DTPL_ENABLE_Tpl3=ON
        -DTPL_ENABLE_Tpl4=ON
        -DTribitsExProj2_ENABLE_ALL_PACKAGES=ON
        -DTribitsExProj2_ENABLE_TESTS=ON
        -DCMAKE_INSTALL_PREFIX=${testDir}/install
        -D CMAKE_PREFIX_PATH="${tplInstallBaseDir}/install_tpl1<semicolon>${tplInstallBaseDir}/install_tpl2<semicolon>${tplInstallBaseDir}/install_tpl3<semicolon>${tplInstallBaseDir}/install_tpl4"
        ../TribitsExampleProject2
      PASS_REGULAR_EXPRESSION_ALL
        "-- Using find_package[(]Tpl1 [.][.][.][)] [.][.][.]"
        "-- Found Tpl1_DIR='.*TribitsExampleProject2_Tpls_install_${sharedOrStatic}/install_tpl1/lib/cmake/Tpl1'"
        "-- Generating Tpl1::all_libs and Tpl1Config.cmake"
        "-- Found Tpl2_DIR='.*TribitsExampleProject2_Tpls_install_${sharedOrStatic}/install_tpl2/lib/cmake/Tpl2'"
        "-- Generating Tpl2::all_libs and Tpl2Config.cmake"
        "-- Found Tpl3_DIR='.*TribitsExampleProject2_Tpls_install_${sharedOrStatic}/install_tpl3/lib/cmake/Tpl3'"
        "-- Generating Tpl3::all_libs and Tpl3Config.cmake"
        "-- Found Tpl4_DIR='.*TribitsExampleProject2_Tpls_install_${sharedOrStatic}/install_tpl4/lib/cmake/Tpl4'"
        "-- Generating Tpl4::all_libs and Tpl4Config.cmake"
        "-- Configuring done"
        "-- Generating done"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_2
      MESSAGE "Build Packages and tests"
      WORKING_DIRECTORY  BUILD
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND ${CMAKE_COMMAND} ARGS --build .
      PASS_REGULAR_EXPRESSION_ALL
        "package1-prg"
        "package2-prg"
        "package3-prg"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_3
      MESSAGE "Run tests"
      WORKING_DIRECTORY  BUILD
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND ${CMAKE_CTEST_COMMAND} ARGS -VV
      PASS_REGULAR_EXPRESSION_ALL
        "Test.*Package1_Prg.*Passed"
        "Test.*Package2_Prg.*Passed"
        "Test.*Package3_Prg.*Passed"
        "100% tests passed, 0 tests failed out of 3"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_4
      MESSAGE "Install"
      WORKING_DIRECTORY  BUILD
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND make ARGS install
      PASS_REGULAR_EXPRESSION_ALL
        "Tpl1Config.cmake"
        "Tpl1ConfigVersion.cmake"
        "Tpl2Config.cmake"
        "Tpl2ConfigVersion.cmake"
        "Tpl3Config.cmake"
        "Tpl3ConfigVersion.cmake"
        "Tpl4Config.cmake"
        "Tpl4ConfigVersion.cmake"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_5
      MESSAGE "Delete source and build directory for TribitsExampleProject2"
      ${deleteSrcAndBuildDirsCmndArgs}

    ${ENV_PATH_HACK_FOR_TPL1_${sharedOrStatic}_ARG}

    ADDED_TEST_NAME_OUT ${testNameBase}_NAME
    )
  # NOTE: The above test ensures that find_package() works with manual
  # building of the target.

  if (${testNameBase}_NAME)
    set(${testNameBase}_NAME ${${testNameBase}_NAME} PARENT_SCOPE)
    set(${testNameBase}_INSTALL_DIR "${testDir}/install" PARENT_SCOPE)
    set_tests_properties(${${testNameBase}_NAME}
      PROPERTIES DEPENDS ${TribitsExampleProject2_Tpls_install_${sharedOrStatic}_NAME} )
  endif()

endfunction()


TribitsExampleProject2_find_package(STATIC)
TribitsExampleProject2_find_package(SHARED)


########################################################################


set(testNameBase TribitsExampleProject2_install_config_again)
set(testName ${PACKAGE_NAME}_${testNameBase})
set(testDir "${CMAKE_CURRENT_BINARY_DIR}/${testName}")

tribits_add_advanced_test( ${testNameBase}
  OVERALL_WORKING_DIRECTORY TEST_NAME
  OVERALL_NUM_MPI_PROCS 1

  ENVIRONMENT
    "CMAKE_PREFIX_PATH=${TribitsExampleProject2_Tpls_install_STATIC_DIR}/install_tpl1"

  TEST_0
    MESSAGE "Configure TribitsExampleProject2 against pre-installed Tpl1"
    CMND ${CMAKE_COMMAND}
    ARGS
      ${TribitsExampleProject2_COMMON_CONFIG_ARGS}
      -DCMAKE_BUILD_TYPE=DEBUG
      -DTpl1_EXTRACT_INFO_AFTER_FIND_PACKAGE=ON
      -DTribitsExProj2_ENABLE_TESTS=ON
      -DCMAKE_INSTALL_PREFIX=install
      -DTribitsExProj2_ENABLE_Package1=ON
      ${${PROJECT_NAME}_TRIBITS_DIR}/examples/TribitsExampleProject2
    PASS_REGULAR_EXPRESSION_ALL
      "Using find_package[(]Tpl1 [.][.][.][)] [.][.][.]"
      "Found Tpl1_DIR='.*TribitsExampleProject2_Tpls_install_STATIC/install_tpl1/lib/cmake/Tpl1'"
      "Extracting include dirs and libraries from target tpl1::tpl1"
      "-- Configuring done"
      "-- Generating done"
    ALWAYS_FAIL_ON_NONZERO_RETURN

  TEST_1
    MESSAGE "Build Package1 and tests"
    CMND make
    PASS_REGULAR_EXPRESSION_ALL
      "package1-prg"
    ALWAYS_FAIL_ON_NONZERO_RETURN

  TEST_2
    MESSAGE "Run tests for Package1"
    CMND ${CMAKE_CTEST_COMMAND} ARGS -VV
    PASS_REGULAR_EXPRESSION_ALL
      "Test.*Package1_Prg.*Passed"
      "100% tests passed, 0 tests failed"
    ALWAYS_FAIL_ON_NONZERO_RETURN

  TEST_3
    MESSAGE "Install Package1"
    CMND make ARGS install
    PASS_REGULAR_EXPRESSION_ALL
      "Tpl1Config.cmake"
    ALWAYS_FAIL_ON_NONZERO_RETURN

  TEST_4
    MESSAGE "Remove configuration files for TribitsExampleProject2"
    CMND rm ARGS -r CMakeCache.txt CMakeFiles

  TEST_5
    MESSAGE "Configure  TribitsExampleProject2 against from scratch with install dir first in path"
    CMND ${CMAKE_COMMAND}
    ARGS
      ${TribitsExampleProject2_COMMON_CONFIG_ARGS}
      -DCMAKE_BUILD_TYPE=DEBUG
      -DTpl1_EXTRACT_INFO_AFTER_FIND_PACKAGE=ON
      -DTribitsExProj2_ENABLE_TESTS=ON
      -DCMAKE_PREFIX_PATH="${testDir}/install"
      -DCMAKE_INSTALL_PREFIX=install
      -DTribitsExProj2_ENABLE_Package1=ON
      ${${PROJECT_NAME}_TRIBITS_DIR}/examples/TribitsExampleProject2
    PASS_REGULAR_EXPRESSION_ALL
      "Using find_package[(]Tpl1 [.][.][.][)] [.][.][.]"
      "Found Tpl1_DIR='.*TribitsExampleProject2_Tpls_install_STATIC/install_tpl1/lib/cmake/Tpl1'"
      "-- Configuring done"
      "-- Generating done"
    ALWAYS_FAIL_ON_NONZERO_RETURN

  ADDED_TEST_NAME_OUT ${testNameBase}_NAME
  )
  # Above, we set the cache var CMAKE_PREFIX_PATH=install_tpl1 and the env var
  # CMAKE_PREFIX_PATH=install_tpl1 so that find_package(Tpl1) will look in
  # install_tpl1/ first for Tpl1Config.cmake before looking in
  # CMAKE_INSTALL_PREFIX=install/.  (Note that we have to set the cache var
  # CMAKE_PREFIX_PATH=install_tpl1 to put install_tpl1/ in the search path
  # ahead of install/ for this simulation since CMAKE_INSTALL_PREFIX, which
  # initializes CMAKE_SYSTEM_PREFIX_PATH, is searched after the env var
  # CMAKE_PREFIX_PATH.)
  #
  # This test simulates the situation in bug #427 where CMAKE_INSTALL_PREFIX
  # (which initializes CMAKE_SYSTEM_PREFIX_PATH) is searched before PATH and
  # HDF5Config.cmake was getting found in CMAKE_INSTALL_PREFIX from a prior
  # install of Trilinos.  But since I don't want to mess with PATH for this
  # test, I just want to have find_package() search install_tpl1/ before in
  # searches install/ to simulate that scenario.  This test ensures that
  # find_package(Tpl1) will not find Tpl1Config.cmake just because
  # CMAKE_INSTALL_PREFIX is in the search path.
  #
  # This test also sets Tpl1_EXTRACT_INFO_AFTER_FIND_PACKAGE=ON so we can test
  # that path through FindTPLTpl1.cmake.
  #
  # NOTE: Updated versions of TriBITS will not find TriBITS-generated files
  # like Tpl1Config.cmake because they are placed under a different subdir
  # <installDir>/external_pacakges/.

if (${testNameBase}_NAME)
  set_tests_properties(${${testNameBase}_NAME}
    PROPERTIES DEPENDS ${TribitsExampleProject2_Tpls_install_STATIC_NAME} )
endif()


################################################################################


function(TribitsExampleProject2_External_Package_by_Package
    sharedOrStatic  findingTplsMethod
  )

  TribitsExampleProject2_test_setup_header()

  set(tplInstallBaseDir
    "${TribitsExampleProject2_Tpls_install_${sharedOrStatic}_DIR}")

  set(allTplsNoPrefindArgs
    "-DTpl1_ALLOW_PACKAGE_PREFIND=OFF"
    "-DTpl2_ALLOW_PACKAGE_PREFIND=OFF"
    "-DTpl3_ALLOW_PACKAGE_PREFIND=OFF"
    "-DTpl4_ALLOW_PACKAGE_PREFIND=OFF"
    )

  if (sharedOrStatic STREQUAL "STATIC")
    set(libExt "a")
  elseif (sharedOrStatic STREQUAL "SHARED")
    set(libExt "so")
  else()
    message(FATAL_ERROR "Error: Invalid value of"
      " sharedOrStatic='${sharedOrStatic}'!")
  endif()

  if (findingTplsMethod STREQUAL "TPL_LIBRARY_AND_INCLUDE_DIRS")
    set(tpl1LibAndIncDirsArgs
      "-DTpl1_INCLUDE_DIRS=${tplInstallBaseDir}/install_tpl1/include"
      "-DTpl1_LIBRARY_DIRS=${tplInstallBaseDir}/install_tpl1/lib"
      "-DTpl1_ALLOW_PACKAGE_PREFIND=OFF")
    set(tpl2LibAndIncDirsArgs
      "-DTpl2_INCLUDE_DIRS=${tplInstallBaseDir}/install_tpl2/include"
      "-DTpl2_LIBRARY_DIRS=${tplInstallBaseDir}/install_tpl2/lib"
      "-DTpl2_ALLOW_PACKAGE_PREFIND=OFF")
    set(tpl3LibAndIncDirsArgs
      "-DTpl3_INCLUDE_DIRS=${tplInstallBaseDir}/install_tpl3/include"
      "-DTpl3_LIBRARY_DIRS=${tplInstallBaseDir}/install_tpl3/lib"
      "-DTpl3_ALLOW_PACKAGE_PREFIND=OFF")
    set(tpl4LibAndIncDirsArgs
      "-DTpl4_INCLUDE_DIRS=${tplInstallBaseDir}/install_tpl4/include"
      "-DTpl4_ALLOW_PACKAGE_PREFIND=OFF")
    set(tpl1CMakePrefixPath "")
    set(tpl2CMakePrefixPath "")
    set(tpl3CMakePrefixPath "")
    set(tpl4CMakePrefixPath "")
    set(tpl1FoundRegexes
      "TPL_Tpl1_LIBRARIES='.*/install_tpl1/lib/libtpl1[.]${libExt}'"
      "TPL_Tpl1_INCLUDE_DIRS='.*/install_tpl1/include'")
    set(tpl2FoundRegexes
      "TPL_Tpl2_LIBRARIES='.*/install_tpl2/lib/libtpl2b[.]${libExt}[;].*/install_tpl2/lib/libtpl2a[.]${libExt}'"
      "TPL_Tpl2_INCLUDE_DIRS='.*/install_tpl2/include'")
    set(tpl3FoundRegexes
      "TPL_Tpl3_LIBRARIES='.*/install_tpl3/lib/libtpl3[.]${libExt}'"
      "TPL_Tpl3_INCLUDE_DIRS='.*/install_tpl3/include'")
    set(tpl4FoundRegexes
      "-- TPL_Tpl4_INCLUDE_DIRS='.*/install_tpl4/include'")
  elseif (findingTplsMethod STREQUAL "CMAKE_PREFIX_PATH_CACHE")
    set(testNameSuffix "_CMAKE_PREFIX_PATH_CACHE")
    set(tpl1LibAndIncDirsArgs "-DTpl1_ALLOW_PACKAGE_PREFIND=ON")
    set(tpl2LibAndIncDirsArgs "-DTpl2_ALLOW_PACKAGE_PREFIND=ON")
    set(tpl3LibAndIncDirsArgs "-DTpl3_ALLOW_PACKAGE_PREFIND=ON")
    set(tpl4LibAndIncDirsArgs "-DTpl4_ALLOW_PACKAGE_PREFIND=ON")
    set(tpl1CMakePrefixPath "${tplInstallBaseDir}/install_tpl1")
    set(tpl2CMakePrefixPath "${tplInstallBaseDir}/install_tpl2")
    set(tpl3CMakePrefixPath "${tplInstallBaseDir}/install_tpl3")
    set(tpl4CMakePrefixPath "${tplInstallBaseDir}/install_tpl4")
    set(tpl1FoundRegexes
      "-- Using find_package[(]Tpl1 ...[)] ..."
      "-- Found Tpl1_DIR='.*/install_tpl1/lib/cmake/Tpl1'"
      "-- Generating Tpl1::all_libs and Tpl1Config.cmake")
    set(tpl2FoundRegexes
      "-- Using find_package[(]Tpl2 ...[)] ..."
      "-- Found Tpl2_DIR='.*/install_tpl2/lib/cmake/Tpl2'"
      "-- Generating Tpl2::all_libs and Tpl2Config.cmake")
    set(tpl3FoundRegexes
      "-- Using find_package[(]Tpl3 ...[)] ..."
      "-- Found Tpl3_DIR='.*/install_tpl3/lib/cmake/Tpl3'"
      "-- Generating Tpl3::all_libs and Tpl3Config.cmake")
    set(tpl4FoundRegexes
      "-- Using find_package[(]Tpl4 ...[)] ..."
      "-- Found Tpl4_DIR='.*/install_tpl4/lib/cmake/Tpl4'"
      "-- Generating Tpl4::all_libs and Tpl4Config.cmake")
  else()
    message(FATAL_ERROR
      "Error, findingTplsMethod='${findingTplsMethod}' is invalid!")
  endif()

  set(testNameBase ${CMAKE_CURRENT_FUNCTION}_${sharedOrStatic}${testNameSuffix})
  set(testName ${PACKAGE_NAME}_${testNameBase})
  set(testDir "${CMAKE_CURRENT_BINARY_DIR}/${testName}")

  tribits_add_advanced_test( ${testNameBase}
    OVERALL_WORKING_DIRECTORY  TEST_NAME
    OVERALL_NUM_MPI_PROCS  1
    EXCLUDE_IF_NOT_TRUE  ${PROJECT_NAME}_ENABLE_Fortran  IS_REAL_LINUX_SYSTEM
    LIST_SEPARATOR <semicolon>

    TEST_0
      MESSAGE "Link TribitsExampleProject2 so it is easy to access"
      CMND ln
      ARGS -s ${${PROJECT_NAME}_TRIBITS_DIR}/examples/TribitsExampleProject2 .

    TEST_1
      MESSAGE "Configure to build and install just Package1"
      WORKING_DIRECTORY Build_Package1
      CMND ${CMAKE_COMMAND}
      ARGS
        ${TribitsExampleProject2_COMMON_CONFIG_ARGS}
        -DTribitsExProj2_TRIBITS_DIR=${${PROJECT_NAME}_TRIBITS_DIR}
        -DTribitsExProj2_ENABLE_SECONDARY_TESTED_CODE=ON
        -DTribitsExProj2_ENABLE_Package1=ON
        -DCMAKE_INSTALL_PREFIX=../install_package1
        -DTribitsExProj2_SKIP_INSTALL_PROJECT_CMAKE_CONFIG_FILES=TRUE
        -DTPL_ENABLE_Tpl1=ON
        ${tpl1LibAndIncDirsArgs}
        -DCMAKE_PREFIX_PATH=${tpl1CMakePrefixPath}
        ../TribitsExampleProject2
      PASS_REGULAR_EXPRESSION_ALL
        "Final set of enabled top-level packages:  Package1 1"
        "Final set of non-enabled top-level packages:  Package2 Package3 2"
        "Final set of enabled top-level external packages/TPLs:  Tpl1 1"
        "Final set of non-enabled top-level external packages/TPLs:  Tpl2 Tpl3 Tpl4 3"

        "Getting information for all enabled external packages/TPLs ..."
        "Processing enabled external package/TPL: Tpl1 [(]enabled explicitly, disable with -DTPL_ENABLE_Tpl1=OFF[)]"
        ${tpl1FoundRegexes}
        "Configuring done"
      ALWAYS_FAIL_ON_NONZERO_RETURN
      # NOTE: Above Tpl1 is found and the wrapper file Tpl1Config.cmake is
      # created and installed.  This Tpl1Config.cmake file gets used in
      # downstream CMake project configures.

    TEST_2
      MESSAGE "Build and install just Package1"
      WORKING_DIRECTORY Build_Package1
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND ${CMAKE_COMMAND} ARGS --build . --target install

    TEST_3
      MESSAGE "Configure to build and install just Package2"
      WORKING_DIRECTORY Build_Package2
      CMND ${CMAKE_COMMAND}
      ARGS
        ${TribitsExampleProject2_COMMON_CONFIG_ARGS}
        -DTribitsExProj2_TRIBITS_DIR=${${PROJECT_NAME}_TRIBITS_DIR}
        -DTribitsExProj2_ENABLE_SECONDARY_TESTED_CODE=ON
        -DTribitsExProj2_ENABLE_Package2=ON
        -DCMAKE_INSTALL_PREFIX=../install_package2
        -DTribitsExProj2_SKIP_INSTALL_PROJECT_CMAKE_CONFIG_FILES=TRUE
        -DTPL_ENABLE_Package1=ON  # Pull in already installed Package!
        -DTPL_ENABLE_Tpl2=ON
        ${tpl2LibAndIncDirsArgs}
        -DTPL_ENABLE_Tpl3=ON
        ${tpl3LibAndIncDirsArgs}
        -DCMAKE_PREFIX_PATH=../install_package1<semicolon>${tpl2CMakePrefixPath}<semicolon>${tpl3CMakePrefixPath}
        ../TribitsExampleProject2
      PASS_REGULAR_EXPRESSION_ALL
        "Adjust the set of internal and external packages:"
        "-- Treating internal package Package1 as EXTERNAL because TPL_ENABLE_Package1=ON"
        "-- NOTE: Tpl1 is directly downstream from a TriBITS-compliant external package Package1"

        "Final set of enabled top-level packages:  Package2 1"
        "Final set of non-enabled top-level packages:  Package3 1"
        "Final set of enabled top-level external packages/TPLs:  Tpl1 Tpl2 Tpl3 Package1 4"
        "Final set of non-enabled top-level external packages/TPLs:  Tpl4 1"

        "Getting information for all enabled TriBITS-compliant or upstream external packages/TPLs ..."
        "Processing enabled external package/TPL: Tpl1 [(]enabled by Package1, disable with -DTPL_ENABLE_Tpl1=OFF[)]"
        "-- The external package/TPL Tpl1 will be read in by a downstream TriBITS-compliant external package"
        "Processing enabled external package/TPL: Package1 [(]enabled explicitly, disable with -DTPL_ENABLE_Package1=OFF[)]"
        "-- Calling find_package[(]Package1[)] for TriBITS-compliant external package"

        "Getting information for all remaining enabled external packages/TPLs ..."
        "Processing enabled external package/TPL: Tpl2 [(]enabled explicitly, disable with -DTPL_ENABLE_Tpl2=OFF[)]"
        ${tpl2FoundRegexes}
        "Processing enabled external package/TPL: Tpl3 [(]enabled explicitly, disable with -DTPL_ENABLE_Tpl3=OFF[)]"
        ${tpl3FoundRegexes}

        "Configuring individual enabled TribitsExProj2 packages ..."
        "Processing enabled top-level package: Package2 [(]Libs[)]"

        "Configuring done"
      ALWAYS_FAIL_ON_NONZERO_RETURN
      # NOTE: Above shows how a TriBITS TPL can depend on an upstream TriBITS
      # TPL found by earlier TriBITS package build and install.  In this case,
      # Tpl1 is found and the Tpl1Config.cmake wrapper file is created as part
      # of the upstream configure and build of Package1 and the definition of
      # Tpl1 is pulled in when find_package(Package1) is called on the
      # TriBITS-compliant external package Package1.  Then Tpl2 and Tpl2 are
      # found and Tpl2Config.cmake and Tpl3Config.cmake are created that point
      # to pre-installed Tpl1Config.cmake.

    TEST_4
      MESSAGE "Build and install just Package2"
      WORKING_DIRECTORY Build_Package2
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND ${CMAKE_COMMAND} ARGS --build . --target install

    TEST_5
      MESSAGE "Configure to build, test, and install the rest of TribitsExampleProject2 (Package2)"
      WORKING_DIRECTORY Build
      CMND ${CMAKE_COMMAND}
      ARGS
        ${TribitsExampleProject2_COMMON_CONFIG_ARGS}
        -DTribitsExProj2_TRIBITS_DIR=${${PROJECT_NAME}_TRIBITS_DIR}
        -DTribitsExProj2_ENABLE_SECONDARY_TESTED_CODE=ON
        -DTribitsExProj2_ENABLE_ALL_PACKAGES=ON
        -DTribitsExProj2_ENABLE_TESTS=ON
        -DCMAKE_INSTALL_PREFIX=../install
        -DTribitsExProj2_SKIP_INSTALL_PROJECT_CMAKE_CONFIG_FILES=TRUE
        -DTPL_ENABLE_Package2=ON  # Pull in already installed Package!
        -DTPL_ENABLE_Tpl1=ON
        -DTPL_ENABLE_Tpl2=ON
        -DTPL_ENABLE_Tpl3=ON
        -DTPL_ENABLE_Tpl4=ON
        ${tpl4LibAndIncDirsArgs}
        -DCMAKE_PREFIX_PATH=../install_package2<semicolon>${tpl4CMakePrefixPath}
        ../TribitsExampleProject2
      PASS_REGULAR_EXPRESSION_ALL
        "Adjust the set of internal and external packages:"
        "-- Treating internal package Package2 as EXTERNAL because TPL_ENABLE_Package2=ON"
        "-- Treating internal package Package1 as EXTERNAL because downstream package Package2 being treated as EXTERNAL"
        "-- NOTE: Tpl3 is directly downstream from a TriBITS-compliant external package Package2"
        "-- NOTE: Tpl2 is indirectly downstream from a TriBITS-compliant external package"
        "-- NOTE: Tpl1 is indirectly downstream from a TriBITS-compliant external package"

        "Final set of enabled top-level packages:  Package3 1"
        "Final set of non-enabled top-level packages:  0"
        "Final set of enabled top-level external packages/TPLs:  Tpl1 Tpl2 Tpl3 Tpl4 Package1 Package2 6"
        "Final set of non-enabled top-level external packages/TPLs:  0"

        "Getting information for all enabled TriBITS-compliant or upstream external packages/TPLs ..."
        "Processing enabled external package/TPL: Tpl1 [(]enabled explicitly, disable with -DTPL_ENABLE_Tpl1=OFF[)]"
        "-- The external package/TPL Tpl1 will be read in by a downstream TriBITS-compliant external package"
        "Processing enabled external package/TPL: Tpl2 [(]enabled explicitly, disable with -DTPL_ENABLE_Tpl2=OFF[)]"
        "-- The external package/TPL Tpl2 will be read in by a downstream TriBITS-compliant external package"
        "Processing enabled external package/TPL: Tpl3 [(]enabled explicitly, disable with -DTPL_ENABLE_Tpl3=OFF[)]"
        "-- The external package/TPL Tpl3 will be read in by a downstream TriBITS-compliant external package"
        "Processing enabled external package/TPL: Package1 [(]enabled explicitly, disable with -DTPL_ENABLE_Package1=OFF[)]"
        "-- The external package/TPL Package1 will be read in by a downstream TriBITS-compliant external package"
        "Processing enabled external package/TPL: Package2 [(]enabled explicitly, disable with -DTPL_ENABLE_Package2=OFF[)]"
        "-- Calling find_package[(]Package2[)] for TriBITS-compliant external package"

        "Getting information for all remaining enabled external packages/TPLs ..."

        "Processing enabled external package/TPL: Tpl4 [(]enabled explicitly, disable with -DTPL_ENABLE_Tpl4=OFF[)]"
        ${tpl4FoundRegexes}

        "Configuring done"
      ALWAYS_FAIL_ON_NONZERO_RETURN
      # NOTE: Above, only the newly enabled TPL Tpl4 is found and its
      # Tpl4Config.cmake file is linked to the pre-installed
      # Tpl1Config.comake, Tpl2Config.cmake and Tpl3Config.cmake files.  And
      # the needed info from Tpl1, Tpl2, and Tpl3 is pulled in from
      # find_package(Package2).

    TEST_6
      MESSAGE "Build and install the rest of TribitsExampleProject2 (Package3)"
      WORKING_DIRECTORY Build
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND ${CMAKE_COMMAND} ARGS --build . --target install

    TEST_7
      MESSAGE "Run remaining tests for TribitsExampleProject2 (Package3)"
      WORKING_DIRECTORY Build
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND ${CMAKE_CTEST_COMMAND}
      PASS_REGULAR_EXPRESSION_ALL
        "Package3_Prg [.]+ *Passed"
	"100% tests passed, 0 tests failed out of 1"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    ADDED_TEST_NAME_OUT ${testNameBase}_NAME
    )

  if (${testNameBase}_NAME)
    set(${testNameBase}_NAME ${${testNameBase}_NAME} PARENT_SCOPE)
    set(${testNameBase}_INSTALL_DIR "${testDir}/install" PARENT_SCOPE)
    set_tests_properties(${${testNameBase}_NAME}
      PROPERTIES DEPENDS ${TribitsExampleProject2_Tpls_install_${sharedOrStatic}_NAME} )
  endif()

endfunction()


TribitsExampleProject2_External_Package_by_Package(STATIC  TPL_LIBRARY_AND_INCLUDE_DIRS)
TribitsExampleProject2_External_Package_by_Package(SHARED  TPL_LIBRARY_AND_INCLUDE_DIRS)
TribitsExampleProject2_External_Package_by_Package(STATIC  CMAKE_PREFIX_PATH_CACHE)
TribitsExampleProject2_External_Package_by_Package(SHARED  CMAKE_PREFIX_PATH_CACHE)

# NOTE: The above tests check a few different use cases for building and
# installing TriBITS packages from a single TriBITS project incrementally.
