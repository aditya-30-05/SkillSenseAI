import 'package:trainer_app/models/trainee.dart';
import 'package:trainer_app/models/drone.dart';
import 'package:trainer_app/models/hazard.dart';
import 'package:trainer_app/models/session.dart';
import 'package:trainer_app/models/assessment.dart';
import 'package:trainer_app/models/ai_feedback.dart';

class MockData {
  // ── Trainees ─────────────────────────────────────────────────────────────

  static final List<Trainee> trainees = [
    Trainee(
      id: 'T001',
      name: 'Rahul Sharma',
      avatarInitials: 'RS',
      trade: Trade.gasFitting,
      skillLevel: SkillLevel.intermediate,
      status: TrainingStatus.onTrack,
      totalSessions: 18,
      accuracyPercent: 92.0,
      avgResponseTimeSec: 18.0,
      falseAlarms: 3,
      hazardsIdentified: 34,
      hazardsMissed: 2,
      skillProgress: 0.74,
      remarks: 'Consistent improvement in response time. Focus on localization.',
      sessionScores: [72, 75, 78, 80, 83, 85, 87, 88, 90, 93],
      enrolledDate: DateTime(2026, 7, 1),
    ),
    Trainee(
      id: 'T002',
      name: 'Priya Patel',
      avatarInitials: 'PP',
      trade: Trade.plumbing,
      skillLevel: SkillLevel.advanced,
      status: TrainingStatus.excelling,
      totalSessions: 24,
      accuracyPercent: 96.5,
      avgResponseTimeSec: 14.2,
      falseAlarms: 1,
      hazardsIdentified: 48,
      hazardsMissed: 1,
      skillProgress: 0.92,
      remarks: 'Top performer. Ready for advanced certification track.',
      sessionScores: [85, 88, 90, 91, 92, 94, 95, 96, 97, 97],
      enrolledDate: DateTime(2026, 6, 15),
    ),
    Trainee(
      id: 'T003',
      name: 'Amir Khan',
      avatarInitials: 'AK',
      trade: Trade.welding,
      skillLevel: SkillLevel.beginner,
      status: TrainingStatus.needsAttention,
      totalSessions: 8,
      accuracyPercent: 68.0,
      avgResponseTimeSec: 34.5,
      falseAlarms: 8,
      hazardsIdentified: 14,
      hazardsMissed: 7,
      skillProgress: 0.32,
      remarks: 'Needs additional practice in hazard localization.',
      sessionScores: [45, 50, 55, 58, 62, 65, 68, 70],
      enrolledDate: DateTime(2026, 8, 10),
    ),
    Trainee(
      id: 'T004',
      name: 'Sneha Reddy',
      avatarInitials: 'SR',
      trade: Trade.electrical,
      skillLevel: SkillLevel.intermediate,
      status: TrainingStatus.onTrack,
      totalSessions: 15,
      accuracyPercent: 88.0,
      avgResponseTimeSec: 21.3,
      falseAlarms: 4,
      hazardsIdentified: 28,
      hazardsMissed: 3,
      skillProgress: 0.65,
      remarks: 'Good progress. Work on diagnostic procedure ordering.',
      sessionScores: [70, 73, 75, 78, 80, 82, 84, 85, 87, 88],
      enrolledDate: DateTime(2026, 7, 20),
    ),
    Trainee(
      id: 'T005',
      name: 'Vikram Singh',
      avatarInitials: 'VS',
      trade: Trade.gasCutting,
      skillLevel: SkillLevel.advanced,
      status: TrainingStatus.excelling,
      totalSessions: 22,
      accuracyPercent: 94.2,
      avgResponseTimeSec: 15.8,
      falseAlarms: 2,
      hazardsIdentified: 42,
      hazardsMissed: 1,
      skillProgress: 0.88,
      remarks: 'Excellent performance. Consistently identifying complex hazards.',
      sessionScores: [80, 83, 85, 87, 89, 91, 92, 93, 94, 95],
      enrolledDate: DateTime(2026, 6, 1),
    ),
    Trainee(
      id: 'T006',
      name: 'Divya Nair',
      avatarInitials: 'DN',
      trade: Trade.plumbing,
      skillLevel: SkillLevel.beginner,
      status: TrainingStatus.onTrack,
      totalSessions: 10,
      accuracyPercent: 76.0,
      avgResponseTimeSec: 28.0,
      falseAlarms: 5,
      hazardsIdentified: 18,
      hazardsMissed: 4,
      skillProgress: 0.45,
      remarks: 'Steady improvement. Encourage more practice sessions.',
      sessionScores: [60, 63, 67, 70, 72, 74, 75, 76, 77, 78],
      enrolledDate: DateTime(2026, 8, 1),
    ),
    Trainee(
      id: 'T007',
      name: 'Arjun Mehta',
      avatarInitials: 'AM',
      trade: Trade.gasFitting,
      skillLevel: SkillLevel.intermediate,
      status: TrainingStatus.needsAttention,
      totalSessions: 12,
      accuracyPercent: 74.0,
      avgResponseTimeSec: 29.5,
      falseAlarms: 7,
      hazardsIdentified: 20,
      hazardsMissed: 6,
      skillProgress: 0.52,
      remarks: 'Response time is improving. False positive rate still high.',
      sessionScores: [65, 68, 70, 71, 73, 74, 74, 75, 76, 78],
      enrolledDate: DateTime(2026, 7, 10),
    ),
    Trainee(
      id: 'T008',
      name: 'Kavya Rao',
      avatarInitials: 'KR',
      trade: Trade.electrical,
      skillLevel: SkillLevel.advanced,
      status: TrainingStatus.excelling,
      totalSessions: 20,
      accuracyPercent: 97.0,
      avgResponseTimeSec: 12.5,
      falseAlarms: 0,
      hazardsIdentified: 38,
      hazardsMissed: 0,
      skillProgress: 0.95,
      remarks: 'Outstanding performance. Consider mentoring junior trainees.',
      sessionScores: [88, 90, 92, 93, 94, 95, 96, 97, 97, 98],
      enrolledDate: DateTime(2026, 5, 15),
    ),
  ];

