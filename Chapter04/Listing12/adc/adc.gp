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
# 8-bit ADC functional verification.
#
# Panels:
#   1. Analog input and reconstructed ADC value.
#   2. Decimal ADC output code.
#   3. Individual output bits B7 ... B0.
#   4. Sampling clock.
#
# The reconstructed voltage is obtained from:
#
#   Vadc = Code / 256
#
# for a nominal full-scale voltage of 1 V.

reset

data_file = "results/adc.txt"
output_file = "plots/adc.pdf"

set terminal pdfcairo enhanced color size 12in,11in font "Arial,11"
set output output_file

set datafile commentschars "#"

# ============================================================
# Automatic simulation time range
# ============================================================

stats data_file using 1 nooutput

time_max = STATS_max * 1e9
time_step = time_max / 5.0

# ============================================================
# Digital conversion helpers
# ============================================================

bit(x) = (x > 0.5 ? 1 : 0)

code(b7,b6,b5,b4,b3,b2,b1,b0) = \
    128*bit(b7) + \
     64*bit(b6) + \
     32*bit(b5) + \
     16*bit(b4) + \
      8*bit(b3) + \
      4*bit(b2) + \
      2*bit(b1) + \
          bit(b0)

# Reconstructed ADC voltage for 1 V full scale.
adc_voltage(b7,b6,b5,b4,b3,b2,b1,b0) = \
    code(b7,b6,b5,b4,b3,b2,b1,b0) / 256.0

# ============================================================
# Common plot geometry
# ============================================================

set lmargin 11
set rmargin 8

set xrange [0:time_max]
set xtics time_step

set grid xtics ytics
set key top right

set multiplot layout 4,1 title "8-bit ADC - Functional Verification" font ",14"

# ============================================================
# Analog input and reconstructed ADC value
# ============================================================

set title "Analog input and reconstructed ADC output"
set ylabel "Voltage (V)"
set xlabel "Time (ns)"

set yrange [0:1.05]
set ytics 0.2

plot data_file using ($1*1e9):2 with lines linewidth 1.7 title "V(in)", \
     data_file using ($1*1e9):(adc_voltage($4,$5,$6,$7,$8,$9,$10,$11)) with steps linewidth 1.6 title "ADC reconstructed"

# ============================================================
# Decimal ADC code
# ============================================================

set title "ADC output code"
set ylabel "Code"
set xlabel "Time (ns)"

set yrange [-5:260]
set ytics 32
unset key

plot data_file using ($1*1e9):(code($4,$5,$6,$7,$8,$9,$10,$11)) with steps linewidth 1.7

# ============================================================
# Individual digital output bits
# ============================================================

set title "ADC output bits"
set ylabel "Digital outputs"
set xlabel "Time (ns)"

bit_height = 0.80
lane_step = 1.10

b0_offset = 0.0
b1_offset = 1.0*lane_step
b2_offset = 2.0*lane_step
b3_offset = 3.0*lane_step
b4_offset = 4.0*lane_step
b5_offset = 5.0*lane_step
b6_offset = 6.0*lane_step
b7_offset = 7.0*lane_step

logic_level(x) = (x > 0.5 ? bit_height : 0.0)

set yrange [-0.25:b7_offset+1.05]

set ytics ( \
    "B0" b0_offset+bit_height/2.0, \
    "B1" b1_offset+bit_height/2.0, \
    "B2" b2_offset+bit_height/2.0, \
    "B3" b3_offset+bit_height/2.0, \
    "B4" b4_offset+bit_height/2.0, \
    "B5" b5_offset+bit_height/2.0, \
    "B6" b6_offset+bit_height/2.0, \
    "B7" b7_offset+bit_height/2.0 \
)

unset key

plot data_file using ($1*1e9):(b7_offset+logic_level($4)) with steps linewidth 1.4, \
     data_file using ($1*1e9):(b6_offset+logic_level($5)) with steps linewidth 1.4, \
     data_file using ($1*1e9):(b5_offset+logic_level($6)) with steps linewidth 1.4, \
     data_file using ($1*1e9):(b4_offset+logic_level($7)) with steps linewidth 1.4, \
     data_file using ($1*1e9):(b3_offset+logic_level($8)) with steps linewidth 1.4, \
     data_file using ($1*1e9):(b2_offset+logic_level($9)) with steps linewidth 1.4, \
     data_file using ($1*1e9):(b1_offset+logic_level($10)) with steps linewidth 1.4, \
     data_file using ($1*1e9):(b0_offset+logic_level($11)) with steps linewidth 1.4

# ============================================================
# Sampling clock
# ============================================================

set title "ADC sampling clock"
set ylabel "CLK"
set xlabel "Time (ns)"

set yrange [-0.15:1.15]
set ytics ("LOW" 0, "HIGH" 1)

unset key

plot data_file using ($1*1e9):3 with steps linewidth 1.7

unset multiplot
unset output
