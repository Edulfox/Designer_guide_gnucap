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
set terminal pdfcairo enhanced font "Sans,12" size 10in,5in
set output "plots/smpl_ckt.pdf"
set grid
set xlabel "Time (ns)"
set ylabel "Node voltage (V)"
plot "results/smpl_ckt.txt" using ($1*1e9):2 with lines linewidth 2 title "V(n)"
