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
set terminal pdfcairo enhanced font "Sans,13" size 12in,7in
set output "plots/sh.pdf"
datafile="results/sh.txt"
stats datafile using 1 nooutput
time_max=STATS_max*1e9
set title "Listing 23 - Ideal Periodic Sample and Hold" font ",17"
set xlabel "Time (ns)"
set ylabel "Voltage (V)"
set xrange [0:time_max]
set grid
set key outside top center horizontal
plot datafile using ($1*1e9):2 with lines linewidth 2.0 title "Input", datafile using ($1*1e9):3 with steps linewidth 2.2 title "Held output"
unset output
