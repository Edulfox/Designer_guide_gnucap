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
# Voltage-controlled oscillator functional verification.
#
# File columns:
#   1 -> Time
#   2 -> V(ps)          Analog control voltage
#   3 -> V(out_probe_v) Electrical representation of digital output
#   4 -> l(out)         Native logic state
#   5 -> iter(0)
#
# Expected behavior:
#   V(ps) = 0 V -> f_out approximately 100 MHz
#   V(ps) = 1 V -> f_out approximately 200 MHz

reset

data_file = "results/vco.txt"
output_file = "plots/vco.pdf"

set terminal pdfcairo enhanced color size 12in,8in font "Arial,11"
set output output_file

set datafile commentschars "#"

# ============================================================
# Automatic time range
# ============================================================

stats data_file using 1 nooutput

time_max = STATS_max * 1e9
time_step = time_max / 5.0

# ============================================================
# Common geometry
# ============================================================

set lmargin 11
set rmargin 8

set xrange [0:time_max]
set xtics time_step
set grid xtics ytics

set multiplot layout 2,1 title "Voltage Controlled Oscillator - Functional Verification" font ",14"

# ============================================================
# Analog control voltage
# ============================================================

set title "VCO control voltage"
set ylabel "V(ps) (V)"
set xlabel "Time (ns)"

set yrange [-0.1:1.1]
set ytics 0.2
unset key

plot data_file using ($1*1e9):2 with steps linewidth 1.7 title "V(ps)"

# ============================================================
# Electrical representation of the digital output
# ============================================================

set title "VCO output waveform"
set ylabel "Output voltage (V)"
set xlabel "Time (ns)"

set yrange [-0.15:1.15]
set ytics 0.2

plot data_file using ($1*1e9):3 with steps linewidth 1.7 title "V(out)"



unset multiplot
unset output
