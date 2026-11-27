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

set terminal pdfcairo enhanced font "Sans,12" size 12in,8in
set output "plots/pll.pdf"

set datafile commentschars "#"
set border linewidth 1.2
set grid xtics ytics
set tics out
set key outside top center horizontal
set xrange [0:500]

set multiplot layout 3,1 title "Appendix A Listing 04 - PLL Functional Verification" font ",17" #margins 0.09,0.97,0.09,0.93 spacing 0.8,0.10

set ylabel "Logic state"
set yrange [-0.15:1.15]
set ytics 0,1,1
unset xlabel
plot "results/pll.txt" using ($1*1e9):(($2>1.5)?1:0) with steps linewidth 2 title "REF", \
     "" using ($1*1e9):(($3>1.5)?1:0) with steps linewidth 2 title "FB"

set ylabel "PFD state"
set yrange [-0.15:1.15]
set ytics 0,1,1
unset xlabel
plot "results/pll.txt" using ($1*1e9):(($4>1.5)?1:0) with steps linewidth 2 title "UP", \
     "" using ($1*1e9):(($5>1.5)?1:0) with steps linewidth 2 title "DOWN"

set ylabel "ERR (V)"
set xlabel "Time (ns)"
set yrange [-0.25:0.25]
set ytics 0.1
set zeroaxis linewidth 1
plot "results/pll.txt" using ($1*1e9):6 with lines linewidth 2 title "Loop-filter control voltage"

unset multiplot
unset output
