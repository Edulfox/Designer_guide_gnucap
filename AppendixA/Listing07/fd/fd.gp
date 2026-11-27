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
set terminal pdfcairo enhanced font "Sans,13" size 12in,8in
set output "plots/fd.pdf"
datafile="results/fd.txt"
stats datafile using 1 nooutput
time_max=STATS_max*1e9
clock_zoom=(time_max<20.0 ? time_max : 20.0)
set multiplot layout 3,1 title "Appendix A Listing 7 - Frequency Divider Functional Verification" font ",18" margins 0.09,0.97,0.08,0.92 spacing 0.07,0.09
set grid xtics ytics
set border linewidth 1.2
set tics out
set yrange [-0.1:1.1]
set ytics 0,0.5,1
set ylabel "Clock (V)"
set xrange [0:clock_zoom]
unset xlabel
set key inside top right
plot datafile using ($1*1e9):2 with steps linewidth 1.8 title "Input clock"
set ylabel "Reset (V)"
set xrange [0:time_max]
unset xlabel
set key inside top right
plot datafile using ($1*1e9):3 with steps linewidth 2.0 title "Reset"
set ylabel "Output (V)"
set xlabel "Time (ns)"
set xrange [0:time_max]
set key inside top right
plot datafile using ($1*1e9):4 with steps linewidth 2.0 title "Divided output"
unset multiplot
unset output
