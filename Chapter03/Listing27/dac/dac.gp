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
set terminal pdfcairo enhanced font "Sans,13" size 13in,9in
set output "plots/dac.pdf"
datafile="results/dac.txt"
stats datafile using 1 nooutput
time_max=STATS_max*1e9
set multiplot layout 2,1 title "Chapter 3 Listing 27 - Eight-Bit Scalar DAC" font ",18" margins 0.09,0.97,0.08,0.92 spacing 0.08,0.10
set grid xtics ytics
set border linewidth 1.2
set tics out
set xrange [0:time_max]
set ylabel "DAC output (V)"
set yrange [-0.05:1.05]
unset xlabel
set key inside top right
plot datafile using ($1*1e9):11 with lines linewidth 2.2 title "Analog output"
set xlabel "Time (ns)"
set ylabel "Input bit lanes"
set yrange [-0.5:8.2]
set ytics ("b0" 0, "b1" 1, "b2" 2, "b3" 3, "b4" 4, "b5" 5, "b6" 6, "b7" 7)
unset key
plot datafile using ($1*1e9):($10*0.65+0) with steps linewidth 1.5, datafile using ($1*1e9):($9*0.65+1) with steps linewidth 1.5, datafile using ($1*1e9):($8*0.65+2) with steps linewidth 1.5, datafile using ($1*1e9):($7*0.65+3) with steps linewidth 1.5, datafile using ($1*1e9):($6*0.65+4) with steps linewidth 1.5, datafile using ($1*1e9):($5*0.65+5) with steps linewidth 1.5, datafile using ($1*1e9):($4*0.65+6) with steps linewidth 1.5, datafile using ($1*1e9):($3*0.65+7) with steps linewidth 1.5
unset multiplot
unset output
