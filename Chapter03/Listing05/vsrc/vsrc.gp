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
set output "plots/vsrc.pdf"
datafile="results/vsrc.txt"
stats datafile using 1 nooutput
time_max=STATS_max*1e9
set title "Listing 5 - Constant Voltage Source" font ",17"
set xlabel "Time (ns)"
set ylabel "Voltage (V)"
set xrange [0:time_max]
set yrange [0:1.4]
set grid
unset key
plot datafile using ($1*1e9):2 with lines linewidth 2.2
unset output