  // ── Drones ──────────────────────────────────────────────────────────────

  static final List<Drone> drones = [
    const Drone(
      id: 'DRONE-01',
      name: 'Alpha-1',
      status: DroneStatus.connected,
      mode: DroneMode.idle,
      batteryPercent: 82,
      signalStrength: 91,
      gpsLocked: true,
      latitude: 20.5937,
      longitude: 78.9629,
      altitudeM: 0.0,
      flightTimeSec: 0,
      currentZone: 'Base',
    ),
    const Drone(
      id: 'DRONE-02',
      name: 'Beta-2',
      status: DroneStatus.charging,
      mode: DroneMode.idle,
      batteryPercent: 45,
      signalStrength: 78,
      gpsLocked: true,
      latitude: 20.5940,
      longitude: 78.9635,
      altitudeM: 0.0,
      flightTimeSec: 0,
      currentZone: 'Base',
    ),
    const Drone(
      id: 'DRONE-03',
      name: 'Gamma-3',
      status: DroneStatus.disconnected,
      mode: DroneMode.idle,
      batteryPercent: 100,
      signalStrength: 0,
      gpsLocked: false,
      latitude: 20.5935,
      longitude: 78.9625,
      altitudeM: 0.0,
      flightTimeSec: 0,
      currentZone: 'Maintenance',
    ),
  ];

  // ── Hazard Events ────────────────────────────────────────────────────────

