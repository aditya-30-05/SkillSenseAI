# 🧠 SkillSense AI — Intelligent Trainer & Trainee Performance Analytics Platform

<div align="center">

![SkillSense AI Banner](https://img.shields.io/badge/SkillSense-AI-6366F1?style=for-the-badge&logo=flutter&logoColor=white)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Vercel Deployment](https://img.shields.io/badge/Deployed%20on-Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)](https://web-zeta-black-29.vercel.app)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

<h3>⚡ Empowering Trainers with Real-Time AI Insights, Skill Gap Detection & Automated Performance Roadmaps</h3>

**[🌐 Live Demo & Prototype](https://web-zeta-black-29.vercel.app)** • **[🚀 Vercel Production](https://web-zeta-black-29.vercel.app)** • **[📦 GitHub Repo](https://github.com/aditya-30-05/SkillSenseAI.git)**

</div>

---

## 🌟 Quick Links

* 🔗 **Live Vercel Web App**: [https://web-zeta-black-29.vercel.app](https://web-zeta-black-29.vercel.app)
* 📱 **Interactive Prototype**: [https://web-zeta-black-29.vercel.app](https://web-zeta-black-29.vercel.app)
* 📂 **Source Repository**: [https://github.com/aditya-30-05/SkillSenseAI.git](https://github.com/aditya-30-05/SkillSenseAI.git)

---

## 📖 Overview

**SkillSense AI** is a next-generation corporate training and talent development dashboard built with Flutter Web. Designed with a sleek obsidian dark theme, glassmorphic accents, and micro-interactions, it provides trainers, managers, and enterprise coaches with an intelligent control center to monitor cohort progress, pinpoint skill deficiencies, simulate performance trajectory, and auto-generate personalized curriculum interventions.

---

## ✨ Key Features & Modules

### 1. 📊 Executive Dashboard & Analytics
* **Cohort Health KPI Cards**: Real-time tracking of active trainees, average assessment scores, completion rates, and at-risk alerts.
* **Skill Radar Matrix & Competency Breakdown**: Multi-dimensional capability maps across technical stacks, soft skills, and problem-solving metrics.
* **Attendance & Weekly Velocity Graphs**: Interactive trendlines visualizing training engagement and milestone velocity.

### 2. 👥 Trainee Roster & Dynamic Profiles
* **Trainee Directory**: Filter by batch, status (Top Performer, On Track, Needs Attention), and domain.
* **Deep-Dive Trainee Profile**: Detailed breakdown with milestone progression bars, skill gap badges, learning curve trajectories, and historical feedback timeline.

### 3. 🤖 AI Assistant & Smart Copilot
* **Interactive AI Chat**: Context-aware trainer co-pilot capable of answering performance queries, analyzing cohort drop-off risks, and recommending personalized remedial tasks.
* **Prompt Quick Actions**: Instant prompts for generating quizzes, drafting 1-on-1 feedback reviews, and summarizing training sessions.

### 4. 📈 Performance & Predictive Analytics
* **Cohort-Wide Benchmarking**: Side-by-side comparative analysis of cohorts.
* **Skill Distribution Heatmaps**: Highlighting areas where students excel vs. modules requiring trainer intervention.

### 5. 📑 Automated Reports & Export Engine
* **One-Click Comprehensive Report Generation**: Export PDF/CSV summaries for stakeholders.
* **Assessment Insights**: Detailed breakdowns of quiz scores, assignment turnaround times, and evaluation rubrics.

### 6. ⚙️ Customization & Enterprise Settings
* **Theme & Workspace Preferences**: Customizable theme configurations and notification thresholds.
* **System Health Monitoring**: Live status of analytics pipelines and sync status.

---

## 🎨 Design System & Aesthetic Architecture

* **Theme**: Deep obsidian dark palette (`#0B0F17`, `#111827`, `#1E293B`) with indigo/violet accents (`#6366F1`, `#8B5CF6`).
* **Visual Styling**: Subtle borders, glassmorphic card containers (`InteractiveCard`), smooth hover transitions, and responsive fluid layout.
* **Animations**: Gentle entry slide fades, staggered list appearance, and responsive interactive feedback states.

---

## 🛠️ Tech Stack

* **Framework**: [Flutter Web](https://flutter.dev) (Dart)
* **State Management**: Provider / Stateful component architecture
* **Icons & Assets**: Material Icons + Modern SVG Vector Integrations
* **Deployment & Hosting**: [Vercel](https://vercel.com)
* **CI/CD**: Git-based continuous deployment

---

## 🚀 Getting Started Locally

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.19+ recommended)
* [Dart SDK](https://dart.dev/get-dart)
* Google Chrome or any modern web browser

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/aditya-30-05/SkillSenseAI.git
   cd SkillSenseAI
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on local development server**:
   ```bash
   flutter run -d chrome
   ```
   *Or for headless web server:*
   ```bash
   flutter run -d web-server --web-port 3000 --web-hostname localhost
   ```

4. **Build for production**:
   ```bash
   flutter build web --release
   ```

---

## 🌐 Deploy to Vercel

```bash
# Build the production release
flutter build web --release

# Deploy using Vercel CLI
vercel deploy build/web --prod --yes
```

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

<div align="center">
  <sub>Built with ❤️ by Aditya & the SkillSense AI Team</sub>
</div>
