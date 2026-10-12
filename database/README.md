# SkillSense AI — Database Module

This directory organizes all database schemas, seed datasets, and data models for SkillSense AI.

## Directory Structure

```
database/
├── schemas/
│   └── schema.sql        # Standard SQL (PostgreSQL/SQLite) DDL table definitions
├── seeds/
│   ├── trainees.json     # Trainee profiles, historical scores, and skill levels
│   ├── sessions.json     # Training session logs, duration, and exercise types
│   ├── hazards.json      # Gas types, danger PPM thresholds, and zones
│   └── drones.json       # Fleet specifications, sensors, and battery profiles
├── models/
│   └── er_diagram.md     # Visual Mermaid ER diagram and entity definitions
└── README.md             # This file
```

## Quick Start / Seeding

### 1. PostgreSQL Initial Setup
```bash
psql -U postgres -d skillsense_db -f schemas/schema.sql
```

### 2. SQLite Initial Setup
```bash
sqlite3 skillsense.db < schemas/schema.sql
```
