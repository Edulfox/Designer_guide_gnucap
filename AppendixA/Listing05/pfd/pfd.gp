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
# Phase-frequency detector functional verification.
#
# The plot shows:
#   1. ACTIVE and REF input signals.
#   2. QDEC and QINC detector outputs.
#   3. RESET signal.
#
# The same PFD instance changes from QDEC operation
# to QINC operation as the phase relationship changes.

set terminal pdfcairo enhanced font "Arial,11" size 12in,8in
set output "plots/pfd.pdf"

set datafile commentschars "#"

# ============================================================
# Automatic time range
# ============================================================

stats "results/pfd.txt" using 1 nooutput

time_max = STATS_max * 1e9
time_step = time_max / 5.0

# ============================================================
# Common geometry
# ============================================================

set lmargin 11
set rmargin 12

set xrange [0:time_max]
set xtics time_step
set grid xtics

unset key

# Vertical spacing used to separate digital signals.
bit_height = 0.75
low_lane = 0.0
high_lane = 1.0

logic_level(x) = (x > 0.5 ? bit_height : 0.0)

set multiplot layout 3,1 title "PFD transient response" font ",14"

# ============================================================
# Input signals
# ============================================================

set title "Phase detector inputs"
set ylabel "Inputs"
set xlabel "Time (ns)"

set yrange [-0.15:1.90]
set ytics ("ACTIVE" low_lane+bit_height/2.0, "REF" high_lane+bit_height/2.0)

plot "results/pfd.txt" using ($1*1e9):(low_lane+logic_level($2)) with steps linewidth 1.5 title "ACTIVE", \
     "results/pfd.txt" using ($1*1e9):(high_lane+logic_level($3)) with steps linewidth 1.5 title "REF"

# ============================================================
# PFD outputs
# ============================================================

set title "Phase-frequency detector outputs"
set ylabel "Outputs"
set xlabel "Time (ns)"

set yrange [-0.15:1.90]
set ytics ("QDEC" low_lane+bit_height/2.0, "QINC" high_lane+bit_height/2.0)

plot "results/pfd.txt" using ($1*1e9):(low_lane+logic_level($5)) with steps linewidth 1.7 title "QDEC", \
     "results/pfd.txt" using ($1*1e9):(high_lane+logic_level($4)) with steps linewidth 1.7 title "QINC"

# ============================================================
# Reset
# ============================================================

set title "Reset"
set ylabel "RESET"
set xlabel "Time (ns)"

set yrange [-0.15:1.15]
set ytics ("0" 0, "1" 1)

plot "results/pfd.txt" using ($1*1e9):6 with steps linewidth 1.7 title "RESET"

unset multiplot
unset output
