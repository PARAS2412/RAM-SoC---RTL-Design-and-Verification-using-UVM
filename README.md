# RAM-SoC: RTL Design and Multi-Agent UVM Verification

> **A scalable 4096 × 64-bit banked RAM SoC designed in Verilog HDL and verified using reusable SystemVerilog and UVM verification environments.**

This project demonstrates the complete RTL design and functional verification flow of a **4096 × 64-bit RAM SoC** consisting of **four independent memory banks**, each verified using its own configurable **Read Agent**, **Write Agent**, and **Scoreboard**.

Unlike a traditional single-agent verification environment, this project implements a **multi-agent UVM architecture** coordinated through a **Virtual Sequencer** and **Virtual Sequences**, making the verification environment scalable and reusable for larger SoC designs.

---

# Project Highlights

- RTL Design of a **4096 × 64-bit Banked RAM SoC**
- Hierarchical Memory Architecture
- 4 Independent RAM Banks
- Configurable Multi-Agent UVM Environment
- Multiple Read Agents
- Multiple Write Agents
- Virtual Sequencer & Virtual Sequences
- Independent Scoreboards per Memory Bank
- TLM Analysis FIFOs
- Reference Model using Associative Array
- Layered SystemVerilog Verification Environment
- Constrained-Random Verification
- Functional Coverage
- Regression Support

---

# UVM Verification Architecture

<p align="center">
<img src="docs/architecture.png" width="850">
</p>

> **Note:** Replace `docs/architecture.png` with the path to your architecture image.

The verification environment consists of:

- **4 Write Agents**
- **4 Read Agents**
- **4 Independent Scoreboards**
- **1 Virtual Sequencer**
- **1 Virtual Sequence**

Each memory bank is verified independently while still being coordinated through the Virtual Sequencer, making the environment highly scalable.

---

# Architecture Overview

```
                    Virtual Sequence
                            │
                            ▼
                  Virtual Sequencer
                            │
      ┌────────────────────────────────────────┐
      │                                        │
      ▼                                        ▼

   Write Agents (4)                     Read Agents (4)

 wr_agt_top[0]                       rd_agt_top[0]
 wr_agt_top[1]                       rd_agt_top[1]
 wr_agt_top[2]                       rd_agt_top[2]
 wr_agt_top[3]                       rd_agt_top[3]

      │                                        │
      └──────────────────┬─────────────────────┘
                         ▼

               RAM SoC (4096 × 64)

        ┌────────┬────────┬────────┬
        ▼        ▼        ▼        ▼
      MEM0     MEM1     MEM2     MEM3

        ▲        ▲        ▲        ▲
        └────────┴────────┴────────┘

                 Scoreboards (4)
```

---

# Design Under Test

The DUT is implemented as a **4096 × 64-bit banked synchronous RAM**.

The memory is divided into **four 1024 × 64 memory banks**.

```
12-bit Address

[11:10] ---> Bank Select

[9:0] ---> Address inside selected bank
```

The upper address bits are decoded using a **2-to-4 decoder**, activating only one memory bank at a time.

---

# RTL Modules

| Module | Description |
|---------|-------------|
| ram_4096 | Top-level RAM controller |
| mem_dec | 2-to-4 decoder for bank selection |
| dual_mem | 1024 × 64 dual-port RAM bank |
| ram_soc | Instantiates four RAM banks |
| ram_chip | Wrapper around each RAM |
| ram_if | Interface containing clocking blocks and modports |

---

# Verification Environments

The repository contains **two independent verification environments** targeting the same RTL.

## 1. Layered SystemVerilog Verification

A custom verification environment built from scratch.

### Components

- Transaction
- Generator
- Driver
- Monitor
- Reference Model
- Scoreboard
- Environment
- Test Library

Features

- Directed Testing
- Constrained Random Verification
- Reference Model
- Functional Coverage

---

## 2. UVM Verification Environment

A reusable verification environment built using standard UVM methodology.

### Write Agent

- Driver
- Monitor
- Sequencer
- Sequences
- Configuration

### Read Agent

- Driver
- Monitor
- Sequencer
- Sequences
- Configuration

### Environment

- Virtual Sequencer
- Virtual Sequences
- Environment Configuration
- Factory Registration
- Analysis Ports
- TLM Analysis FIFOs
- Scoreboards

---

# Multi-Agent Verification Flow

Each RAM bank has an independent verification path.

```
Write Sequence
      │
      ▼
Write Agent
      │
      ▼
RAM Bank
      │
      ▼
Write Monitor
      │
      ▼
Scoreboard
```

Similarly,

```
Read Sequence
      │
      ▼
Read Agent
      │
      ▼
RAM Bank
      │
      ▼
Read Monitor
      │
      ▼
Scoreboard
```

The Virtual Sequencer coordinates all agents simultaneously, enabling synchronized verification across multiple RAM banks.

---

# Scoreboard Methodology

Each scoreboard maintains its own reference model using an associative array.

### Write Flow

```
Write Monitor
      │
      ▼
Analysis FIFO
      │
      ▼
Reference Memory Update
```

### Read Flow

```
Read Monitor
      │
      ▼
Analysis FIFO
      │
      ▼
Reference Memory Lookup
      │
      ▼
Expected Data
      │
      ▼
Compare
      │
      ▼
PASS / FAIL
```

Each scoreboard reports:

- Number of Write Transactions
- Number of Read Transactions
- Compared Transactions
- Dropped Transactions
- Data Mismatches

---

# Test Suite

| Test | Description |
|------|-------------|
| ram_single_addr_test | Single-address write/read verification |
| ram_ten_addr_test | Multiple-address verification |
| ram_even_addr_test | Even-address transactions |
| ram_odd_addr_test | Odd-address transactions |

---

# Repository Structure

```
RAM-SoC---RTL-Design-and-Verification-using-UVM/

├── SV_Verification/
│   ├── rtl/
│   ├── env/
│   ├── env_lib/
│   ├── test/
│   └── sim/
│
└── UVM_Verification/
    ├── rtl/
    ├── wr_agt_top/
    ├── rd_agt_top/
    ├── tb/
    ├── test/
    └── sim/
```

---

# Running the Project

### SystemVerilog

```bash
make sv_cmp
make TC1
make TC2
make TC3
make regress_123
```

### UVM

```bash
make sv_cmp

make run_test

make run_test1

make run_test2

make run_test3

make regress

make report

make cov
```

---

# Tools & Technologies

### RTL Design

- Verilog HDL

### Verification

- SystemVerilog
- UVM 1.2

### Concepts

- Layered Verification
- Multi-Agent UVM
- Virtual Sequencing
- Constrained Random Verification
- TLM Communication
- Scoreboard
- Reference Model
- Functional Coverage
- Regression Testing

### Simulators

- Mentor QuestaSim
- Synopsys VCS

---

# Key Learning Outcomes

- RTL Design of Banked Memory Architectures
- Multi-Agent UVM Verification
- Virtual Sequencer & Virtual Sequences
- Agent Configuration
- TLM Communication
- Scoreboard Development
- Reference Model Design
- Associative Array Modeling
- Functional Verification
- Regression Automation

---

# License

This project is intended for educational and learning purposes.
