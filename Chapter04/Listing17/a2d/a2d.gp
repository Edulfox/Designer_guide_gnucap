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
# Listing 17 enhanced A2D functional verification.
#
# The model adds a timed unknown-state region:
#
#   vl  = 0.5 V
#   vlx = 0.7 V
#   vhx = 2.5 V
#   vh  = 2.7 V
#
# A slow transition must generate X after dt.
# A sufficiently fast transition must pass directly between
# LOW and HIGH without generating X.

reset

data_file = "results/a2d.txt"
output_file = "plots/a2d.pdf"

set terminal pdfcairo enhanced color size 11in,8in font "Arial,11"
set output output_file

set datafile commentschars "#"

stats data_file using 1 nooutput

time_max = STATS_max * 1e9
time_step = time_max / 5.0

vl = 0.5
vlx = 0.7
vhx = 2.5
vh = 2.7

set lmargin 11
set rmargin 8

set multiplot layout 2,1 title "Listing 17 A2D - Enhanced Functional Verification" font ",14"

# ============================================================
# Analog input and threshold regions
# ============================================================

set title "Electrical input and enhanced A2D thresholds"
set xlabel "Time (ns)"
set ylabel "Voltage (V)"

set xrange [0:time_max]
set xtics time_step
set yrange [-0.2:3.4]

set grid xtics ytics
set key top right

plot data_file using ($1*1e9):2 with lines linewidth 1.8 title "V(in)", \
     vh with lines dashtype 2 linewidth 1.2 title "vh = 2.7 V", \
     vhx with lines dashtype 3 linewidth 1.2 title "vhx = 2.5 V", \
     vlx with lines dashtype 3 linewidth 1.2 title "vlx = 0.7 V", \
     vl with lines dashtype 2 linewidth 1.2 title "vl = 0.5 V"

# ============================================================
# Logic output including unknown state
# ============================================================

set title "A2D logic output - slow versus fast transitions"
set xlabel "Time (ns)"
set ylabel "OUT"

set xrange [0:time_max]
set yrange [-0.15:1.15]
set ytics ("LOW" 0, "X" 0.5, "HIGH" 1)

unset key

plot data_file using ($1*1e9):3 with steps linewidth 1.8

unset multiplot
unset output
