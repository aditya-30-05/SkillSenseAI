# SkillSense AI — System Architecture

```mermaid
graph TD
    subgraph Clients["Frontend Layer"]
        FLUTTER["Flutter Mobile/Desktop/Web App (frontend/)"]
        NEXTJS["Next.js Operations Web Portal (web_portal/)"]
    end

    subgraph BackendLayer["Backend & Simulation Layer (backend/)"]
        API["REST & WebSocket Gateway"]
        SIM["Telemetry Simulation Engine"]
        HAZARD["Hazard Injection Service"]
        COACH["AI Coach & Assessment Service"]
    end

    subgraph DataLayer["Database & Storage Layer (database/)"]
        SQL[(PostgreSQL / SQLite Database)]
        SCHEMAS["SQL Schemas"]
        SEEDS["JSON Seed Datasets"]
    end

    FLUTTER <-->|Real-time Telemetry & Controls| API
    NEXTJS <-->|Management & Reports| API
    API <--> SIM
    API <--> HAZARD
    API <--> COACH
    API <--> SQL
    SCHEMAS --> SQL
    SEEDS --> SQL
```

## System Modules

1. **`frontend/`**: Flutter cross-platform trainer cockpit application featuring real-time HUD telemetry, hazard radar maps, interactive timeline replay, and trainee evaluation dashboards.
2. **`web_portal/`**: Next.js 16 / React 19 web application for administrators, trainers, and curriculum coordinators.
3. **`backend/`**: Real-time flight physics engine, telemetry generation, hazard injection orchestrator, and WebSocket communication gateway.
4. **`database/`**: Relational schema DDL, entity dictionaries, and JSON seed records.
5. **`docs/`**: UI/UX audit reports, development guidelines, and system diagrams.
