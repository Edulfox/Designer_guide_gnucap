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
#
# DAC transient-response verification.
#
# All panels use the same fixed horizontal margins so that
# equal time values are vertically aligned between plots.

set terminal pdfcairo enhanced font "Arial,11" size 12in,8in
set output "plots/dac.pdf"

set datafile commentschars "#"

# ============================================================
# Automatically determine simulation time range
# ============================================================

stats "results/dac.txt" using 1 nooutput

time_max = STATS_max * 1e9
time_step = time_max / 5.0

# ============================================================
# Common plot geometry
# ============================================================
#
# Fixed margins guarantee identical horizontal plot lengths.
# Therefore, every time instant is vertically aligned between
# the analog output, clock and digital-input panels.

set lmargin 10
set rmargin 15

set multiplot layout 3,1 title "DAC transient response" font ",14"

# ============================================================
# DAC digital input bits
# ============================================================

set xlabel "Time (ns)"
set ylabel "Input states"

set xrange [0:time_max]
set xtics time_step

# Each bit occupies an independent vertical lane.
#
# HIGH level = 0.80
# Lane spacing = 1.00
# Gap between adjacent bits = 0.20

bit_height = 0.80

b0_offset = 0.0
b1_offset = 1.0
b2_offset = 2.0
b3_offset = 3.0
b4_offset = 4.0
b5_offset = 5.0
b6_offset = 6.0
b7_offset = 7.0

# Normalize Gnucap logic states to visual LOW/HIGH levels.
logic_level(x) = (x > 1.5 ? bit_height : 0.0)

set yrange [-0.25:8.05]

set ytics ( \
    "b0" b0_offset+bit_height/2.0, \
    "b1" b1_offset+bit_height/2.0, \
    "b2" b2_offset+bit_height/2.0, \
    "b3" b3_offset+bit_height/2.0, \
    "b4" b4_offset+bit_height/2.0, \
    "b5" b5_offset+bit_height/2.0, \
    "b6" b6_offset+bit_height/2.0, \
    "b7" b7_offset+bit_height/2.0 \
)

set grid xtics
unset key

plot "results/dac.txt" using ($1*1e9):(b7_offset+logic_level($4)) with steps linewidth 1.5 title "b7", \
     "results/dac.txt" using ($1*1e9):(b6_offset+logic_level($5)) with steps linewidth 1.5 title "b6", \
     "results/dac.txt" using ($1*1e9):(b5_offset+logic_level($6)) with steps linewidth 1.5 title "b5", \
     "results/dac.txt" using ($1*1e9):(b4_offset+logic_level($7)) with steps linewidth 1.5 title "b4", \
     "results/dac.txt" using ($1*1e9):(b3_offset+logic_level($8)) with steps linewidth 1.5 title "b3", \
     "results/dac.txt" using ($1*1e9):(b2_offset+logic_level($9)) with steps linewidth 1.5 title "b2", \
     "results/dac.txt" using ($1*1e9):(b1_offset+logic_level($10)) with steps linewidth 1.5 title "b1", \
     "results/dac.txt" using ($1*1e9):(b0_offset+logic_level($11)) with steps linewidth 1.5 title "b0"

# ============================================================
# Sampling clock
# ============================================================

set xlabel "Time (ns)"
set ylabel "Clock state"

set xrange [0:time_max]
set yrange [-0.15:1.15]

set xtics time_step
set ytics ("0" 0, "1" 1)

set grid xtics ytics
set key outside right center

plot "results/dac.txt" using ($1*1e9):3 with steps linewidth 1.5 title "CLK"



# ============================================================
# DAC analog output
# ============================================================

set title ""
set xlabel "Time (ns)"
set ylabel "Output (V)"

set xrange [0:time_max]
set yrange [0:1.02]

set xtics time_step
set ytics 0.1

set grid xtics ytics
set key outside right center

plot "results/dac.txt" using ($1*1e9):2 with lines linewidth 2 title "V(out)"

unset multiplot
unset output
