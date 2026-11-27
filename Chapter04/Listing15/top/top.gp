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
set terminal pdfcairo enhanced font "Sans,13" size 10in,5in
set output "plots/top.pdf"
set grid
set title "Chapter 4 Listing 15 - Explicit Gnucap Interface Equivalent"
set xlabel "Time (us)"
set ylabel "Analog interface voltage (V)"
plot "results/top.txt" using ($1*1e6):2 with steps lw 2 title "Clock after explicit D2A"
unset output
