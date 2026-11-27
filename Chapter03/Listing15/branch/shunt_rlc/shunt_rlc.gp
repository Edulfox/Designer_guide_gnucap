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
set terminal pdfcairo enhanced font "Sans,12" size 10in,6in
set output "plots/shunt_rlc.pdf"
set grid
set key outside top center horizontal
set xlabel "Time (ns)"
set ylabel "Voltage (V)"
plot "results/shunt_rlc.txt" using ($1*1e9):2 with lines linewidth 2 title "signal 1", \
     "results/shunt_rlc.txt" using ($1*1e9):3 with lines linewidth 2 title "signal 2"
