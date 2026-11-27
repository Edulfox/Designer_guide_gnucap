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
# Listing 16 A2D functional verification.
#
# Panels:
#   1. Source voltage, actual A2D input and thresholds.
#   2. Digital output.
#
# The difference between V(input_drive) and V(in) demonstrates
# the effect of the model input capacitance through the 100 kohm
# testbench source resistance.

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
vh = 2.7

set lmargin 11
set rmargin 8

set multiplot layout 2,1 title "Listing 16 A2D - Functional Verification" font ",14"

# ============================================================
# Analog input
# ============================================================

set title "Electrical input and logic thresholds"
set xlabel "Time (ns)"
set ylabel "Voltage (V)"

set xrange [0:time_max]
set xtics time_step
set yrange [-0.2:3.4]

set grid xtics ytics
set key top right

plot data_file using ($1*1e9):2 with lines linewidth 1.5 title "Source", \
     data_file using ($1*1e9):3 with lines linewidth 1.8 title "V(in)", \
     vh with lines dashtype 2 linewidth 1.2 title "vh = 2.7 V", \
     vl with lines dashtype 2 linewidth 1.2 title "vl = 0.5 V"

# ============================================================
# Digital output
# ============================================================

set title "A2D logic output"
set xlabel "Time (ns)"
set ylabel "OUT"

set xrange [0:time_max]
set yrange [-0.15:1.15]
set ytics ("LOW" 0, "HIGH" 1)

unset key

plot data_file using ($1*1e9):4 with steps linewidth 1.8

unset multiplot
unset output
