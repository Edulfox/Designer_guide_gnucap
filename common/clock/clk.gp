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


reset

data_file = "results/clk.txt"
output_file = "plots/clk.pdf"

set terminal pdfcairo enhanced color size 12in,6in font "Arial,9"
set output output_file

set datafile commentschars "#"

# ============================================================
# Automatic simulation time range
# ============================================================

stats data_file using 1 nooutput

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
set key top right

set title "Clock verifications" font ",16"

# ============================================================
# Automatic simulation time range
# ============================================================

stats data_file using 1 nooutput

time_max = STATS_max * 1e9
time_step = time_max / 5.0


# ============================================================
# Sampling clock
# ============================================================

set ylabel "CLK"
set xlabel "Time (ns)"

set yrange [-0.15:1.15]
set ytics ("LOW" 0, "HIGH" 1)

unset key

plot data_file using ($1*1e9):2 with steps linewidth 1.7


unset output
