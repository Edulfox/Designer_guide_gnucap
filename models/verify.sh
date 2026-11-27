#!/bin/bash
########################################################################
#
# Verification for the models/ tree.
#
#   ./verify.sh            check files, run behavioral models, validate
#   ./verify.sh --device   also run the (slow) device-level model
#
########################################################################

set -u

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT"

PASS=0
FAIL=0

ok()   { echo "  OK   $1"; PASS=$((PASS+1)); }
bad()  { echo "  FAIL $1"; FAIL=$((FAIL+1)); }

check_file() {
    if [ -f "$1" ]; then ok "$1"; else bad "$1 missing"; fi
}

echo "=== 1. files ==="
check_file README.md
check_file behavioral/build.sh
check_file behavioral/run.sh
check_file behavioral/comp_std.vams
check_file behavioral/comp_reg.vams
check_file behavioral/comp_mix.vams
check_file behavioral/comp_reg_logic_ref.vams
check_file behavioral/clock_logic_ref.vams
check_file behavioral/elect_to_logic.vams
check_file behavioral/logic_to_elect.vams
check_file behavioral/vpwl.vams
check_file behavioral/vpulse.vams
check_file behavioral/comp_std_tb.gc
check_file behavioral/comp_reg_tb.gc
check_file behavioral/comp_mix_tb.gc
check_file behavioral/comp_reg_logic_tb.gc
check_file device/build.sh
check_file device/run.sh
check_file device/CMP7345.va
check_file device/vpwl.vams
check_file device/CMP7345_tb.gc
check_file plot.py
check_file verify.sh

echo
echo "=== 2. behavioral models ==="
( cd behavioral && ./build.sh > build.log 2>&1 )
if [ -f behavioral/comp_std.so ] && [ -f behavioral/comp_reg.so ] && [ -f behavioral/comp_mix.so ] && [ -f behavioral/comp_reg_logic_ref.so ] && [ -f behavioral/clock_logic_ref.so ] && [ -f behavioral/vpwl.so ] && [ -f behavioral/vpulse.so ]; then
    ok "models compiled"
else
    bad "model compilation"
fi

( cd behavioral && ./run.sh > run.log 2>&1 )
if [ -s behavioral/comp_std_tran.txt ] && [ -s behavioral/comp_reg_tran.txt ] \
   && [ -s behavioral/comp_mix_tran.txt ] \
   && [ -s behavioral/comp_reg_logic_tran.txt ]; then
    ok "simulations produced output"
else
    bad "simulation output missing"
fi

# Resolve column numbers from the header so the checks survive probe changes.
col() {  # col <file> <signal>
    awk -v want="$2" 'NR==1 {
        sub(/^#/, "")
        for (i = 1; i <= NF; i++) if ($i == want) { print i; exit }
    }' "$1"
}

# Look for a settled low state (outp low, outn high) and a settled high
# state (outp high, outn low); the low state must come first.
check_transitions() {  # check_transitions <label> <file> [outp] [outn]
    label=$1
    file=$2
    t=$(col "$file" "Time")
    p=$(col "$file" "${3:-v(outp)}")
    n=$(col "$file" "${4:-v(outn)}")

    if [ -z "$t" ] || [ -z "$p" ] || [ -z "$n" ]; then
        bad "$label: incomplete header in $file"
        return
    fi

    low=$(awk -v t="$t" -v p="$p" -v n="$n" \
        'NR>1 && $p<0.3 && $n>0.9 {print $t, $p, $n; exit}' "$file")
    high=$(awk -v t="$t" -v p="$p" -v n="$n" \
        'NR>1 && $p>0.9 && $n<0.3 {print $t, $p, $n; exit}' "$file")

    if [ -n "$low" ] && [ -n "$high" ]; then
        awk -v a="$low" -v b="$high" \
            'BEGIN{split(a,x," "); split(b,y," "); exit !(x[1]<y[1])}' \
            && ok "$label: low then high (inp<inn then inp>inn)" \
            || bad "$label: wrong order (low=$low high=$high)"
    else
        bad "$label transitions (low=$low high=$high)"
    fi
}

