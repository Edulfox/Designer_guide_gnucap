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
set output "plots/quantizer.pdf"
datafile="results/quantizer.txt"
stats datafile using 1 nooutput
time_max=STATS_max*1e9
set multiplot layout 2,1 title "Appendix A Listing 1 - N-Level Quantizer" font ",18" margins 0.09,0.97,0.10,0.92 spacing 0.08,0.10
set grid xtics ytics
set border linewidth 1.2
set tics out
set xrange [0:time_max]
set ylabel "Voltage (V)"
unset xlabel
set key inside top left horizontal
plot datafile using ($1*1e9):2 with lines linewidth 2.2 title "Analog input", datafile using ($1*1e9):4 with steps linewidth 2.2 title "Quantized output"
set xlabel "Time (ns)"
set ylabel "Clock (V)"
set yrange [-1.15:1.15]
set key inside top right
plot datafile using ($1*1e9):3 with steps linewidth 1.8 title "Sampling clock"
unset multiplot
unset output
