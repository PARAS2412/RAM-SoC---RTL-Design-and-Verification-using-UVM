# RAM-SoC — RTL Design and Verification using UVM

Design and functional verification of a **4096 × 64-bit dual-port RAM SoC**, verified with **two independent testbenches**:

1. **SystemVerilog (class-based) verification environment** — a from-scratch layered TB.
2. **UVM verification environment** — a reusable, configurable, agent-based UVM TB.

Both environments target the same synthesizable RTL and check writes against reads using a scoreboard / reference model.

---

## Repository layout

```
RAM-SoC---RTL-Design-and-Verification-using-UVM/
├── SV_Verification/          # Class-based SystemVerilog testbench
│   ├── rtl/                  # DUT (ram_4096, mem_dec, dual_mem)
│   ├── env/                  # ram_env (top-level environment)
│   ├── env_lib/             # gen, drivers, monitors, scoreboard, model, if, trans
│   ├── test/                # top.sv, test.sv, ram_pkg.sv
│   └── sim/                 # Makefile (Questa / VCS)
│
└── UVM_Verification/         # UVM testbench (RAM-SoC, 4 memory banks)
    ├── rtl/                  # DUT + SoC wrapper + interface
    ├── wr_agt_top/          # Write agent (driver, monitor, sequencer, seqs, xtn, cfg)
    ├── rd_agt_top/          # Read agent  (driver, monitor, sequencer, seqs, xtn, cfg)
    ├── tb/                  # env, scoreboard, virtual sequencer/seqs, top, configs
    ├── test/                # test package + test library (base + 4 tests)
    └── sim/                 # Makefile (Questa / VCS)
```

---

## Design Under Test (DUT)

A 4096-deep, 64-bit-wide RAM built hierarchically:

| Module      | Role |
|-------------|------|
| `ram_4096`  | Top RAM. 12-bit address (`ADDR_SIZE=12`), 64-bit data (`RAM_WIDTH=64`). Decodes the 2 MSB address bits to select one of 4 banks. |
| `mem_dec`   | 2→4 address decoder that produces the per-bank enable (one-hot). |
| `dual_mem`  | 1024 × 64 dual-port memory bank. Independent read/write addresses, tri-state `data_out` (`64'bz`) when not selected. |

**RAM-SoC wrapper (UVM env):**

| Module     | Role |
|------------|------|
| `ram_soc`  | Instantiates 4 `ram_chip` banks (`MB1..MB4`), each driven by its own interface. |
| `ram_chip` | Wraps one `ram_4096` and binds it to a `ram_if` interface via the `DUV_MP` modport. |
| `ram_if`   | Interface with clocking blocks & modports for write/read driver and monitor (`wdr_cb`, `rdr_cb`, `wmon_cb`, `rmon_cb`). |

Key behavior:
- **Writes** are registered on `posedge clk` when the bank is enabled and `write` is asserted.
- **Reads** drive `data_out` on `posedge clk` when enabled and `read` is asserted; otherwise the bank tri-states its output.
- Separate read/write address buses allow concurrent read and write.

---

## SV Verification Environment (`SV_Verification/`)

A classic layered class-based testbench:

- `ram_trans` — transaction (randomized address / data with constraints).
- `ram_gen` — generator/stimulus.
- `ram_write_drv` / `ram_read_drv` — drivers (drive the interface via modports).
- `ram_write_mon` / `ram_read_mon` — monitors (sample the interface).
- `ram_model` — reference model of the RAM.
- `ram_sb` — scoreboard comparing DUT reads vs. the reference model.
- `ram_env` — connects all components.
- `test.sv` — base test + extended test with directed/constrained-random constraints.
- `top.sv` — instantiates DUT + interface, generates clock, and launches tests via `+TEST1` / `+TEST2` plusargs.

### Run (from `SV_Verification/sim/`)

The Makefile supports **Questa** and **VCS** (set `SIMULATOR = Questa` or `VCS`):

```bash
make sv_cmp       # compile
make TC1          # run test case 1
make TC2          # run test case 2
make TC3          # run test case 3
make regress_123  # clean, compile & run TC1..TC3 + merge coverage
make covhtml      # open merged coverage report (HTML)
make clean
```

---

## UVM Verification Environment (`UVM_Verification/`)

A reusable UVM TB built around configurable **write** and **read** agents replicated across the 4 RAM banks.

**Components**
- **Write agent** (`wr_agt_top/`): `write_xtn`, `ram_wr_driver`, `ram_wr_monitor`, `ram_wr_sequencer`, `ram_wr_seqs`, `ram_wr_agent(_config)`.
- **Read agent** (`rd_agt_top/`): `read_xtn`, `ram_rd_driver`, `ram_rd_monitor`, `ram_rd_sequencer`, `ram_rd_seqs`, `ram_rd_agent(_config)`.
- **Environment** (`tb/`): `ram_tb` (env) builds dynamic arrays of agents per DUT, `ram_scoreboard` (TLM analysis FIFOs compare writes vs. reads), `ram_virtual_sequencer` + `ram_virtual_seqs` to coordinate stimulus across banks, `ram_env_config` / agent configs for knobs (`has_wagent`, `has_ragent`, `has_scoreboard`, `no_of_duts`, …).
- **Top** (`tb/top.sv`): generates clock, instantiates 4 `ram_if` + `ram_soc`, publishes virtual interfaces (`vif_0..vif_3`) through `uvm_config_db`, and calls `run_test()`.

**Tests** (`test/ram_vtest_lib.sv`)

| Test | Description |
|------|-------------|
| `ram_base_test`        | Base test (env config + common setup). |
| `ram_single_addr_test` | Write/read a single address. |
| `ram_ten_addr_test`    | Ten-address traffic. |
| `ram_odd_addr_test`    | Odd-address traffic. |
| `ram_even_addr_test`   | Even-address traffic. |

### Run (from `UVM_Verification/sim/`)

Set `SIMULATOR = Questa` (or `VCS`), then:

```bash
make sv_cmp       # create lib & compile
make run_test     # ram_single_addr_test
make run_test1    # ram_ten_addr_test
make run_test2    # ram_odd_addr_test
make run_test3    # ram_even_addr_test
make regress      # clean, compile & run all tests
make report       # merge coverage & convert to HTML
make cov          # open merged coverage report
make view_wave1   # view waveform (per test: view_wave1..4)
make clean
```

Tests are selected via `+UVM_TESTNAME=<test>` inside the Makefile targets.

---

## Requirements

- A SystemVerilog/UVM-capable simulator: **Mentor Questa** or **Synopsys VCS**.
- **UVM library** (for `UVM_Verification/` — uses `uvm_pkg` and `uvm_macros.svh`).
- GNU Make.
- (Optional) Verdi/FSDB for waveform dumping — the tops guard `$fsdbDumpvars` under `` `ifdef VCS ``.

---

## Notes

This project was developed as part of RTL design & verification lab work (RAM-SoC, Lab 10). The two testbenches demonstrate the same DUT verified with a hand-built SystemVerilog environment and with a methodology-driven UVM environment.
