# @HEADER
# ************************************************************************
#
#            TriBITS: Tribal Build, Integrate, and Test System
#                    Copyright 2013 Sandia Corporation
#
# Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,
# the U.S. Government retains certain rights in this software.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the Corporation nor the names of the
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY SANDIA CORPORATION "AS IS" AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SANDIA CORPORATION OR THE
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ************************************************************************
# @HEADER

include(TribitsGetEnabledSublists)


# @FUNCTION: tribits_print_enables_before_adjust_package_enables()
#
# Call this to print the package enables before calling
# tribits_adjust_package_enables().
#
# Usage::
#
#   tribits_print_enables_before_adjust_package_enables()
#
function(tribits_print_enables_before_adjust_package_enables)
  tribits_print_internal_toplevel_package_list_enable_status(
    "\nExplicitly enabled top-level packages on input (by user)" ON FALSE)
  tribits_print_internal_package_list_enable_status(
    "\nExplicitly enabled packages on input (by user)" ON FALSE)
  tribits_print_internal_toplevel_package_list_enable_status(
    "\nExplicitly disabled top-level packages on input (by user or by default)" OFF FALSE)
  tribits_print_internal_package_list_enable_status(
    "\nExplicitly disabled packages on input (by user or by default)" OFF FALSE)
  tribits_print_tpl_list_enable_status(
    "\nExplicitly enabled external packages/TPLs on input (by user)" ON FALSE)
  tribits_print_tpl_list_enable_status(
    "\nExplicitly disabled external packages/TPLs on input (by user or by default)"
    OFF FALSE)
  tribits_print_package_build_status("\nInitial package build status:\n"
    "-- Initial: " PRINT_ALL)
endfunction()


# @FUNCTION: tribits_print_enables_after_adjust_package_enables()
#
# Call this to print the package enables before calling
# tribits_adjust_package_enables().
#
# Usage::
#
#   tribits_print_enables_after_adjust_package_enables()
#
function(tribits_print_enables_after_adjust_package_enables)
  tribits_print_prefix_string_and_list(
    "\nFinal set of enabled top-level packages"
    ${PROJECT_NAME}_ENABLED_INTERNAL_TOPLEVEL_PACKAGES)
  tribits_print_prefix_string_and_list(
    "\nFinal set of enabled packages"
    ${PROJECT_NAME}_ENABLED_INTERNAL_PACKAGES)
  tribits_print_internal_toplevel_package_list_enable_status(
    "\nFinal set of non-enabled top-level packages" OFF TRUE)
  tribits_print_internal_package_list_enable_status(
    "\nFinal set of non-enabled packages" OFF TRUE)
  tribits_print_tpl_list_enable_status(
    "\nFinal set of enabled external packages/TPLs" ON FALSE)
  tribits_print_tpl_list_enable_status(
    "\nFinal set of non-enabled external packages/TPLs" OFF TRUE)
  tribits_print_package_build_status("\nFinal package build status (enabled only):\n"
    "-- Final: " PRINT_ONLY_ENABLED)
endfunction()


# Function that prints the current set of enabled internal top-level packages
#
function(tribits_print_internal_toplevel_package_list_enable_status
    DOCSTRING  ENABLED_FLAG  INCLUDE_EMPTY
  )
  tribits_print_packages_list_enable_status_from_var(
    ${PROJECT_NAME}_DEFINED_INTERNAL_TOPLEVEL_PACKAGES
    "${DOCSTRING}" ${ENABLED_FLAG} ${INCLUDE_EMPTY} )
endfunction()


# Prints the current set of enabled/disabled internal packages
#
function(tribits_print_internal_package_list_enable_status
    DOCSTRING  ENABLED_FLAG  INCLUDE_EMPTY
  )
  if (ENABLED_FLAG  AND  NOT  INCLUDE_EMPTY)
    tribits_get_sublist_enabled(
      ${PROJECT_NAME}_DEFINED_INTERNAL_PACKAGES
      internalPackagesEnableStatusList  "")
  elseif (ENABLED_FLAG  AND  INCLUDE_EMPTY)
    tribits_get_sublist_nondisabled(
      ${PROJECT_NAME}_DEFINED_INTERNAL_PACKAGES  ${PROJECT_NAME}
      internalPackagesEnableStatusList  "")
  elseif (NOT  ENABLED_FLAG  AND  NOT  INCLUDE_EMPTY)
    tribits_get_sublist_disabled(
      ${PROJECT_NAME}_DEFINED_INTERNAL_PACKAGES
      internalPackagesEnableStatusList  "")
  else() # NOT  ENABLED_FLAG  AND  INCLUDE_EMPTY
    tribits_get_sublist_nonenabled(
      ${PROJECT_NAME}_DEFINED_INTERNAL_PACKAGES
      internalPackagesEnableStatusList  "")
  endif()
  tribits_print_prefix_string_and_list("${DOCSTRING}"
    internalPackagesEnableStatusList)
