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
# Designer's Guide Listing 18 D2A functional verification.
#
# Two complementary loads verify both the output voltage
# and the finite 1 kOhm output resistance.

reset

data_file = "results/d2a.txt"
output_file = "plots/d2a.pdf"

set terminal pdfcairo enhanced color size 11in,8in font "Arial,11"
set output output_file

set datafile commentschars "#"

stats data_file using 1 nooutput

time_max = STATS_max * 1e9
time_step = time_max / 6.0

set lmargin 10
set rmargin 8

set multiplot layout 2,1 title "Listing 18 D2A - Functional Verification" font ",14"

set title "Digital input stimulus"
set xlabel "Time (ns)"
set ylabel "Input (V)"
set xrange [0:time_max]
set xtics time_step
set yrange [-0.25:5.25]
set ytics 1
set grid xtics ytics
unset key

plot data_file using ($1*1e9):2 with steps linewidth 1.8

set title "Loaded D2A outputs"
set xlabel "Time (ns)"
set ylabel "Output voltage (V)"
set xrange [0:time_max]
set xtics time_step
set yrange [-0.25:5.25]
set ytics 1
set grid xtics ytics
set key top right

plot data_file using ($1*1e9):3 with lines linewidth 1.8 title "1 kOhm to GND", \
     data_file using ($1*1e9):4 with lines linewidth 1.8 title "1 kOhm to 5 V", \
     2.5 with lines dashtype 2 linewidth 1.2 title "Expected divider = 2.5 V"

unset multiplot
unset output
