import 'package:trainer_app/models/trainee.dart';
import 'package:trainer_app/models/hazard.dart';

enum SessionStatus { pending, active, paused, completed, cancelled }
enum ExerciseType {
  gasLeakDetection,
  pipeLeakLocalization,
  weldingSafetyInspection,
  hazardIdentification,
  electricalFaultFinding,
}

extension ExerciseTypeExtension on ExerciseType {
  String get label {
    switch (this) {
      case ExerciseType.gasLeakDetection:
        return 'Gas Leak Detection';
      case ExerciseType.pipeLeakLocalization:
        return 'Pipe Leak Localization';
      case ExerciseType.weldingSafetyInspection:
        return 'Welding Safety Inspection';
      case ExerciseType.hazardIdentification:
        return 'Hazard Identification';
      case ExerciseType.electricalFaultFinding:
        return 'Electrical Fault Finding';
    }
  }
}

extension SessionStatusExtension on SessionStatus {
  String get label {
    switch (this) {
      case SessionStatus.pending:
        return 'Pending';
      case SessionStatus.active:
        return 'Active';
      case SessionStatus.paused:
        return 'Paused';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class SessionTimelineEvent {
  final DateTime time;
  final String title;
  final String? detail;
  final String eventType; // 'start','drone','sensor','ai','trainee','complete'

  const SessionTimelineEvent({
    required this.time,
    required this.title,
    this.detail,
    required this.eventType,
  });
}

class TrainingSession {
  final String id;
  final String traineeId;
  final String traineeName;
  final Trade trade;
  final ExerciseType exercise;
  final SkillLevel difficulty;
  final String droneId;
  final SessionStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final List<HazardEvent> hazards;
  final int hazardsDetected;
  final int hazardsMissed;
  final int falsePositives;
  final int score;
  final double durationSec;
  final List<SessionTimelineEvent> timeline;

  const TrainingSession({
    required this.id,
    required this.traineeId,
    required this.traineeName,
    required this.trade,
    required this.exercise,
    required this.difficulty,
    required this.droneId,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.hazards,
    required this.hazardsDetected,
    required this.hazardsMissed,
    required this.falsePositives,
    required this.score,
    required this.durationSec,
    required this.timeline,
  });

  TrainingSession copyWith({
    SessionStatus? status,
    DateTime? endTime,
    List<HazardEvent>? hazards,
    int? hazardsDetected,
    int? hazardsMissed,
    int? falsePositives,
    int? score,
    double? durationSec,
    List<SessionTimelineEvent>? timeline,
  }) {
    return TrainingSession(
      id: id,
      traineeId: traineeId,
      traineeName: traineeName,
      trade: trade,
      exercise: exercise,
      difficulty: difficulty,
      droneId: droneId,
      status: status ?? this.status,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      hazards: hazards ?? this.hazards,
      hazardsDetected: hazardsDetected ?? this.hazardsDetected,
      hazardsMissed: hazardsMissed ?? this.hazardsMissed,
      falsePositives: falsePositives ?? this.falsePositives,
      score: score ?? this.score,
      durationSec: durationSec ?? this.durationSec,
      timeline: timeline ?? this.timeline,
    );
  }

  String get durationFormatted {
    final d = Duration(seconds: durationSec.toInt());
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
