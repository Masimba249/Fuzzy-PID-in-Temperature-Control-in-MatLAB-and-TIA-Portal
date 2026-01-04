# Automated Climate Control System for Grain Storage Facility

## Project Overview

This repository contains the documentation, design files, simulation models, and related materials for the **Development of an Automated Climate Control System for a Grain Storage Facility Based on the Smart City Concept**, a final-year project completed at Kazakh-British Technical University (Almaty, 2025).

The project proposes a fully automated HVAC (Heating, Ventilation, and Air Conditioning) system for grain silos to maintain optimal storage conditions (temperature 15–20 °C, relative humidity 60–65 %) and minimize post-harvest grain losses (< 1 % over 12–24 months). The solution integrates modern industrial automation with smart city principles, achieving 20–30 % energy savings through intelligent control and demand-responsive operation.

### Key Objectives
- Prevent mold, insect infestation, and spoilage by precise control of temperature and humidity.
- Reduce human intervention and operational costs.
- Align with smart city goals: energy efficiency, IoT integration, real-time monitoring, and city-level food security analytics.

## System Architecture

### Main Components
- **Control Object**: Shell-and-tube heat exchanger (primary actuator for cooling/dehumidification and reheating).
- **Additional Actuators**: Air conditioning unit, ultrasonic humidifier, aeration fans.
- **Sensors**: Distributed temperature cables (SITRANS TS500/TH420), humidity sensors, flow/pressure transmitters.
- **Controller**: Siemens SIMATIC S7-1200 PLC with fuzzy-enhanced PID control.
- **Supervisory Layer**: SCADA/HMI via WinCC Unified.
- **Communication**: PROFINET (primary), Modbus TCP (legacy), PROFIsafe (safety).
- **Remote Monitoring**: SIMATIC RTU3030C for GSM-based alarms during power outages.
- **Safety**: SIRIUS 3SK1121 safety relay.

### Control Strategy
- **Mathematical Model**: First-order linear model of grain thermal dynamics (time constant ≈ 8.6 days / 206 hours).
- **Controller**: Hybrid Fuzzy-PID (Sugeno inference) with dynamic gain scheduling.
  - Outperforms classical Ziegler-Nichols PID by eliminating overshoot and handling nonlinear silo dynamics.
  - 49-rule base with linguistic variables (e.g., "if temperature moderately high AND humidity critically elevated → increase ventilation").
- **Seasonal Strategy**: Stepped temperature reduction (e.g., 22 °C → 20.8 °C → 20.2 °C) using cooler ambient air when available.

### Smart City Integration
- Smart grid power management with off-peak scheduling and renewable (solar) support.
- Integration with municipal IoT infrastructure for aggregated food storage resilience metrics.
- Multi-channel alarm escalation (visual, auditory, GSM, city emergency dashboard).

## Repository Contents

- **`Automation of Storage Facility Environment Control.docx`**  
  Full project report (introduction, technological description, mathematical modeling, controller design, hardware selection, PLC programming, conclusions, and appendices).

- **Appendices (referenced in the report)**  
  - A: MATLAB transfer function model  
  - B: Step response analysis  
  - C: Impulse response  
  - D: Nyquist plot  
  - E: Bode plot  
  - F: Fuzzy-PID simulation results  
  - G: Fuzzy membership functions  
  - H: Professional P&ID diagram  
  - I: Heat exchanger details  
  - J: Electrical wiring diagram  

- **(Future additions – not included in current upload)**  
  - TIA Portal V19 project files (.ap19)  
  - MATLAB/Simulink models (.slx)  
  - PLC program exports (ladder, SCL)  
  - HMI/SCADA screen exports  

## Key Results

- Grain loss rate: < 1 % over extended storage.
- Energy savings: 20–30 % vs. traditional HVAC.
- Stability: Unconditionally stable first-order system (infinite gain/phase margins).
- Controller performance: Zero steady-state error, no overshoot, robust disturbance rejection.

## Technologies Used

- **Hardware**: Siemens SIMATIC S7-1200, ET 200SP, SINAMICS G120, SITRANS sensors, SIRIUS safety relays, RTU3030C.
- **Software**: Siemens TIA Portal V19 (STEP 7, WinCC Unified, Startdrive), MATLAB/Simulink (modeling & fuzzy design), PLCSIM Advanced (virtual commissioning).
- **Protocols**: PROFINET, PROFIsafe, Modbus TCP.

## Conclusion

This project delivers a scalable, intelligent, and sustainable solution for modern grain storage, reducing food loss, operational costs, and environmental impact while contributing to urban food security within a smart city framework.

## License

This project is for academic and educational purposes. All rights reserved © 2025 Kazakh-British Technical University.

For inquiries or collaboration, refer to the original author(s) listed in the full report.