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
# Functional verification of the digitally controlled ideal switch.
#
# Panels:
#   1. Analog input and switched output.
#   2. Voltage difference V(p)-V(n).
#   3. Digital switch control.
#
# Expected behavior:
#
#   CONTROL = 1:
#      Switch closed.
#      V(n) follows V(p).
#      V(p)-V(n) approaches zero.
#
#   CONTROL = 0:
#      Switch open.
#      V(n) is pulled to zero by the load.
#      V(p) continues following the analog source.

set terminal pdfcairo enhanced font "Arial,11" size 12in,8in
set output "plots/sw.pdf"

set datafile commentschars "#"

# ============================================================
# Automatic simulation time range
# ============================================================

stats "results/sw.txt" using 1 nooutput

time_max = STATS_max * 1e9
time_step = time_max / 5.0

# ============================================================
# Common plot geometry
# ============================================================

set lmargin 11
set rmargin 8

set xrange [0:time_max]
set xtics time_step
set grid xtics ytics

set multiplot layout 3,1 title "Digitally controlled ideal switch" font ",14"

# ============================================================
# Analog input and output
# ============================================================

set title "Analog input and switched output"
set ylabel "Voltage (V)"
set xlabel "Time (ns)"

set yrange [-1.2:1.2]
set ytics 0.5
set key top right

plot "results/sw.txt" using ($1*1e9):2 with lines linewidth 1.7 title "V(p) - Input", \
     "results/sw.txt" using ($1*1e9):3 with lines linewidth 1.7 title "V(n) - Output"

# ============================================================
# Voltage across the ideal switch
# ============================================================

set title "Voltage difference across the switch"
set ylabel "V(p)-V(n) (V)"
set xlabel "Time (ns)"

set yrange [-1.2:1.2]
set ytics 0.5
set key top right

plot "results/sw.txt" using ($1*1e9):($2-$3) with lines linewidth 1.7 title "V(p)-V(n)", \
     0 with lines dashtype 2 linewidth 1.0 title "Closed-switch ideal"

# ============================================================
# Digital control
# ============================================================

set title "Switch control"
set ylabel "CONTROL"
set xlabel "Time (ns)"

set yrange [-0.15:1.15]
set ytics ("OFF" 0, "ON" 1)
unset key

plot "results/sw.txt" using ($1*1e9):4 with steps linewidth 1.7

unset multiplot
unset output
