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

include_guard()

# @FUNCTION: tribits_print_list()
#
# Unconditionally the name and values of a listg var.
#
# Usage::
#
#   tribits_print_list(<listName>)
#
# This prints::
#
#   -- <listName> (size=<len>):
#   --   <val0>
#   --   <val1>
#   ...
#   --   <valN>
#
# The variable ``<listName>`` can be defined or undefined or empty.  This uses
# an explicit "-- " line prefix so that it prints nice even on Windows CMake.
#
function(tribits_print_list listName)
  list(LENGTH ${listName} len)
  message("-- " "${listName} (size=${len})")
  foreach(ele IN LISTS ${listName})
    message("-- " "  '${ele}'")
  endforeach()
endfunction()

# NOTE: Above, I was not able to call message_wrapper() directly because it
# was removing the ';' in array arguments.  This broke a bunch of unit tests.
# Therefore, I have to duplicate code and call it in two separate places.  I
# have to admit that CMake behavior surprises me many times.  This is not a
# great programming language.
