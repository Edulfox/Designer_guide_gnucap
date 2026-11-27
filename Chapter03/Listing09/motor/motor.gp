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

# Plot the electrical and mechanical transient response of the motor.

set terminal pdfcairo enhanced size 8,8
set output "plots/motor.pdf"

set datafile commentschars "#"
set grid
set key top right
set xlabel "Time (s)"

set multiplot layout 3,1 title "Motor Transient Response"

# Supply voltage
set ylabel "Voltage (V)"
set yrange [0:1.1]
plot "results/motor.txt" using 1:2 with lines linewidth 2 title "Supply voltage"

# Shaft angular velocity
set ylabel "Angular velocity (rad/s)"
set yrange [0:*]
plot "results/motor.txt" using 1:3 with lines linewidth 2 title "Shaft velocity"

# Motor current
set ylabel "Current (mA)"
set yrange [*:*]
plot "results/motor.txt" using 1:(-$4*1000) with lines linewidth 2 title "Motor current"

unset multiplot
