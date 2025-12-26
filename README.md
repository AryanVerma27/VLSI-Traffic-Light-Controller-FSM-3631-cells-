# Traffic Light Controller using Finite State Machine (VLSI Design)

## Project Overview
This project implements a **Finite State Machine (FSM)** based Traffic Light Controller using Verilog HDL. The design manages a four-way intersection, alternating traffic flow between North-South (NS) and East-West (EW) directions. It ensures safety by preventing simultaneous green lights and includes timing features for Green and Yellow phases.

The project was developed as part of **EECT/CE 6325 - VLSI Design** at the **University of Texas at Dallas**.

### Key Features
* **FSM Implementation:** 4-state architecture (NS Green, NS Yellow, EW Green, EW Yellow).
* **Parameterized Timing:** Adjustable `GREEN_TIME` (default 3631 cycles) and `YELLOW_TIME` (default 500 cycles).
* **PWM Integration:** Includes a Pulse-Width Modulation module for controlling light intensity.
* **Scalability:** A `big_system` module demonstrates scalability by instantiating multiple independent controllers.
* **Safety Interlocks:** Combinational logic ensures no perpendicular green lights are active simultaneously.

## Directory Structure
* `src/`: Contains Verilog source files (`traffic_light_controller.v`, `pwm.v`, `ctl_with_pwm.v`).
* `tb/`: Contains the testbench (`traffic_light_controller_tb.v`).
* `docs/`: Schematic diagrams and verification logs.

## Design Modules
1.  **traffic_light_controller:** The core FSM with state registers and output logic.
2.  **pwm:** Generates PWM signals based on duty cycle inputs.
3.  **ctl_with_pwm:** Wraps the controller and PWM modules for full functionality.
4.  **big_system:** Top-level module for instantiating $N$ number of controllers.

## Simulation
The testbench `traffic_light_controller_tb.v` simulates the system with a 100 MHz clock. It includes:
* Automated reset sequencing.
* Heartbeat monitoring every 500 cycles.
* **Safety Check:** Automatically stops simulation if both NS and EW are Green simultaneously.

## Verification & Layout
The project includes analysis on:
* **Schematic Entry:** Logical representation of the controller.
* **Layout:** Physical design implementation.
* **DRC & LVS:** Design Rule Checks and Layout Versus Schematic checks (Note: Documentation highlights trade-offs and challenges in physical verification).

## Authors
* **Aryan Verma**
* **Instructor:** Prof. Carl Sechen

