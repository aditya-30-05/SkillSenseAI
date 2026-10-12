-- ==============================================================================
-- SkillSense AI — Database Schema
-- Dialect: PostgreSQL / SQLite Compatible
-- Description: Core tables for Trainees, Drone Telemetry, Hazards, Sessions & Assessments
-- ==============================================================================

-- 1. Trainees Table
CREATE TABLE IF NOT EXISTS trainees (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    avatar_initials VARCHAR(8) NOT NULL,
    trade VARCHAR(64) NOT NULL,              -- gasFitting, plumbing, welding, electrical
    skill_level VARCHAR(32) NOT NULL,        -- beginner, intermediate, advanced
    status VARCHAR(32) NOT NULL,             -- excelling, onTrack, needsAttention
    total_sessions INTEGER DEFAULT 0,
    accuracy_percent NUMERIC(5, 2) DEFAULT 0.0,
    avg_response_time_sec NUMERIC(6, 2) DEFAULT 0.0,
    false_alarms INTEGER DEFAULT 0,
    hazards_identified INTEGER DEFAULT 0,
    hazards_missed INTEGER DEFAULT 0,
    skill_progress NUMERIC(4, 2) DEFAULT 0.0, -- 0.00 to 1.00
    remarks TEXT,
    session_scores JSONB,                    -- Array of historical integer scores [72, 75, 80...]
    enrolled_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Drones Fleet Table
CREATE TABLE IF NOT EXISTS drones (
    id VARCHAR(32) PRIMARY KEY,
    callsign VARCHAR(64) NOT NULL,           -- e.g. 'AERO-V1', 'SCOUT-02'
    model VARCHAR(64) NOT NULL,
    firmware_version VARCHAR(32) NOT NULL,
    status VARCHAR(32) NOT NULL,             -- standby, inFlight, returning, maintenance
    battery_level INTEGER DEFAULT 100,       -- 0 to 100
    sensors_enabled JSONB,                   -- ['gas_optical', 'thermal', 'lidar']
    last_ping_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Hazards Catalog Table
CREATE TABLE IF NOT EXISTS hazards (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,              -- e.g. 'Methane Gas Leak', 'CO Build-up'
    gas_type VARCHAR(64) NOT NULL,           -- CH4, H2S, CO, LPG, smoke
    zone VARCHAR(64) NOT NULL,               -- Zone A: Pipe Gallery, Zone B: Storage, etc.
    severity VARCHAR(32) NOT NULL,           -- safe, warning, high, critical
    threshold_ppm NUMERIC(8, 2) NOT NULL,
    description TEXT,
    recommended_action TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Training Sessions Table
CREATE TABLE IF NOT EXISTS training_sessions (
    id VARCHAR(32) PRIMARY KEY,
    trainee_id VARCHAR(32) REFERENCES trainees(id) ON DELETE CASCADE,
    drone_id VARCHAR(32) REFERENCES drones(id) ON DELETE SET NULL,
    exercise_type VARCHAR(128) NOT NULL,     -- Gas Leak Localization, Emergency RTH, etc.
    status VARCHAR(32) NOT NULL,             -- scheduled, active, paused, completed, aborted
    score NUMERIC(5, 2) DEFAULT 0.0,
    duration_seconds INTEGER DEFAULT 0,
    hazard_detected BOOLEAN DEFAULT FALSE,
    reaction_time_sec NUMERIC(6, 2) DEFAULT 0.0,
    hazards_injected INTEGER DEFAULT 0,
    hazards_resolved INTEGER DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    trainer_notes TEXT
);

-- 5. Session Timeline Events Table
CREATE TABLE IF NOT EXISTS session_timeline_events (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(32) REFERENCES training_sessions(id) ON DELETE CASCADE,
    step_number INTEGER NOT NULL,
    title VARCHAR(128) NOT NULL,
    description TEXT,
    timestamp_sec INTEGER NOT NULL,
    event_type VARCHAR(32) NOT NULL,          -- info, trigger, action, alert, completion
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Live Drone Telemetry Logs Table
CREATE TABLE IF NOT EXISTS telemetry_logs (
    id BIGSERIAL PRIMARY KEY,
    session_id VARCHAR(32) REFERENCES training_sessions(id) ON DELETE CASCADE,
    drone_id VARCHAR(32) REFERENCES drones(id) ON DELETE SET NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    altitude_meters NUMERIC(6, 2) NOT NULL,
    ground_speed_mps NUMERIC(6, 2) NOT NULL,
    battery_percent INTEGER NOT NULL,
    gas_ppm NUMERIC(8, 2) NOT NULL,
    temp_celsius NUMERIC(5, 2) NOT NULL,
    humidity_percent NUMERIC(5, 2) NOT NULL,
    signal_dbm INTEGER NOT NULL,
    latitude NUMERIC(10, 7) NOT NULL,
    longitude NUMERIC(10, 7) NOT NULL,
    active_hazard_id VARCHAR(32) REFERENCES hazards(id)
);

-- 7. Trainee Assessments & Certifications Table
CREATE TABLE IF NOT EXISTS assessments (
    id VARCHAR(32) PRIMARY KEY,
    session_id VARCHAR(32) REFERENCES training_sessions(id) ON DELETE CASCADE,
    trainee_id VARCHAR(32) REFERENCES trainees(id) ON DELETE CASCADE,
    accuracy_score NUMERIC(5, 2) NOT NULL,
    reaction_score NUMERIC(5, 2) NOT NULL,
    safety_compliance_score NUMERIC(5, 2) NOT NULL,
    composite_score NUMERIC(5, 2) NOT NULL,
    grade VARCHAR(8) NOT NULL,               -- A+, A, B, C, F
    is_certified BOOLEAN DEFAULT FALSE,
    certificate_id VARCHAR(64),
    evaluator_remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performant telemetry querying and dashboard aggregations
CREATE INDEX IF NOT EXISTS idx_telemetry_session_ts ON telemetry_logs (session_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_sessions_trainee ON training_sessions (trainee_id, status);
CREATE INDEX IF NOT EXISTS idx_assessments_trainee ON assessments (trainee_id);
CREATE INDEX IF NOT EXISTS idx_hazards_zone ON hazards (zone);
