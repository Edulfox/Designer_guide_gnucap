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
# Comparator functional verification.
#
# The test uses:
#
#   offset = 0.05 V
#   hyst   = 0.10 V
#
# Therefore:
#
#   VTH_LOW  = 0.00 V
#   VTH_HIGH = 0.10 V
#
# Panels:
#   1. Analog differential input and both switching thresholds.
#   2. Digital comparator output.
#   3. Output versus input voltage, showing the hysteresis loop.

reset

data_file = "results/comparator.txt"
output_file = "plots/comparator.pdf"

set terminal pdfcairo enhanced color size 11in,10in font "Arial,11"
set output output_file

set datafile commentschars "#"

stats data_file using 1 nooutput

time_max = STATS_max * 1e9
time_step = time_max / 5.0

thrlo = 0.00
thrhi = 0.10

set lmargin 11
set rmargin 8

set multiplot layout 2,1 title "Comparator - Functional Verification" font ",14"

# ============================================================
# Analog input and thresholds
# ============================================================

set title "Differential input and hysteresis thresholds"
set xlabel "Time (ns)"
set ylabel "Voltage (V)"

set xrange [0:time_max]
set xtics time_step
set yrange [-0.45:0.25]

set grid xtics ytics
set key top right

plot data_file using ($1*1e9):2 with lines linewidth 1.7 title "V(p,n)", thrhi with lines dashtype 2 linewidth 1.3 title "Upper threshold = 0.10 V", thrlo with lines dashtype 2 linewidth 1.3 title "Lower threshold = 0.00 V"

# ============================================================
# Digital output
# ============================================================

set title "Comparator logic output"
set xlabel "Time (ns)"
set ylabel "OUT"

set xrange [0:time_max]
set yrange [-0.15:1.15]
set ytics ("LOW" 0, "HIGH" 1)

unset key

plot data_file using ($1*1e9):3 with steps linewidth 1.7



unset multiplot
unset output
