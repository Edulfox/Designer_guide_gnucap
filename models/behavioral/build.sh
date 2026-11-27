#!/bin/sh
########################################################################
#
# Copyright 2026 IHP PDK Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
########################################################################

set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

GNUGCAP_INC="${GNUGCAP_INC:-/usr/local/include/gnucap}"
GNUGCAP_VAMS="${GNUGCAP_VAMS:-gnucap-mg-vams}"
CXX="${CXX:-g++}"

build_model() {
    src="$1"
    out="$2"
    cc=$(mktemp)
    "$GNUGCAP_VAMS" -I "$GNUGCAP_INC" --cc "$src" > "$cc"
    "$CXX" -xc++ -I"$GNUGCAP_INC" \
        -DNDEBUG -O2 -fPIC -shared "$cc" -o "$out"
    rm -f "$cc"
    echo "built $out"
}

rm -rf *.so
# Standard StrongARM latch
build_model comp_std.vams comp_std.so

# Registered comparator + gated clock
build_model comp_reg.vams comp_reg.so

# Mixed-signal comparator: digital clock + digitized rail outputs
build_model comp_mix.vams comp_mix.so

# Digital-logic reference variant: a logic-domain clock and logic outputs,
# bridged to the analog testbench with the PDK connectmodules.
build_model comp_reg_logic_ref.vams comp_reg_logic_ref.so
build_model clock_logic_ref.vams clock_logic_ref.so

# Connectmodules from the IHP SG13G2 gnucap mixed-signal examples.
build_model elect_to_logic.vams elect_to_logic.so
build_model logic_to_elect.vams logic_to_elect.so

# Sources used by the testbenches (local copies, so the decks do not depend
# on the installed vams plugin set):
build_model vpwl.vams vpwl.so
build_model vpulse.vams vpulse.so

echo "behavioral models built"
