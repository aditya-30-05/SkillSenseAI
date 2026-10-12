# SkillSense AI — Database Architecture & Entity Relationship Diagram

This document models the relational entities, keys, and foreign relationships powering the **SkillSense AI** platform.

```mermaid
erDiagram
    TRAINEES ||--o{ TRAINING_SESSIONS : attends
    TRAINEES ||--o{ ASSESSMENTS : earns
    DRONES ||--o{ TRAINING_SESSIONS : assigned_to
    DRONES ||--o{ TELEMETRY_LOGS : emits
    TRAINING_SESSIONS ||--o{ SESSION_TIMELINE_EVENTS : contains
    TRAINING_SESSIONS ||--o{ TELEMETRY_LOGS : records
    TRAINING_SESSIONS ||--o| ASSESSMENTS : evaluates
    HAZARDS ||--o{ TELEMETRY_LOGS : triggers

    TRAINEES {
        varchar id PK
        varchar name
        varchar trade
        varchar skill_level
        varchar status
        numeric accuracy_percent
        numeric avg_response_time_sec
        integer false_alarms
        integer hazards_identified
        numeric skill_progress
    }

    DRONES {
        varchar id PK
        varchar callsign
        varchar model
        varchar status
        integer battery_level
        jsonb sensors_enabled
    }

    HAZARDS {
        varchar id PK
        varchar name
        varchar gas_type
        varchar zone
        varchar severity
        numeric threshold_ppm
    }

    TRAINING_SESSIONS {
        varchar id PK
        varchar trainee_id FK
        varchar drone_id FK
        varchar exercise_type
        varchar status
        numeric score
        integer duration_seconds
        numeric reaction_time_sec
    }

    TELEMETRY_LOGS {
        bigserial id PK
        varchar session_id FK
        varchar drone_id FK
        numeric altitude_meters
        numeric ground_speed_mps
        integer battery_percent
        numeric gas_ppm
        numeric temp_celsius
        numeric humidity_percent
        varchar active_hazard_id FK
    }

    ASSESSMENTS {
        varchar id PK
        varchar session_id FK
        varchar trainee_id FK
        numeric composite_score
        varchar grade
        boolean is_certified
    }
```

## Entity Dictionary

1. **`trainees`**: Profiles, trade specialization (Gas Fitting, Plumbing, Welding, Electrical), historical accuracy metrics, and progressive skill mastery.
2. **`drones`**: Hardware specifications, operational statuses (`inFlight`, `standby`, `maintenance`), battery thresholds, and sensor payloads.
3. **`hazards`**: Industrial crisis definitions categorized by zone, gas chemical types (Methane, H2S, CO, VOC), and PPM trigger thresholds.
4. **`training_sessions`**: Flight exercise records, timing, trainee reaction latencies, and outcome scores.
5. **`telemetry_logs`**: High-frequency time-series telemetry streams logging altitude, speed, atmospheric gases, and environmental parameters.
6. **`assessments`**: Certification evaluations, weighted component grading, and formal trainer remarks.
