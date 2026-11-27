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

if [ ! -f comp_std.so ] || [ ! -f comp_reg.so ] || [ ! -f comp_mix.so ] \
   || [ ! -f comp_reg_logic_ref.so ] || [ ! -f clock_logic_ref.so ] \
   || [ ! -f elect_to_logic.so ] || [ ! -f logic_to_elect.so ] \
   || [ ! -f vpwl.so ] || [ ! -f vpulse.so ]; then
    echo "building models..."
    ./build.sh
fi

run_sim() {
    tb="$1"
    out="$2"
    log="${out%_tran.txt}_run.log"
    rm -f "$out" "$log"
    if ! gnucap "$tb" > "$log" 2>&1; then
        echo "simulation failed, see $log" >&2
        exit 1
    fi
    if grep -qE 'undefined symbol|Bus error|Cannot find|no match' "$log"; then
        echo "simulation error, see $log" >&2
        tail -5 "$log" >&2
        exit 1
    fi
    if [ ! -s "$out" ]; then
        echo "no output produced, see $log" >&2
        exit 1
    fi
    echo "    -> $out ($(wc -l < "$out") lines)"
}

echo "=== comp_std: standard StrongARM latch ==="
run_sim comp_std_tb.gc comp_std_tran.txt

echo "=== comp_reg: registered outputs + gated clock ==="
run_sim comp_reg_tb.gc comp_reg_tran.txt

echo "=== comp_mix: digital clock + digitized outputs ==="
run_sim comp_mix_tb.gc comp_mix_tran.txt

echo "=== comp_reg_logic: logic-domain model + connect modules ==="
run_sim comp_reg_logic_tb.gc comp_reg_logic_tran.txt

if python3 -c 'import matplotlib' >/dev/null 2>&1; then
    echo "=== plots ==="
    python3 ../plot.py comp_std_tran.txt comp_reg_tran.txt comp_mix_tran.txt \
        comp_reg_logic_tran.txt
fi

echo "done"
