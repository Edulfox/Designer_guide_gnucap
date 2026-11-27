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

# Plot the DC, AC, and thermal-noise validation of Listing 16.

set terminal pdfcairo enhanced font "Sans,12" size 10in,10in
set output "plots/port.pdf"

tran_file = "results/port_tran.txt"
ac_file = "results/port_ac_noise.txt"

r = 50.0
dc = 0.5
mag = 1.0
k = 1.380649e-23
temperature = 300.0

expected_dc = dc
expected_ac = mag
expected_noise = sqrt(k*temperature*r)*1e9

set grid
set multiplot layout 3,1 title "Listing 16 - Resistive Port Validation" font ",16"

set title "Matched-Load DC Response"
set xlabel "Time (ns)"
set ylabel "Voltage (V)"
set xrange [0:10]
set yrange [0:0.6]
unset logscale x
plot tran_file using ($1*1e9):2 with lines linewidth 2 title "V(out)", \
     expected_dc with lines dashtype 2 linewidth 1.5 title "Expected = 0.5 V"

set title "AC Response"
set xlabel "Frequency (Hz)"
set ylabel "|V(out)| (V)"
set logscale x
set xrange [1:1e9]
set yrange [0:1.2]
plot ac_file using 1:2 with linespoints linewidth 2 pointtype 7 title "AC output", \
     expected_ac with lines dashtype 2 linewidth 1.5 title "Expected = 1 V"

set title "Thermal Noise Density"
set xlabel "Frequency (Hz)"
set ylabel "Noise (nV/sqrt(Hz))"
set logscale x
set xrange [1:1e9]
set yrange [0:0.6]
plot ac_file using 1:($3*1e9) with linespoints linewidth 2 pointtype 7 title "Thermal noise", \
     expected_noise with lines dashtype 2 linewidth 1.5 title "Expected = 0.455 nV/sqrt(Hz)"

unset multiplot
unset output
