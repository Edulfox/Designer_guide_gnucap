# models/

Comparator models extracted from `comp/` and split by abstraction level.
Everything here is **buildable and runnable with the installed
`gnucap` / `gnucap-mg-vams`**.

```
models/
├── README.md
├── verify.sh                 # builds, runs and checks both model sets
├── behavioral/               # Verilog-A, compiled with gnucap-mg-vams
│   ├── comp_std.vams         # StrongARM latch (time-domain decision)
│   ├── comp_reg.vams         # registered/latched comparator + gated clock
│   ├── comp_mix.vams         # digital clock + digitized rail outputs
│   ├── comp_reg_logic_ref.vams  # original digital-logic model
│   ├── clock_logic_ref.vams     # original digital-logic clock
│   ├── elect_to_logic.vams   # electrical-to-logic connectmodule
│   ├── logic_to_elect.vams   # logic-to-electrical connectmodule
│   ├── vpwl.vams             # piecewise-linear source
│   ├── vpulse.vams           # pulse source (local copy of Felix Salfelder's)
│   ├── comp_std_tb.gc
│   ├── comp_reg_tb.gc
│   ├── comp_mix_tb.gc
│   ├── comp_reg_logic_tb.gc
│   ├── build.sh
│   └── run.sh
└── device/                   # transistor level, IHP SG13G2 PDK
    ├── CMP7345.va            # CMP7345 / CMP7345_7T + diff_pair etc.
    ├── vpwl.vams             # npts/wave* piecewise source
    ├── CMP7345_tb.gc
    ├── build.sh              # rebuilds the PDK plugins + patched includes
    ├── run.sh
    └── pdk/                  # generated: patched includes and rebuilt .so
```

## Behavioral models

`comp_std` – conventional StrongARM latch. A numeric `decision` is
updated on the rising clock edge; both outputs are precharged high while
the clock is low and are driven by linear ramps (delay + transition) afterwards.

`comp_reg` – the registered-output idea of `comp/comp_reg`, rewritten in
analog style: an `integer state` (0 reset, +1, -1) is clocked with
`@(cross(...))` and both outputs reset high while the clock is low. It
also contains the gated `clock` module (enable `en`, 50 % duty cycle).

`comp_mix` – mixed-signal extension of the behavioral latch, following
the clocked/registered structure of `comp/comp_reg` (and of the
`mg_logic.1` ModelGen example) but implemented with discrete states so it
runs in plain gnucap:

* `mix_clock` generates the **digital clock** on-chip: a rail-to-rail
  0/1 square wave with a defined half period and edge times, gated by an
  enable input (it stops low when disabled).
* `comparator_mix` samples the input difference on each rising clock
  edge and stores it in a **digitized** state (+1 / 0 / -1).  The outputs
  are **digitalized**: they switch between the supply rails with fixed
  transition times, and both go high during the clock-low reset phase.

