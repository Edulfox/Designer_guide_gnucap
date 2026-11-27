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
set output "plots/time_interval_measurement.pdf"
datafile="results/time_interval_measurement.txt"
stats datafile using 1 nooutput
time_max=STATS_max*1e9
stats datafile using ($5*1e9) nooutput
final_mean=STATS_max
set multiplot layout 2,1 title "Chapter 3 Listing 25 - Time Interval Measurement" font ",18" margins 0.09,0.97,0.10,0.92 spacing 0.08,0.10
set grid xtics ytics
set border linewidth 1.2
set tics out
set xrange [0:time_max]
set ylabel "Edge signals (V)"
unset xlabel
set key inside top center horizontal
plot datafile using ($1*1e9):2 with lines linewidth 2.0 title "Start", datafile using ($1*1e9):3 with lines linewidth 2.0 title "Stop"
set xlabel "Time (ns)"
set ylabel "Measured delay (ns)"
set yrange [0:*]
set key inside top right
set label 1 sprintf("Final mean = %.3g ns", final_mean) at graph 0.98,0.88 right
plot datafile using ($1*1e9):($5*1e9) with steps linewidth 2.2 title "Running mean delay"
unset label 1
unset multiplot
unset output
