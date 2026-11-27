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

set terminal pdfcairo enhanced font "Sans,14" size 14in,14in
set output "plots/bidir.pdf"

datafile = "results/bidir.txt"

stats datafile using 1 nooutput
time_max = STATS_max * 1e9
time_step = time_max / 5.0

set multiplot layout 4,1 margins 0.08,0.94,0.06,0.95 spacing 0.04,0.08 title "Listing 19 Bidir - Functional Verification" font ",20"

set grid xtics ytics
set border linewidth 1.3

set lmargin 11
set rmargin 11

set xrange [0:time_max]
set xtics time_step font ",13"
set ytics font ",13"

set xlabel "Time (ns)" font ",14"
set ylabel font ",14"
set title font ",15"

set key font ",12"
set key opaque
set key samplen 2.5
set key spacing 1.2

# ======================================================================
# 1. DIGITAL-TO-ANALOG PATH
# ======================================================================

unset y2tics
unset y2label

set title "Digital-to-Analog Path and Thevenin Output Resistance"

set ylabel "Voltage (V)"
set yrange [-0.25:5.5]
set ytics 1

set key outside top center horizontal

plot datafile using ($1*1e9):2 with steps linewidth 2.5 title "Digital input", \
     datafile using ($1*1e9):3 with lines linewidth 2.5 title "1 kOhm to GND", \
     datafile using ($1*1e9):4 with lines linewidth 2.5 title "1 kOhm to 5 V"

# ======================================================================
# 2. FAST TRANSITION
# ======================================================================

set title "Fast Analog Transition - X Region Shorter than xdelay"

set ylabel "Voltage (V)"
set yrange [-0.25:5.5]
set ytics 1 font ",13"

set y2range [0.5:3.5]
set y2tics ("HIGH" 1, "X" 2, "LOW" 3) font ",13"

set key outside top center horizontal

set arrow 1 from graph 0, first 0.5 to graph 1, first 0.5 nohead dashtype 2 linewidth 1.3
set arrow 2 from graph 0, first 2.7 to graph 1, first 2.7 nohead dashtype 2 linewidth 1.3

set label 1 "vl = 0.5 V" at graph 0.015, first 0.68 font ",12"
set label 2 "vh = 2.7 V" at graph 0.015, first 2.88 font ",12"

plot datafile using ($1*1e9):5 axes x1y1 with lines linewidth 2.5 title "Fast analog input", \
     datafile using ($1*1e9):6 axes x1y1 with steps linewidth 2.5 title "Digital output", \
     datafile using ($1*1e9):7 axes x1y2 with steps linewidth 2.5 title "vstate"

unset arrow 1
unset arrow 2
unset label 1
unset label 2

# ======================================================================
# 3. SLOW TRANSITION
# ======================================================================

set title "Slow Analog Transition - X Region Longer than xdelay"

set ylabel "Voltage (V)"
set yrange [-0.25:5.5]
set ytics 1 font ",13"

set y2range [0.5:3.5]
set y2tics ("HIGH" 1, "X" 2, "LOW" 3) font ",13"

set key outside top center horizontal

set arrow 3 from graph 0, first 0.5 to graph 1, first 0.5 nohead dashtype 2 linewidth 1.3
set arrow 4 from graph 0, first 2.7 to graph 1, first 2.7 nohead dashtype 2 linewidth 1.3

set label 3 "vl = 0.5 V" at graph 0.015, first 0.68 font ",12"
set label 4 "vh = 2.7 V" at graph 0.015, first 2.88 font ",12"

plot datafile using ($1*1e9):8 axes x1y1 with lines linewidth 2.5 title "Slow analog input", \
     datafile using ($1*1e9):9 axes x1y1 with steps linewidth 2.5 title "Digital output", \
     datafile using ($1*1e9):10 axes x1y2 with steps linewidth 2.5 title "vstate"

unset arrow 3
unset arrow 4
unset label 3
unset label 4

# ======================================================================
# 4. HIGH-IMPEDANCE CURRENT QUALIFICATION
# ======================================================================

set title "High-Impedance Current Qualification - zdelay"

set ylabel "Test voltage (V)"
set yrange [-0.025:0.225]
set ytics 0.05 font ",13"

set y2range [-0.2:1.2]
set y2tics ("Within Hi-Z limit" 0, "Above limit" 1) font ",12"

set key outside top center horizontal

plot datafile using ($1*1e9):11 axes x1y1 with lines linewidth 2.5 title "Current-test voltage", \
     datafile using ($1*1e9):12 axes x1y2 with steps linewidth 2.5 title "istate"

unset multiplot
unset output
