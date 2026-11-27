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

GNUCAP_INC="${GNUCAP_INC:-/usr/local/include/gnucap}"
GNUCAP_VAMS="${GNUCAP_VAMS:-gnucap-mg-vams}"
CXX="${CXX:-g++}"

# IHP SG13G2 PDK sources.  Only the Verilog-A models are needed here; the
# plugins are rebuilt locally because the ones shipped with the PDK were
# built against a previous gnucap core and fail to load.
PDK="${IHP_PDK:-/home/herman/work/IHP-Open-PDK}"
PDK_LIB="$PDK/ihp-sg13g2/libs.tech"
PDK_SRC="$PDK_LIB/gnucap/models"
PDK_VA="$PDK_LIB/verilog-a"

if [ ! -d "$PDK_SRC" ]; then
    echo "PDK sources not found in $PDK (set IHP_PDK)" >&2
    exit 1
fi

mkdir -p pdk

# The PDK Verilog-A sources use three constructs that the current
# gnucap-mg-vams / lang_verilog no longer accepts:
#
#   localparam real x = ...;      -> parameter real x = ...;
#   <line> \                      -> joined into a single line
#   $rdist_normal(seed, mean, sigma, "scope") -> (mean)
#
# The last one removes statistical variation, which is what the nominal
# typical-corner testbench wants.  The patched files are local copies; the
# PDK tree itself is left untouched.  They are only rewritten when their
# contents change, so re-running this script does not invalidate the .so
# files built below.
python3 - "$PDK_SRC" <<'PY'
import pathlib, re, sys

src = pathlib.Path(sys.argv[1])
out = pathlib.Path("pdk")
files = ["sg13g2_moslv_module.va", "capacitor_module.va",
         "cornerRES.va", "cornerMOSlv.va", "cornerCAP.va"]
rdist = re.compile(
    r'\$rdist_normal\([^,()]+,\s*([^,()]+),\s*[^,()]+'
    r'(?:\s*,\s*"[^"]*")?\s*\)')

for name in files:
    text = (src / name).read_text()
    text = re.sub(r'\blocalparam\b', 'parameter', text)
    text = text.replace("\\\n", " ")
    text = rdist.sub(r'(\1)', text)
    dest = out / name
    if not dest.exists() or dest.read_text() != text:
        dest.write_text(text)
        print("patched", name)
PY

build_plugin() {
    # $1 = source name; remaining args are extra -I paths
    src="$1"
    name="${src%.va}"
    shift
    if [ -f "pdk/$name.so" ] && [ "pdk/$name.so" -nt "$PDK_SRC/$src" ]; then
        echo "up to date pdk/$name.so"
        return
    fi
    cc=$(mktemp --suffix=.cc)
    "$GNUCAP_VAMS" -I "$GNUCAP_INC" -I "$PDK_SRC" "$@" \
        --cc "$PDK_SRC/$src" > "$cc"
    "$CXX" -xc++ -I"$GNUCAP_INC" -DNDEBUG -O0 -fPIC -shared \
        "$cc" -o "pdk/$name.so"
    rm -f "$cc"
    echo "built pdk/$name.so"
}

build_plugin sg13g2_moslv_paramset.va    -I "$PDK_VA/psp103"
build_plugin sg13g2_moslv_rf_paramset.va -I "$PDK_VA/psp103"
build_plugin resistor_paramset.va        -I "$PDK_VA/r3_cmc"
build_plugin capacitor_paramset.va       -I "$PDK_VA/cap_cmomi" -I "$PDK_VA/cap_cmomf"
build_plugin idc.va                      -I "$PDK_VA/psp103"

# vpwl is the only model used directly by the testbench.
if [ ! -f vpwl.so ] || [ vpwl.vams -nt vpwl.so ]; then
    cc=$(mktemp)
    "$GNUCAP_VAMS" -I "$GNUCAP_INC" --cc vpwl.vams > "$cc"
    "$CXX" -xc++ -I"$GNUCAP_INC" \
        -DNDEBUG -O2 -fPIC -shared "$cc" -o vpwl.so
    rm -f "$cc"
    echo "built vpwl.so"
else
    echo "up to date vpwl.so"
fi

echo "device sources built"
