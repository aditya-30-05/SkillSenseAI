"""
SkillSense AI — Real-time Drone Telemetry Simulation Engine
Provides physics-based waypoints, sensor drift, atmospheric telemetry,
and real-time hazard threshold evaluation.
"""

import time
import math
import random
from typing import Dict, Any, List

class DroneSimulationEngine:
    def __init__(self, drone_id: str = "DRONE-01"):
        self.drone_id = drone_id
        self.waypoints = [
            {"lat": 18.5204, "lng": 73.8567, "zone": "Base Station", "alt": 0.0},
            {"lat": 18.5210, "lng": 73.8572, "zone": "Zone A: Pipe Gallery", "alt": 3.5},
            {"lat": 18.5218, "lng": 73.8580, "zone": "Zone B: Gas Storage", "alt": 4.8},
            {"lat": 18.5225, "lng": 73.8588, "zone": "Zone C: Welding Bay", "alt": 3.2},
            {"lat": 18.5215, "lng": 73.8575, "zone": "Zone D: Maintenance Depot", "alt": 2.8},
        ]
        self.waypoint_index = 0
        self.battery = 88.0
        self.gas_ppm = 12.0
        self.temperature = 26.5
        self.humidity = 58.0
        self.active_hazard = None
        self.is_aborted = False

    def tick(self) -> Dict[str, Any]:
        """Generates a 1-second simulation tick."""
        if self.is_aborted:
            return {"status": "ABORTED", "battery": self.battery}

        # Battery drain
        self.battery = max(0.0, self.battery - 0.04)

        # Move along waypoints
        target_wp = self.waypoints[self.waypoint_index]

        # Natural sensor drift
        ppm_drift = random.uniform(-0.8, 1.2)
        if self.active_hazard:
            self.gas_ppm = min(self.active_hazard["target_ppm"], self.gas_ppm + random.uniform(8.0, 18.0))
        else:
            self.gas_ppm = max(5.0, min(35.0, self.gas_ppm + ppm_drift))

        self.temperature += random.uniform(-0.1, 0.15)
        self.humidity += random.uniform(-0.2, 0.2)

        return {
            "timestamp": time.time(),
            "drone_id": self.drone_id,
            "zone": target_wp["zone"],
            "latitude": target_wp["lat"] + random.uniform(-0.00005, 0.00005),
            "longitude": target_wp["lng"] + random.uniform(-0.00005, 0.00005),
            "altitude_meters": target_wp["alt"] + random.uniform(-0.1, 0.1),
            "ground_speed_mps": 1.2 if target_wp["alt"] > 0 else 0.0,
            "battery_percent": int(self.battery),
            "gas_ppm": round(self.gas_ppm, 2),
            "temperature_celsius": round(self.temperature, 1),
            "humidity_percent": round(self.humidity, 1),
            "hazard_active": self.active_hazard is not None
        }

    def inject_hazard(self, hazard_type: str, target_ppm: float, zone: str):
        self.active_hazard = {
            "type": hazard_type,
            "target_ppm": target_ppm,
            "zone": zone,
            "injected_at": time.time()
        }

    def clear_hazard(self):
        self.active_hazard = None

    def trigger_abort(self):
        self.is_aborted = True
