# SkillSense AI — Backend & Simulation Module

This directory organizes backend services, simulation engines, and API interfaces for SkillSense AI.

## Directory Structure

```
backend/
├── api/
│   └── api_spec.json               # OpenAPI 3.1 REST & WebSocket endpoint definitions
├── simulation/
│   └── simulation_engine.py        # Real-time drone physics, waypoint navigation, and gas sensor drift
├── services/                       # Microservices for telemetry ingest, AI evaluations, and alerts
└── README.md                       # This file
```

## Features

1. **Telemetry Streaming:** Emits GPS, altitude, ground speed, battery, and atmospheric sensor updates at 1Hz frequency.
2. **Hazard Injection Engine:** Dynamic scenario trigger for methane spikes, toxic H2S leaks, and asphyxiant gases.
3. **Emergency Controls:** Mission abort protocols and Return-to-Home (RTH) overrides.
