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
set terminal pdfcairo size 30cm,20cm
set output "plots/latch2.pdf"
set multiplot layout 5,1 rowsfirst title "latch2 transient response" font ",16"
set grid xtics ytics
set border linewidth 1.2
set tics out
set key outside right center
set lmargin 12
set rmargin 24
set format x "%.0f"
set xlabel "Time (ns)"
set style line 1 lc rgb "#1f77b4" lw 2
set style line 2 lc rgb "#d62728" lw 2
set style line 3 lc rgb "#2ca02c" lw 2
set style line 4 lc rgb "#9467bd" lw 2
set style line 5 lc rgb "#ff7f0e" lw 2
set style line 6 lc rgb "#17becf" lw 2
set style line 7 lc rgb "#8c564b" lw 2
set style line 8 lc rgb "#7f7f7f" lw 2
set ylabel "D1 (V)"
set yrange [-0.1:1.3]
plot "results/latch2.txt" using ($1*1e9):2 with steps ls 1 title "D1"
set ylabel "D2 (V)"
set yrange [-0.1:1.3]
plot "results/latch2.txt" using ($1*1e9):3 with steps ls 2 title "D2"
set ylabel "Enable (V)"
set yrange [-0.1:1.3]
plot "results/latch2.txt" using ($1*1e9):4 with steps ls 3 title "EN"
set ylabel "OUT0 (V)"
set yrange [-0.1:1.3]
plot "results/latch2.txt" using ($1*1e9):5 with steps ls 4 title "OUT0"
set ylabel "OUT1 (V)"
set yrange [-0.1:1.3]
plot "results/latch2.txt" using ($1*1e9):6 with steps ls 5 title "OUT1"
unset multiplot
set output
