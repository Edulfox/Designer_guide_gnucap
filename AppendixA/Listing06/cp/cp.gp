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
set output "plots/cp.pdf"
set multiplot layout 3,1 rowsfirst title "cp transient response" font ",16"
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
set style line 4 lc rgb "#000000" lw 2
set ylabel "INC (V)"
set yrange [-0.1:1.3]
plot "results/cp.txt" using ($1*1e9):2 with steps ls 1 title "INC"
set ylabel "DEC (V)"
set yrange [-0.1:1.3]
plot "results/cp.txt" using ($1*1e9):3 with steps ls 2 title "DEC"
set ylabel "Output node (V)"
set yrange [*:*]
plot "results/cp.txt" using ($1*1e9):4 with lines ls 3 title "V(out)"
unset multiplot
set output
