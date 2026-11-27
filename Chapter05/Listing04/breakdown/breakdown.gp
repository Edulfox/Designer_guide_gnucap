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
set output "plots/breakdown.pdf"
datafile="results/breakdown.txt"
stats datafile using 1 nooutput
time_max=STATS_max*1e9
set multiplot layout 2,1 margins 0.09,0.96,0.10,0.93 spacing 0.05,0.08 title "Listing 4 - Breakdown Sentinel" font ",18"
set grid
set xrange [0:time_max]
set ylabel "Node voltage (V)"
set arrow from graph 0, first 5 to graph 1, first 5 nohead dashtype 2
plot datafile using ($1*1e9):2 with lines linewidth 2.2 title "Monitored voltage"
unset arrow
set xlabel "Time (ns)"
set ylabel "Warning state"
set yrange [-0.2:1.2]
set ytics ("Not triggered" 0, "Triggered" 1)
plot datafile using ($1*1e9):3 with steps linewidth 2.2 title "given"
unset multiplot
unset output
