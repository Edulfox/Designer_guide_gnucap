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

if [ ! -f vpwl.so ] || [ ! -f pdk/sg13g2_moslv_paramset.so ] \
   || [ ! -f pdk/sg13g2_moslv_rf_paramset.so ] \
   || [ ! -f pdk/resistor_paramset.so ] || [ ! -f pdk/capacitor_paramset.so ] \
   || [ ! -f pdk/idc.so ]; then
    echo "building device sources (this takes several minutes)..."
    ./build.sh
fi

# Use the locally rebuilt PDK plugins and the patched include files
# (see build.sh) ahead of the installed ones.
GNUCAP_INCLUDEPATH="$SCRIPT_DIR/pdk:${GNUCAP_INCLUDEPATH:-/usr/local/include/gnucap}"
GNUCAP_PLUGPATH="$SCRIPT_DIR/pdk:${GNUCAP_PLUGPATH:-/usr/local/lib/gnucap}"
export GNUCAP_INCLUDEPATH GNUCAP_PLUGPATH

echo "=== CMP7345: transistor-level SG13G2 comparator ==="

rm -f CMP7345_tran.txt
gnucap CMP7345_tb.gc > CMP7345_run.log 2>&1

if [ ! -s CMP7345_tran.txt ]; then
    echo "simulation failed, see CMP7345_run.log" >&2
    exit 1
fi
if grep -qE 'undefined symbol|Bus error|Cannot find|no match|syntax error' CMP7345_run.log; then
    echo "simulation error, see CMP7345_run.log" >&2
    grep -E 'undefined symbol|Bus error|Cannot find|no match|syntax error' CMP7345_run.log \
        | head -5 >&2
    exit 1
fi

echo "    -> CMP7345_tran.txt ($(wc -l < CMP7345_tran.txt) lines)"

if python3 -c 'import matplotlib' >/dev/null 2>&1; then
    echo "=== plot ==="
    python3 ../plot.py CMP7345_tran.txt
fi

echo "done"
