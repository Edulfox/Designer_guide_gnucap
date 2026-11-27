#############################################################################
# Copyright 2026 IHP-Open-PDK Authors
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#############################################################################
#
# Functional verification plot for the frequency measurement model.
#
# Expected values:
# - clk100 -> approximately 100 MHz
# - clk25  -> approximately 25 MHz
#
# Input file columns:
# 1: Time
# 2: v(clk100_probe)
# 3: v(clk25_probe)
# 4: freq(dut100)
# 5: freq(dut25)
# 6: iter(0)

set terminal pdfcairo enhanced font "Arial,11" size 11in,8in
set output "plots/freq_meas.pdf"

set datafile commentschars "#"

set multiplot layout 3,1 title "Frequency Measurement - Functional Verification" font ",14"

# ------------------------------------------------------------
# 100 MHz input clock
# ------------------------------------------------------------

set grid xtics ytics
set xrange [0:250]
set yrange [-0.15:1.15]
set ytics ("0" 0, "1" 1)
set ylabel "Logic level"
unset xlabel
set format x ""

set title "Input Clock - Expected Frequency: 100 MHz"
plot "results/freq_meas.txt" using ($1*1e9):2 with steps linewidth 2 title "clk100"

# ------------------------------------------------------------
# 25 MHz input clock
# ------------------------------------------------------------

set title "Input Clock - Expected Frequency: 25 MHz"
plot "results/freq_meas.txt" using ($1*1e9):3 with steps linewidth 2 title "clk25"

# ------------------------------------------------------------
# Measured frequencies
# ------------------------------------------------------------

set title "Measured Frequency"
set xlabel "Time (ns)"
set format x "%g"

set ylabel "Frequency (MHz)"
set yrange [0:115]
set ytics 25

plot "results/freq_meas.txt" using ($1*1e9):($4/1e6) with steps linewidth 2 title "Measured clk100", \
     "results/freq_meas.txt" using ($1*1e9):($5/1e6) with steps linewidth 2 title "Measured clk25", \
     100 with lines dashtype 2 linewidth 1 title "Expected 100 MHz", \
     25 with lines dashtype 2 linewidth 1 title "Expected 25 MHz"

unset multiplot
unset output
