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
# Functional verification plot for the digital counter.
# The figure compares the input clock with two counter instances:
# maxcount = 4 and maxcount = 9.

set terminal pdfcairo enhanced font "Arial,11" size 11in,8in
set output "plots/counter.pdf"

set datafile commentschars "#"

set multiplot layout 3,1 title "Digital Counter - Functional Verification" font ",14"

set grid xtics ytics
set xrange [0:250]
set yrange [-0.15:1.15]
set ytics ("0" 0, "1" 1)
set ylabel "Logic level"
unset xlabel
set format x ""

# Input clock.
set title "Input Clock - 100 MHz"
plot "results/counter.txt" using ($1*1e9):3 with steps linewidth 2 title "clk"

# Counter configured with maxcount = 4.
set title "Counter Output - maxcount = 4"
plot "results/counter.txt" using ($1*1e9):4 with steps linewidth 2 title "out4"

# Counter configured with maxcount = 9.
set title "Counter Output - maxcount = 9"
set xlabel "Time (ns)"
set format x "%g"
plot "results/counter.txt" using ($1*1e9):5 with steps linewidth 2 title "out9"

unset multiplot
unset output
