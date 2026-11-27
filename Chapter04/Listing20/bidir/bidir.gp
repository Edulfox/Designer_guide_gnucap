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
set terminal pdfcairo noenhanced font "Sans,13" size 12in,7in
set output "plots/bidir.pdf"
set xrange [0:1]
set yrange [0:1]
unset border
unset xtics
unset ytics
unset key
set title "Chapter 4 Listing 20 - Driver Access Connectmodule" font ",18"
set object 1 rect from graph 0.08,0.14 to graph 0.92,0.82 front fillcolor rgb "white" fillstyle solid 1.0 border linewidth 1.2
set label 1 "No simulation data is available for this listing in the supplied repository snapshot." at graph 0.12,0.74 front
set label 2 "Status: BLOCKED / REFERENCE" at graph 0.12,0.64 front font ",14"
set label 3 "Current blockers:" at graph 0.12,0.53 front
set label 4 "- connectmodule code generation" at graph 0.16,0.46 front
set label 5 "- $driver_count and $driver_state" at graph 0.16,0.40 front
set label 6 "- driver_update" at graph 0.16,0.34 front
set label 7 "- full X/Z resolution" at graph 0.16,0.28 front
set label 8 "This page documents the unsupported reference case without inventing simulation data." at graph 0.12,0.19 front
plot NaN notitle
unset output