endfunction()


# Print the current set of enabled/disabled TPLs
#
function(tribits_print_tpl_list_enable_status  DOCSTRING  ENABLED_FLAG  INCLUDE_EMPTY)
  if (ENABLED_FLAG AND NOT INCLUDE_EMPTY)
    tribits_get_sublist_enabled( ${PROJECT_NAME}_DEFINED_TPLS
      tplsEnableStatusList  "")
  elseif (ENABLED_FLAG AND INCLUDE_EMPTY)
    tribits_get_sublist_nondisabled( ${PROJECT_NAME}_DEFINED_TPLS
      tplsEnableStatusList  "")
  elseif (NOT ENABLED_FLAG AND NOT INCLUDE_EMPTY)
    tribits_get_sublist_disabled( ${PROJECT_NAME}_DEFINED_TPLS
      tplsEnableStatusList  "")
  else() # NOT ENABLED_FLAG AND INCLUDE_EMPTY
    tribits_get_sublist_nonenabled( ${PROJECT_NAME}_DEFINED_TPLS
       tplsEnableStatusList  "")
  endif()
  tribits_print_prefix_string_and_list("${DOCSTRING}"  tplsEnableStatusList)
endfunction()


# Print the current set of enabled/disabled packages given input list of
# packages
#
function(tribits_print_packages_list_enable_status_from_var  PACKAGES_LIST_VAR
  DOCSTRING  ENABLED_FLAG  INCLUDE_EMPTY
  )
  if (ENABLED_FLAG  AND  NOT  INCLUDE_EMPTY)
    tribits_get_sublist_enabled(${PACKAGES_LIST_VAR}
      enableStatusList  "")
  elseif (ENABLED_FLAG  AND  INCLUDE_EMPTY)
    tribits_get_sublist_nondisabled(${PACKAGES_LIST_VAR}  enableStatusList  "")
  elseif (NOT  ENABLED_FLAG  AND  NOT  INCLUDE_EMPTY)
    tribits_get_sublist_disabled(${PACKAGES_LIST_VAR}
      enableStatusList  "")
  else() # NOT  ENABLED_FLAG  AND  INCLUDE_EMPTY
    tribits_get_sublist_nonenabled(${PACKAGES_LIST_VAR}
      enableStatusList  "")
  endif()
  tribits_print_prefix_string_and_list("${DOCSTRING}"  enableStatusList)
endfunction()


# Print out a list with white-space separators with an initial doc string
#
function(tribits_print_prefix_string_and_list  docString   listNameToPrint)
  string(REPLACE ";" " " listToPrintStr "${${listNameToPrint}}")
  list(LENGTH  ${listNameToPrint}  numElements)
  if (numElements GREATER "0")
    message("${docString}:  ${listToPrintStr} ${numElements}")
  else()
    message("${docString}:  ${numElements}")
  endif()
endfunction()


# Print out the `<Package>_PACKAGE_BUILD_STATUS` vars
function(tribits_print_package_build_status  summaryHeaderStr  prefixStr
    printEnabledOpt
  )
  if (printEnabledOpt STREQUAL "PRINT_ALL")
    set(printAll ON)
  elseif (printEnabledOpt STREQUAL "PRINT_ONLY_ENABLED")
    set(printAll OFF)
  else()
    message(FATAL_ERROR
      "Error, invalid value for printEnabledOpt='${printEnabledOpt}'")
  endif()

  if (${PROJECT_NAME}_DUMP_PACKAGE_BUILD_STATUS)
    message("${summaryHeaderStr}")
    foreach(packageName  IN LISTS  ${PROJECT_NAME}_DEFINED_PACKAGES)
    tribits_get_package_enable_status(${packageName}  packageEnable  "")
      if (printAll OR packageEnable)
        message("${prefixStr}${packageName}_PACKAGE_BUILD_STATUS="
	  "${${packageName}_PACKAGE_BUILD_STATUS}")
      endif()
    endforeach()
  endif()
endfunction()