check_transitions "comp_std" behavioral/comp_std_tran.txt
check_transitions "comp_reg" behavioral/comp_reg_tran.txt
check_transitions "comp_mix" behavioral/comp_mix_tran.txt
check_transitions "comp_reg_logic" behavioral/comp_reg_logic_tran.txt \
    "v(outp_a)" "v(outn_a)"

# comp_mix: the internally generated digital clock must be gated (low while
# the enable is low) and run at the programmed period once enabled.
mix_f=behavioral/comp_mix_tran.txt
c_clk=$(col "$mix_f" "v(clk)")
c_en=$(col "$mix_f" "v(en)")

if [ -n "$c_clk" ] && [ -n "$c_en" ]; then
    awk -v c="$c_clk" -v e="$c_en" \
        'NR>1 && $e<1.0 && $c>0.1 {bad=1} END{exit bad}' "$mix_f" \
        && ok "comp_mix: clock gated low while enable is low" \
        || bad "comp_mix: clock runs while disabled"

    period=$(awk -v c="$c_clk" '
        NR>1 {
            v = $c
            if (prev <= 0.6 && v > 0.6) {
                if (t1 == "") { t1 = $1 } else { printf "%.4g", $1 - t1; exit }
            }
            prev = v
        }' "$mix_f")
    awk -v p="$period" 'BEGIN{exit !(p > 8e-9 && p < 12e-9)}' \
        && ok "comp_mix: clock period ${period}s" \
        || bad "comp_mix: unexpected clock period (${period:-none})"
else
    bad "comp_mix: clock/enable columns missing"
fi

# comp_reg_logic: check the electrical -> logic -> electrical clock path.
logic_f=behavioral/comp_reg_logic_tran.txt
l_clk=$(col "$logic_f" "v(clk_a)")

if [ -n "$l_clk" ]; then
    awk -v c="$l_clk" 'NR>1 && $1+0 < 6e-9 && $c > 0.1 {bad=1} END{exit bad}' "$logic_f" \
        && ok "comp_reg_logic: converted clock low before 6 ns" \
        || bad "comp_reg_logic: clock starts too early"

    period=$(awk -v c="$l_clk" '
        NR>1 {
            v = $c
            if (prev <= 0.6 && v > 0.6) {
                if (t1 == "") { t1 = $1 } else { printf "%.4g", $1 - t1; exit }
            }
            prev = v
        }' "$logic_f")
    awk -v p="$period" 'BEGIN{exit !(p > 9.5e-9 && p < 10.5e-9)}' \
        && ok "comp_reg_logic: connect-module clock period ${period}s" \
        || bad "comp_reg_logic: unexpected clock period (${period:-none})"
else
    bad "comp_reg_logic: clk_a column missing"
fi

# Both inputs must be recorded so they can share one plot panel.
for f in behavioral/comp_std_tran.txt behavioral/comp_reg_tran.txt \
         behavioral/comp_mix_tran.txt behavioral/comp_reg_logic_tran.txt; do
    n_in=0
    [ -n "$(col "$f" "v(inp)")" ] && n_in=$((n_in+1))
    [ -n "$(col "$f" "v(inn)")" ] && n_in=$((n_in+1))
    [ "$n_in" -eq 2 ] && ok "$(basename "$f"): both inputs present" \
                      || bad "$(basename "$f"): inputs missing"
done

echo
echo "=== 3. plots ==="
if python3 -c 'import matplotlib' >/dev/null 2>&1; then
    ( cd behavioral && python3 ../plot.py comp_std_tran.txt comp_reg_tran.txt comp_mix_tran.txt comp_reg_logic_tran.txt > /dev/null 2>&1 )
    if [ -s behavioral/comp_std_tran.png ] && [ -s behavioral/comp_reg_tran.png ] \
       && [ -s behavioral/comp_mix_tran.png ] \
       && [ -s behavioral/comp_reg_logic_tran.png ]; then
        ok "matplotlib plots generated (horizontal subplots)"
    else
        bad "matplotlib plots"
    fi

    # Both inputs must land in the same ("inputs") panel.
    groups=$( cd behavioral && python3 ../plot.py --groups comp_std_tran.txt )
    echo "$groups" | grep -q 'inputs: v(inp) v(inn)' \
        && ok "comp_std: inputs share one panel" \
        || bad "comp_std: inputs not grouped together"
    echo "$groups" | grep -q 'outputs: v(outp) v(outn)' \
        && ok "comp_std: outputs share one panel" \
        || bad "comp_std: outputs not grouped together"

    groups=$( cd behavioral && python3 ../plot.py --groups comp_mix_tran.txt )
    echo "$groups" | grep -q 'inputs: v(inp) v(inn)' \
        && ok "comp_mix: inputs share one panel" \
        || bad "comp_mix: inputs not grouped together"
    echo "$groups" | grep -q 'clock: v(en) v(clk)' \
        && ok "comp_mix: clock/enable share one panel" \
        || bad "comp_mix: clock panel grouping"

    groups=$( cd behavioral && python3 ../plot.py --groups comp_reg_logic_tran.txt )
    echo "$groups" | grep -q 'inputs: v(inp) v(inn)' \
        && ok "comp_reg_logic: inputs share one panel" \
        || bad "comp_reg_logic: inputs not grouped together"
    echo "$groups" | grep -q 'clock: v(clk_a)' \
        && ok "comp_reg_logic: clock panel present" \
        || bad "comp_reg_logic: clock panel grouping"
    echo "$groups" | grep -q 'outputs: v(outp_a) v(outn_a)' \
        && ok "comp_reg_logic: outputs share one panel" \
        || bad "comp_reg_logic: outputs not grouped together"

    ( cd behavioral && python3 ../plot.py comp_std_tran.txt --layout stacked --out svg > /dev/null 2>&1 )
    [ -s behavioral/comp_std_tran.svg ] && ok "stacked layout works" || bad "stacked layout"
else
    echo "  SKIP python3/matplotlib not available"
fi

if [ "${1:-}" = "--device" ]; then
    echo
    echo "=== 4. device-level model (slow) ==="

    rm -f device/CMP7345_tran.txt
    if ( cd device && ./run.sh > run.log 2>&1 ); then
        ok "CMP7345 build and simulation"
    else
        bad "CMP7345 run failed (see device/run.log)"
    fi

    for f in pdk/sg13g2_moslv_paramset.so pdk/sg13g2_moslv_rf_paramset.so \
             pdk/resistor_paramset.so pdk/capacitor_paramset.so pdk/idc.so; do
        check_file "device/$f"
    done

    f=device/CMP7345_tran.txt
    if [ -s "$f" ]; then
        ok "CMP7345 simulation produced output"

        if [ -n "$(find "$f" -newer device/CMP7345_tb.gc -print -quit 2>/dev/null)" ]; then
            ok "CMP7345 output is fresh"
        else
            bad "CMP7345 output is stale"
        fi

        p=$(col "$f" "v(vout1)")
        n=$(col "$f" "v(vout2)")
        low=$(awk -v p="$p" -v n="$n" 'NR>1 && $p<0.4 && $n>1.0 {print $1; exit}' "$f")
        high=$(awk -v p="$p" -v n="$n" 'NR>1 && $p>1.0 && $n<0.4 {print $1; exit}' "$f")
        echo "  info: vout1 low at ${low:-none}s, high at ${high:-none}s"
        if [ -n "$low" ] && [ -n "$high" ]; then
            awk -v a="$low" -v b="$high" 'BEGIN{exit !(a<b)}' \
                && ok "CMP7345 resolves both ways as the input ramps" \
                || bad "CMP7345 decisions in the wrong order"
        else
            bad "CMP7345 did not resolve in both directions"
        fi

        n_in=0
        [ -n "$(col "$f" "v(vinp)")" ] && n_in=$((n_in+1))
        [ -n "$(col "$f" "v(vinn)")" ] && n_in=$((n_in+1))
        [ "$n_in" -eq 2 ] && ok "CMP7345: both inputs present" \
                          || bad "CMP7345: inputs missing"

        groups=$( cd device && python3 ../plot.py --groups CMP7345_tran.txt 2>/dev/null )
        echo "$groups" | grep -q 'inputs: v(vinp) v(vinn)' \
            && ok "CMP7345: inputs share one panel" \
            || bad "CMP7345: inputs not grouped together"
        echo "$groups" | grep -q 'outputs: v(vout1) v(vout2)' \
            && ok "CMP7345: outputs share one panel" \
            || bad "CMP7345: outputs not grouped together"
    else
        bad "CMP7345 simulation output missing"
    fi
fi

echo
echo "=== summary: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