  static List<HazardEvent> hazardHistory = [
    HazardEvent(
      id: 'H001',
      type: HazardType.gas,
      riskLevel: RiskLevel.critical,
      confidencePercent: 94.0,
      sensorValue: 8.7,
      sensorUnit: 'ppm',
      latitude: 20.5942,
      longitude: 78.9631,
      zone: 'Zone A-03',
      detectedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      droneId: 'DRONE-01',
      sessionId: 'SS-1042',
      acknowledged: true,
      marked: true,
      responseStatus: 'Responded',
    ),
    HazardEvent(
      id: 'H002',
      type: HazardType.water,
      riskLevel: RiskLevel.warning,
      confidencePercent: 82.0,
      sensorValue: 15.3,
      sensorUnit: 'mm',
      latitude: 20.5945,
      longitude: 78.9634,
      zone: 'Zone B-01',
      detectedAt: DateTime.now().subtract(const Duration(hours: 1)),
      droneId: 'DRONE-01',
      sessionId: 'SS-1041',
      acknowledged: true,
      marked: true,
      responseStatus: 'Responded',
    ),
    HazardEvent(
      id: 'H003',
      type: HazardType.heat,
      riskLevel: RiskLevel.high,
      confidencePercent: 88.0,
      sensorValue: 78.4,
      sensorUnit: '°C',
      latitude: 20.5938,
      longitude: 78.9628,
      zone: 'Zone C-02',
      detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
      droneId: 'DRONE-02',
      sessionId: 'SS-1040',
      acknowledged: true,
      marked: true,
      responseStatus: 'Responded',
    ),
    HazardEvent(
      id: 'H004',
      type: HazardType.gas,
      riskLevel: RiskLevel.warning,
      confidencePercent: 76.0,
      sensorValue: 3.9,
      sensorUnit: 'ppm',
      latitude: 20.5950,
      longitude: 78.9640,
      zone: 'Zone D-01',
      detectedAt: DateTime.now().subtract(const Duration(hours: 3)),
      droneId: 'DRONE-01',
      sessionId: 'SS-1039',
      acknowledged: true,
      marked: false,
      responseStatus: 'Missed',
    ),
    HazardEvent(
      id: 'H005',
      type: HazardType.electrical,
      riskLevel: RiskLevel.critical,
      confidencePercent: 91.0,
      sensorValue: 240.0,
      sensorUnit: 'V',
      latitude: 20.5932,
      longitude: 78.9622,
      zone: 'Zone A-01',
      detectedAt: DateTime.now().subtract(const Duration(hours: 5)),
      droneId: 'DRONE-02',
      sessionId: 'SS-1038',
      acknowledged: true,
      marked: true,
      responseStatus: 'Responded',
    ),
  ];

  // ── Sessions ─────────────────────────────────────────────────────────────

