#!/bin/sh
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
prepare_directories() {
    SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
    REPO_ROOT="$SCRIPT_DIR"
    while [ ! -f "$REPO_ROOT/Makefile" ] && [ "$REPO_ROOT" != "/" ]; do
        REPO_ROOT=$(dirname "$REPO_ROOT")
    done
    mkdir -p "$SCRIPT_DIR/results" "$SCRIPT_DIR/plots"
    if [ -f "$REPO_ROOT/Makefile" ]; then
        mkdir -p "$REPO_ROOT/logs/root/build" "$REPO_ROOT/logs/root/test" "$REPO_ROOT/logs/root/plot"
    fi
    cd "$SCRIPT_DIR"
}
prepare_directories
set -e
gnucap series_rlc_tb.gc
if command -v gnuplot >/dev/null 2>&1; then gnuplot series_rlc.gp; fi