`comp_reg_logic_tb.gc` exercises `comp_reg_logic_ref.vams` using the
explicit Verilog-AMS `connectmodule` definitions from the
[IHP Gnucap example](https://ihp-open-pdk-docs.readthedocs.io/en/latest/analog/gnucap.html#compiling-a-verilog-a-model-to-be-used-in-a-simulation).
Both converters are built locally from `elect_to_logic.vams` and
`logic_to_elect.vams`:

```
   clk_drive (electrical) --[elect_to_logic]--> clk_logic
   clk_logic --[logic_to_elect]--> clk_a
   outp_logic --[logic_to_elect]--> outp_a
   outn_logic --[logic_to_elect]--> outn_a
```

`comp_mix` remains the self-contained mixed-signal variant with integer
state and analog rail outputs, so it does not need any connect modules.

`vpulse.vams` is a local copy of Felix Salfelder's pulse source (GPLv3+).
It replaces the installed `vams/vpulse.so` which is built against the
previous gnucap core and expects the legacy `logic_ground` symbol.

Build and run:

```sh
cd behavioral
./build.sh          # comp_std, comp_reg, comp_mix, logic refs, vpwl, vpulse
./run.sh            # *_tran.txt + *_tran.png for all four testbenches
```

Expected results (VDD 1.2 V, INN 0.6 V, INP ramps 0.45→0.75 V):

| model      | clk low      | inp < inn        | inp > inn        |
|------------|--------------|------------------|------------------|
| comp_std   | outp=outn=vdd| outp=0, outn=vdd | outp=vdd, outn=0 |
| comp_reg   | outp=outn=vdd| outp=0, outn=vdd | outp=vdd, outn=0 |
| comp_mix   | outp=outn=vdd| outp=0, outn=vdd | outp=vdd, outn=0 |

`comp_std` latches at ≈0.22 ns (first decision) and flips when the ramp
crosses 0.6 V; `comp_reg` behaves the same but only while the gated clock
is enabled (after 5 ns).  `comp_mix` runs from its own digital clock
(10 ns period, enabled at 5 ns) and digitizes the decision on every
rising edge.

The electrical clock starts at 6 ns with a 10 ns period, following the
documentation's pulse-source → connectmodule arrangement.
`elect_to_logic` uses explicit 0.85 V / 0.25 V thresholds.
`logic_to_elect` initializes its electrical output to 0 V and uses
`transition()` with 10 ps rise/fall times and 0/1.2 V rails.
The comparator resolves low then high as the input ramp crosses 0.6 V.
The reference self-oscillating `clock_logic_ref` is built but is not used
in this deck: its event handling did not work reliably with these
edge-driven converters in the installed runtime.

## Device model

`CMP7345.va` is the transistor-level SG13G2 comparator from
`comp/comparator-pdk`: a differential pair, cross-coupled NMOS/PMOS
regeneration pairs and a clock tail device, plus the alternative
`CMP7345_7T` variant.  The testbench instantiates it at top level, drives
`vinn` from 0.5 V to 0.7 V (0.6 V at 5 ns) and probes both inputs
(`v(vinp)`, `v(vinn)`) and both outputs (`v(vout1)`, `v(vout2)`).

The output load capacitors are explicit (`10 fF`).  The generic
`vams/capacitor` model defaults to **1 F**, which would freeze the
strong-arm precharge; without the explicit value the outputs never leave
0 V.

### PDK plugins and include files

The SG13G2 PDK plugins shipped with the PDK kit were built against an
older gnucap core and fail to load against the current one.  `build.sh`
therefore rebuilds them locally from the IHP-Open-PDK Verilog-A sources:

* `sg13g2_moslv_paramset.so`, `sg13g2_moslv_rf_paramset.so`,
  `resistor_paramset.so`, `capacitor_paramset.so`, `idc.so`
* the local `vpwl.so`

The PDK sources also use constructs the current `lang_verilog` rejects, so
`build.sh` writes patched copies into `pdk/` and puts that directory first
in `GNUCAP_INCLUDEPATH`:

* `localparam` → `parameter`
* backslash-newline continuations joined into one line
* `$rdist_normal(seed, mean, sigma, "scope")` → `(mean)` (nominal corner)

The PDK tree itself is not modified.  `build.sh` takes several minutes on
the first run (the RF parameter set is large); after that the `.so` files
are reused.

```sh
cd device
./build.sh          # rebuild the PDK plugins and patched includes (slow, once)
./run.sh            # 20 ns run, about one minute
```

`run.sh` prepends `device/pdk/` to `GNUCAP_INCLUDEPATH` and
`GNUCAP_PLUGPATH`, runs the deck and writes `CMP7345_tran.txt`,
`CMP7345_run.log` and `CMP7345_tran.png`.

Expected result: during each clock-low phase both outputs precharge to
1.2 V; on the decision phase one output goes low while the other stays
high.  Because `vinn` crosses 0.6 V at 5 ns, `vout1` is low after the
first decision and high after the second, so the plotted run shows both
polarities.

## Plotting

`plot.py` renders the `.txt` files with matplotlib.  Signals are grouped
automatically (inputs, clock/control, outputs) and, by default, the
groups are placed as **horizontal subplots** in a single row.  Both
comparator inputs (`v(inp)`, `v(inn)` — or `v(vinp)`, `v(vinn)` for the
device model) are recorded and drawn **together in one panel**, so the
input crossing that flips the decision is visible directly:

```sh
./plot.py behavioral/comp_std_tran.txt behavioral/comp_reg_tran.txt
./plot.py device/CMP7345_tran.txt --layout stacked   # horizontal strips, shared x
./plot.py device/CMP7345_tran.txt --out svg --show   # other formats / window
./plot.py behavioral/comp_std_tran.txt --groups      # show the panel grouping
```

`run.sh` in both directories calls the plotter automatically when
matplotlib is available, writing `<file>.png` next to the data.

## Verification

```sh
./verify.sh            # files + behavioral models + numeric checks + plots
./verify.sh --device   # additionally runs the slow device model
```