  static List<TrainingSession> sessions = [
    TrainingSession(
      id: 'SS-1042',
      traineeId: 'T001',
      traineeName: 'Rahul Sharma',
      trade: Trade.gasFitting,
      exercise: ExerciseType.gasLeakDetection,
      difficulty: SkillLevel.intermediate,
      droneId: 'DRONE-01',
      status: SessionStatus.completed,
      startTime: DateTime.now().subtract(const Duration(minutes: 30)),
      endTime: DateTime.now().subtract(const Duration(minutes: 21)),
      hazards: [],
      hazardsDetected: 2,
      hazardsMissed: 0,
      falsePositives: 1,
      score: 93,
      durationSec: 522,
      timeline: _sampleTimeline(),
    ),
    TrainingSession(
      id: 'SS-1041',
      traineeId: 'T002',
      traineeName: 'Priya Patel',
      trade: Trade.plumbing,
      exercise: ExerciseType.pipeLeakLocalization,
      difficulty: SkillLevel.advanced,
      droneId: 'DRONE-01',
      status: SessionStatus.completed,
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 48)),
      hazards: [],
      hazardsDetected: 3,
      hazardsMissed: 0,
      falsePositives: 0,
      score: 97,
      durationSec: 720,
      timeline: [],
    ),
    TrainingSession(
      id: 'SS-1040',
      traineeId: 'T004',
      traineeName: 'Sneha Reddy',
      trade: Trade.electrical,
      exercise: ExerciseType.electricalFaultFinding,
      difficulty: SkillLevel.intermediate,
      droneId: 'DRONE-02',
      status: SessionStatus.active,
      startTime: DateTime.now().subtract(const Duration(minutes: 15)),
      hazards: [],
      hazardsDetected: 1,
      hazardsMissed: 0,
      falsePositives: 0,
      score: 0,
      durationSec: 900,
      timeline: [],
    ),
    TrainingSession(
      id: 'SS-1039',
      traineeId: 'T003',
      traineeName: 'Amir Khan',
      trade: Trade.welding,
      exercise: ExerciseType.weldingSafetyInspection,
      difficulty: SkillLevel.beginner,
      droneId: 'DRONE-01',
      status: SessionStatus.completed,
      startTime: DateTime.now().subtract(const Duration(hours: 4)),
      endTime: DateTime.now().subtract(const Duration(hours: 3, minutes: 45)),
      hazards: [],
      hazardsDetected: 1,
      hazardsMissed: 2,
      falsePositives: 3,
      score: 68,
      durationSec: 900,
      timeline: [],
    ),
    TrainingSession(
      id: 'SS-1038',
      traineeId: 'T005',
      traineeName: 'Vikram Singh',
      trade: Trade.gasCutting,
      exercise: ExerciseType.hazardIdentification,
      difficulty: SkillLevel.advanced,
      droneId: 'DRONE-02',
      status: SessionStatus.completed,
      startTime: DateTime.now().subtract(const Duration(hours: 6)),
      endTime: DateTime.now().subtract(const Duration(hours: 5, minutes: 42)),
      hazards: [],
      hazardsDetected: 4,
      hazardsMissed: 0,
      falsePositives: 0,
      score: 96,
      durationSec: 1080,
      timeline: [],
    ),
  ];

  static List<SessionTimelineEvent> _sampleTimeline() {
    final base = DateTime.now().subtract(const Duration(minutes: 30));
    return [
      SessionTimelineEvent(
        time: base,
        title: 'Mission Started',
        detail: 'DRONE-01 launched from base',
        eventType: 'start',
      ),
      SessionTimelineEvent(
        time: base.add(const Duration(minutes: 1, seconds: 16)),
        title: 'Drone Entered Zone A',
        detail: 'Altitude stabilised at 8.4 m',
        eventType: 'drone',
      ),
      SessionTimelineEvent(
        time: base.add(const Duration(minutes: 2, seconds: 1)),
        title: 'Gas Concentration Increasing',
        detail: 'Gas: 3.9 ppm — WARNING threshold reached',
        eventType: 'sensor',
      ),
      SessionTimelineEvent(
        time: base.add(const Duration(minutes: 2, seconds: 2)),
        title: 'AI Hazard Detection Triggered',
        detail: 'Confidence: 94% — Risk: HIGH',
        eventType: 'ai',
      ),
      SessionTimelineEvent(
        time: base.add(const Duration(minutes: 2, seconds: 16)),
        title: 'Trainee Acknowledged Alert',
        detail: 'Response time: 14 sec',
        eventType: 'trainee',
      ),
      SessionTimelineEvent(
        time: base.add(const Duration(minutes: 2, seconds: 38)),
        title: 'Trainee Marked Location',
        detail: 'Localization delta: 2.3 m',
        eventType: 'trainee',
      ),
      SessionTimelineEvent(
        time: base.add(const Duration(minutes: 3, seconds: 8)),
        title: 'Hazard Response Completed',
        detail: 'Correct safety action performed',
        eventType: 'trainee',
      ),
      SessionTimelineEvent(
        time: base.add(const Duration(minutes: 8, seconds: 42)),
        title: 'Session Completed',
        detail: 'Score: 93/100',
        eventType: 'complete',
      ),
    ];
  }

  // ── Assessments ──────────────────────────────────────────────────────────

  static final Map<String, Assessment> assessments = {
    'SS-1042': Assessment(
      id: 'A-1042',
      sessionId: 'SS-1042',
      traineeId: 'T001',
      categories: const [
        AssessmentCategory(
          name: 'Hazard Identification',
          score: 20,
          maxScore: 20,
          feedback: 'Correctly identified both hazards without hesitation.',
        ),
        AssessmentCategory(
          name: 'Localization Accuracy',
          score: 18,
          maxScore: 20,
          feedback: 'Good localization. Minor offset in second hazard marking.',
        ),
        AssessmentCategory(
          name: 'Response Time',
          score: 17,
          maxScore: 20,
          feedback: 'Response time of 18 sec is within acceptable range.',
        ),
        AssessmentCategory(
          name: 'Diagnostic Procedure',
          score: 18,
          maxScore: 20,
          feedback: 'Followed correct diagnostic sequence.',
        ),
        AssessmentCategory(
          name: 'Safety Response',
          score: 20,
          maxScore: 20,
          feedback: 'Executed all safety actions correctly.',
        ),
      ],
      totalScore: 93,
      maxScore: 100,
      generatedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      overallRemark:
          'Strong performance. Focus on reducing localization error.',
    ),
  };

  // ── AI Feedback ──────────────────────────────────────────────────────────

  static final Map<String, AiFeedback> aiFeedbacks = {
    'SS-1042': AiFeedback(
      id: 'AF-1042',
      sessionId: 'SS-1042',
      traineeId: 'T001',
      overallPerformance: 'Strong',
      strengths: [
        'Correctly identified both hazards',
        'Excellent safety response execution',
        'Followed the diagnostic sequence accurately',
      ],
      areasForImprovement: [
        'Localization accuracy in Zone B could improve',
        'One false-positive response recorded',
        'Response time slightly above optimal for second hazard',
      ],
      recommendations: [
        'Repeat medium-level localization exercises 2–3 times',
        'Practice zone triangulation drills',
        'Review gas dispersion patterns',
      ],
      trainerInsight:
          'Performance improved by 14% compared to the previous session. Rahul shows consistent upward trend in accuracy.',
      performanceChangePct: 14.0,
      generatedAt: DateTime.now().subtract(const Duration(minutes: 19)),
    ),
  };

  // ── Mock AI responses ────────────────────────────────────────────────────

  static String getMockAiResponse(String question) {
    final q = question.toLowerCase();
    if (q.contains('rahul') && q.contains('lost marks')) {
      return '''**Analysis for Rahul Sharma — Last Session (SS-1042)**

Rahul correctly identified both gas hazards during the session.

His primary weakness was **localization accuracy** in Zone B. He took 31 seconds to mark the second hazard, which is higher than his previous average of 18 seconds.

Additionally, one false-positive response was recorded — Rahul flagged a non-hazardous sensor spike in Zone A as a gas leak.

**Recommended Practice:**
- Repeat the *Gas Leak Localization* exercise at medium difficulty (2–3 times)
- Practice zone triangulation under time pressure
- Review gas dispersion simulation modules

📈 *Performance improved by 14% overall compared to Session SS-1041.*''';
    }
    if (q.contains('summarize') || q.contains('performance')) {
      return '''**Trainee Performance Summary**

| Metric | Value |
|--------|-------|
| Sessions Completed | 18 |
| Detection Accuracy | 92% |
| Avg Response Time | 18 sec |
| Hazards Identified | 34 |
| False Alarms | 3 |

**Trend:** Consistently improving over the last 5 sessions. Detection accuracy increased from 80% to 92% in 6 weeks.

**Risk Areas:** Localization in complex multi-zone scenarios.''';
    }
    if (q.contains('practice') || q.contains('next')) {
      return '''**Recommended Next Steps for Rahul Sharma**

Based on the last 5 sessions, I recommend:

1. 🎯 **Gas Leak Localization** — Medium difficulty (3 repetitions)
2. ⏱️ **Timed Response Drills** — Focus on sub-15 sec identification
3. 📍 **Zone Mapping Exercise** — Improve spatial awareness in Zone B & C

**Estimated Time to Next Level:** 4–6 sessions with consistent practice.

*This is a training recommendation only — not an official assessment.*''';
    }
    if (q.contains('report') || q.contains('generate')) {
      return '''**Training Report Generated**

📋 *SkillSense AI — Training Summary*

**Trainee:** Rahul Sharma
**Period:** Jul 2026 – Oct 2026
**Sessions:** 18 completed
**Overall Score:** 92/100

**Key Achievements:**
- Passed Gas Leak Detection (Intermediate)
- Improved response time by 38%
- Zero missed hazards in last 3 sessions

**Certification Note:** This is a *practice assessment* within a training simulation environment. Not an official NSQF certification.

*Report generated by SkillSense AI — Prototype v1.0*''';
    }
    if (q.contains('who') && q.contains('practice')) {
      return '''**Trainees Requiring Additional Practice:**

| Trainee | Trade | Issue | Priority |
|---------|-------|-------|----------|
| Amir Khan | Welding | High miss rate, slow response | 🔴 High |
| Arjun Mehta | Gas Fitting | Elevated false positives | 🟡 Medium |
| Divya Nair | Plumbing | Localization accuracy | 🟡 Medium |

**Recommendation:** Schedule additional practice sessions for Amir Khan this week. Focus on basic hazard identification drills.''';
    }
    return '''**SkillSense AI Coach Response**

Thank you for your question. Based on the available training data, here is my analysis:

The training sessions show overall positive progression across your cohort. Detection accuracy averages 88.3% with notable improvements in response time metrics.

For specific trainee insights, try asking:
- *"Summarize Rahul's performance"*
- *"What should [trainee] practice next?"*
- *"Show trainees who need additional practice"*
- *"Generate a trainer report"*

*SkillSense AI Coach — Prototype training analysis tool*
*Note: AI analysis is advisory only. Verify with direct observation.*''';
  }
}
