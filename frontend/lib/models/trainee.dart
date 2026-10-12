import 'package:flutter/foundation.dart';

enum Trade { gasFitting, plumbing, electrical, welding, gasCutting }

enum SkillLevel { beginner, intermediate, advanced }

enum TrainingStatus { onTrack, needsAttention, excelling, inactive }

extension TradeExtension on Trade {
  String get label {
    switch (this) {
      case Trade.gasFitting:
        return 'Gas Fitting';
      case Trade.plumbing:
        return 'Plumbing';
      case Trade.electrical:
        return 'Electrical';
      case Trade.welding:
        return 'Welding';
      case Trade.gasCutting:
        return 'Gas Cutting';
    }
  }
}

extension SkillLevelExtension on SkillLevel {
  String get label {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
    }
  }
}

extension TrainingStatusExtension on TrainingStatus {
  String get label {
    switch (this) {
      case TrainingStatus.onTrack:
        return 'On Track';
      case TrainingStatus.needsAttention:
        return 'Needs Attention';
      case TrainingStatus.excelling:
        return 'Excelling';
      case TrainingStatus.inactive:
        return 'Inactive';
    }
  }
}

@immutable
class Trainee {
  final String id;
  final String name;
  final String avatarInitials;
  final Trade trade;
  final SkillLevel skillLevel;
  final TrainingStatus status;
  final int totalSessions;
  final double accuracyPercent;
  final double avgResponseTimeSec;
  final int falseAlarms;
  final int hazardsIdentified;
  final int hazardsMissed;
  final double skillProgress;
  final String remarks;
  final List<double> sessionScores;
  final DateTime enrolledDate;

  const Trainee({
    required this.id,
    required this.name,
    required this.avatarInitials,
    required this.trade,
    required this.skillLevel,
    required this.status,
    required this.totalSessions,
    required this.accuracyPercent,
    required this.avgResponseTimeSec,
    required this.falseAlarms,
    required this.hazardsIdentified,
    required this.hazardsMissed,
    required this.skillProgress,
    required this.remarks,
    required this.sessionScores,
    required this.enrolledDate,
  });
}
