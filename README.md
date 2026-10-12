# 🧠 SkillSense AI — Intelligent Trainer & Safety Operations Platform

<div align="center">

![SkillSense AI Banner](https://img.shields.io/badge/SkillSense-AI-6366F1?style=for-the-badge&logo=flutter&logoColor=white)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Vercel Deployment](https://img.shields.io/badge/Deployed%20on-Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)](https://web-zeta-black-29.vercel.app)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

<h3>⚡ Empowering Trainers with Real-Time AI Insights, Skill Gap Detection & Industrial Telemetry</h3>

**[🌐 Live Demo & Prototype](https://web-zeta-black-29.vercel.app)** • **[🚀 Vercel Production](https://web-zeta-black-29.vercel.app)** • **[📦 GitHub Repo](https://github.com/aditya-30-05/SkillSenseAI.git)**

</div>

---

## 🗂️ Monorepo Architecture & Directory Structure

The repository is structured into distinct, modular subsystems:

```
trainer_app/
├── 📱 frontend/              # Primary Flutter Cross-Platform Client (Mobile, Desktop, Web)
│   ├── android/              # Native Android wrapper & Gradle configuration
│   ├── ios/                  # Native iOS Xcode workspace & CocoaPods
│   ├── web/                  # Flutter Web embedder & PWA manifest
│   ├── lib/                  # Dart source code (Features, Widgets, Theming, State)
│   │   ├── app/              # App Shell, theme tokens, responsive layout breakpoints
│   │   ├── core/             # Constants & local mock datasets
│   │   ├── features/         # 10 Domain screens (Dashboard, Live Monitor, Hazard Map, etc.)
│   │   ├── models/           # Domain entity classes (Trainee, Drone, Hazard, Telemetry)
│   │   ├── providers/        # Riverpod reactive state stores
│   │   ├── services/         # Client-side simulation service & ticker
│   │   └── widgets/          # Reusable UI library (Bento grid, Notch bar, Animated buttons)
│   ├── pubspec.yaml          # Flutter package dependencies
│   └── analysis_options.yaml # Static analysis rules & linter configuration
│
├── 🌐 web_portal/            # Next.js 16 & React 19 Operations Web Portal
│   ├── app/                  # Next.js App Router pages and layouts
│   ├── components/           # UI components, Radix UI & Lucide icons
│   ├── public/               # Static assets & icons
│   └── package.json          # Node dependencies & Next.js scripts
│
├── ⚙️ backend/               # Backend Services, APIs & Simulation Engine
│   ├── api/                  # OpenAPI 3.1 REST & WebSocket specifications
│   ├── simulation/           # Drone physics engine & gas sensor drift simulation
│   └── services/             # Hazard injector & telemetry streaming services
│
├── 🗄️ database/              # Database Layer, Schemas & Seed Datasets
│   ├── schemas/              # PostgreSQL & SQLite DDL tables (schema.sql)
│   ├── seeds/                # Structured JSON seed records (trainees, sessions, hazards, drones)
│   └── models/               # Visual Mermaid ER diagrams & data dictionary
│
├── 📚 docs/                  # Documentation & Technical Audit Reports
│   ├── frontend_report.md    # Complete UI/UX, Design System & Screen Audit Report
│   └── architecture.md       # High-level system architecture and data flows
│
└── 🚀 vercel.json            # Vercel deployment routing configuration
```

---

## 🚀 Getting Started

### 1. Running the Flutter Frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome     # Run in Chrome
# or
flutter run -d windows    # Run natively on Windows Desktop
```

### 2. Running the Web Portal (Next.js)
```bash
cd web_portal
npm install
npm run dev
```

### 3. Running Backend Simulation
```bash
cd backend/simulation
python simulation_engine.py
```

### 4. Database Setup
```bash
# PostgreSQL
psql -U postgres -d skillsense_db -f database/schemas/schema.sql

# SQLite
sqlite3 database/skillsense.db < database/schemas/schema.sql
```

---

## 📑 Detailed Technical Documentation
* **[Frontend Audit Report](file:///c:/Users/ACER/trainer_app/docs/frontend_report.md)**: Deep dive into design tokens, 10 feature screens, component library, and micro-interactions.
* **[System Architecture](file:///c:/Users/ACER/trainer_app/docs/architecture.md)**: Microservice topology, data communication, and state lifecycles.
* **[Database ER Diagram](file:///c:/Users/ACER/trainer_app/database/models/er_diagram.md)**: Entity relationships, table indices, and schema design.
* **[Backend API Spec](file:///c:/Users/ACER/trainer_app/backend/api/api_spec.json)**: REST & WebSocket API specification.
