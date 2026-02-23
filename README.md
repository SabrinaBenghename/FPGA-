# 🔍 FPGA Sequence Detector with Overlap Detection & Audio Alert

## 📌 Overview

This project implements a configurable **Finite State Machine (FSM)** in VHDL on FPGA to detect a 3-bit binary sequence within an 8-bit input stream.

The system detects:
- All occurrences of a given sequence
- Overlapping patterns
- Total number of detections
- Positions of overlaps

It also provides:
- LED bargraph visualization
- 7-segment display output
- Audio feedback using a buzzer

---

## 🧠 Features

- Parameterized sequence detection using VHDL generics
- Sliding window detection across 8-bit input
- Overlap detection logic
- FSM-controlled buzzer and LED alert
- 7-segment display driver
- Hardware-friendly synchronous design

---

## ⚙️ Entity Description

### Entity: `fsm`

### Generics

| Generic | Type | Default | Description |
|----------|--------|----------|-------------|
| `CLKQ` | integer | 1 | Clock timing parameter for buzzer |
| `B` | real | 0.5 | Reserved parameter |
| `L` | real | 0.5 | Reserved parameter |
| `SEQUENCE` | std_logic_vector(2 downto 0) | "101" | 3-bit sequence to detect |

---

## 📥 Inputs

| Signal | Type | Description |
|--------|--------|-------------|
| `clk` | std_logic | System clock |
| `rst` | std_logic | Asynchronous reset |
| `data_in` | std_logic_vector(7 downto 0) | 8-bit input data |

---

## 📤 Outputs

| Signal | Type | Description |
|--------|--------|-------------|
| `LEDS` | std_logic_vector(5 downto 0) | Bargraph for total detections |
| `LEDS_POSI` | std_logic_vector(7 downto 0) | One-hot overlap positions |
| `SEG` | std_logic_vector(7 downto 0) | 7-segment display segments |
| `AN` | std_logic_vector(3 downto 0) | Active digit selector |
| `buzzer_out` | std_logic | Audio alert output |
| `LED_out` | std_logic | Visual alert output |

---

## 🔎 Detection Logic

The design slides a 3-bit window across the 8-bit input:

- Positions checked: 7→5, 6→4, 5→3, 4→2
- Stores starting positions of detected sequences
- Detects overlapping occurrences
- Counts:
  - Total detections
  - Number of overlaps

---

## 🔔 FSM Operation

The Finite State Machine has 4 states:

- `wai` → Idle state  
- `BEEP_ON` → Buzzer active  
- `BEEP_OFF` → Silent delay  
- `DONE` → Return to idle  

The buzzer and LED are activated when detections occur.

---

## 🔢 Display Behavior

- 6 LEDs → Total number of detections (bargraph style)
- 8 LEDs → Positions of overlapping detections
- 7-segment display → Number of overlaps (0–9 supported)

---

## 🛠 Requirements

- FPGA board (Xilinx or Intel compatible)
- VHDL synthesis tool (Vivado / Quartus)
- 7-segment display
- LEDs
- Buzzer module

---

## 🚀 Possible Improvements

- Support variable-length sequence (N-bit pattern)
- Improve overlap detection robustness
- Optimize FSM timing logic
- Add UART debugging output
- Add testbench for simulation

---

## 👩‍💻 Author

**Sabrina Benghename**  
Electronic & Embedded Systems Engineer  
FPGA & Digital Design Enthusiast  

---

## 📄 License

This project is open-source and available for educational and research purposes.
