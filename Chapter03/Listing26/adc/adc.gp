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
set terminal pdfcairo enhanced font "Sans,13" size 13in,10in
set output "plots/adc.pdf"
datafile="results/adc.txt"
stats datafile using 1 nooutput
time_max=STATS_max*1e9
set multiplot layout 3,1 title "Chapter 3 Listing 26 - Eight-Bit Scalar ADC" font ",18" margins 0.09,0.97,0.07,0.93 spacing 0.06,0.08
set grid xtics ytics
set border linewidth 1.2
set tics out
set xrange [0:time_max]
set ylabel "Input (V)"
unset xlabel
set key inside top right
plot datafile using ($1*1e9):2 with lines linewidth 2.2 title "Analog input"
set ylabel "Bit lanes"
set yrange [-0.5:8.2]
set ytics ("b0" 0, "b1" 1, "b2" 2, "b3" 3, "b4" 4, "b5" 5, "b6" 6, "b7" 7)
unset xlabel
unset key
plot datafile using ($1*1e9):($11*0.65+0) with steps linewidth 1.6, datafile using ($1*1e9):($10*0.65+1) with steps linewidth 1.6, datafile using ($1*1e9):($9*0.65+2) with steps linewidth 1.6, datafile using ($1*1e9):($8*0.65+3) with steps linewidth 1.6, datafile using ($1*1e9):($7*0.65+4) with steps linewidth 1.6, datafile using ($1*1e9):($6*0.65+5) with steps linewidth 1.6, datafile using ($1*1e9):($5*0.65+6) with steps linewidth 1.6, datafile using ($1*1e9):($4*0.65+7) with steps linewidth 1.6
set ylabel "Clock (V)"
set xlabel "Time (ns)"
set yrange [-0.1:1.1]
set ytics 0,0.5,1
set key inside top right
plot datafile using ($1*1e9):3 with lines linewidth 1.7 title "Sampling clock"
unset multiplot
unset output
