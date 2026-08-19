# Asynchronous FIFO with Clock Domain Crossing (CDC)

A Verilog HDL implementation of an **Asynchronous FIFO (First-In First-Out) Buffer** designed for reliable data transfer between two independent clock domains. The design demonstrates key concepts such as **Clock Domain Crossing (CDC)**, **Metastability Mitigation**, **Pointer Synchronization**, and **FIFO Control Logic** commonly used in FPGA and ASIC designs.

---

## Overview

Modern digital systems often contain multiple clock domains operating at different frequencies. Direct communication between such domains can lead to metastability and unreliable behavior.

This project implements an **Asynchronous FIFO** that safely transfers data between:

- Write Clock Domain (`wr_clk`)
- Read Clock Domain (`rd_clk`)

The FIFO acts as an intermediate buffer, allowing independent read and write operations while maintaining data integrity.

---

## Key Concepts Demonstrated

- Clock Domain Crossing (CDC)
- Metastability Mitigation
- Two-Stage Synchronizers
- FIFO Buffer Design
- Independent Read and Write Clocks
- Pointer Synchronization
- Full and Empty Flag Generation
- Verilog RTL Design
- Functional Verification

---

## Design Architecture

```text
                    Write Clock Domain
                 ┌────────────────────┐
                 │    Write Logic     │
                 │     wr_clk         │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │     FIFO Memory    │
                 │      8 x 8-bit     │
                 └────────────────────┘
                           ▲
                           │
                 ┌─────────┴──────────┐
                 │     Read Logic     │
                 │      rd_clk        │
                 └────────────────────┘

          ┌──────────────────────────────┐
          │ Pointer Synchronization      │
          │ (CDC Synchronizers)          │
          └──────────────────────────────┘
```

---

## Features

- Dual-clock FIFO architecture
- Independent read and write operations
- Synchronizer-based pointer transfer
- FIFO full detection
- FIFO empty detection
- Parameterized FIFO depth
- Functional verification using Vivado
- Modular RTL implementation

---

## Module Description

### Synchronizer

A two-stage synchronizer is used to transfer pointer information safely across clock domains.

```text
Write Pointer ──► Synchronizer ──► Read Domain
Read Pointer  ──► Synchronizer ──► Write Domain
```

Purpose:

- Reduces metastability risk
- Improves reliability of clock domain crossing

---

### FIFO Memory

Stores incoming data from the write domain until it is requested by the read domain.

Current Configuration:

| Parameter | Value |
|------------|---------|
| Data Width | 8 bits |
| FIFO Depth | 8 Entries |

---

### Write Controller

Functions:

- Accepts incoming data
- Writes data into FIFO memory
- Updates write pointer
- Checks FIFO full condition

---

### Read Controller

Functions:

- Reads data from FIFO memory
- Updates read pointer
- Checks FIFO empty condition

---

## Signal Description

| Signal | Description |
|----------|-------------|
| wr_clk | Write Clock |
| rd_clk | Read Clock |
| rst | Asynchronous Reset |
| data_in | Input Data |
| data_out | Output Data |
| wr_en | Write Enable |
| rd_en | Read Enable |
| fifo_full | FIFO Full Flag |
| fifo_empty | FIFO Empty Flag |

---

## Project Structure

```text
asynchronous_fifo/
│
├── rtl/
│   ├── synchroniser.v
│   └── asynchronous_fifo.v
│
├── tb/
│   └── tb_asynchronous_fifo.v
│
├── screenshots/
│
├── README.md
```

---

## Verification

The design was verified using a dedicated Verilog testbench in Vivado.

### Test Cases Performed

- FIFO Reset Verification
- Multiple Write Operations
- Multiple Read Operations
- Different Read and Write Clock Frequencies
- FIFO Full Condition
- FIFO Empty Condition
- Continuous Data Transfer

### Example Data Sequence

```text
Write Data:
A5
5A
3C
7F
FF
01
A0
B0

Read Data:
A5
5A
3C
7F
FF
01
A0
B0
```

---

## Simulation Environment

| Parameter | Value |
|------------|---------|
| Tool | Xilinx Vivado 2017.4 |
| Simulator | XSim |
| Write Clock Period | 10 ns |
| Read Clock Period | 14 ns |

---

## Learning Outcomes

Through this project, the following concepts were explored:

- Clock Domain Crossing (CDC)
- Metastability and Synchronization
- FIFO Design Methodology
- Pointer Management
- Full and Empty Detection Logic
- Verilog RTL Coding
- Functional Verification and Debugging
- FPGA-Oriented Digital Design

---

## Future Improvements

- Dual-Port RAM Based FIFO
- Almost Full / Almost Empty Flags
- Parameterized Data Width
- FPGA Implementation and Timing Analysis
- AXI-Stream FIFO Interface
- Formal Verification

---

## Tools Used

- Verilog HDL
- Xilinx Vivado 2017.4
- XSim Simulator
- FPGA Design Flow

---

## Author

**Chirayu Suneja**  
B.Tech Electronics & Communication Engineering  
Indian Institute of Information Technology, Allahabad (IIIT-A)

GitHub: https://github.com/chirayusuneja7-maker
