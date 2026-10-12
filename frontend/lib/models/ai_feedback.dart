class AiFeedback {
  final String id;
  final String sessionId;
  final String traineeId;
  final String overallPerformance;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final List<String> recommendations;
  final String trainerInsight;
  final double performanceChangePct;
  final DateTime generatedAt;

  const AiFeedback({
    required this.id,
    required this.sessionId,
    required this.traineeId,
    required this.overallPerformance,
    required this.strengths,
    required this.areasForImprovement,
    required this.recommendations,
    required this.trainerInsight,
    required this.performanceChangePct,
    required this.generatedAt,
  });
}

class AiChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  const AiChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });
}

class AiSessionAnalysis {
  final String sessionId;
  final String summary;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final String coachingNote;
  final double confidenceScore;

  const AiSessionAnalysis({
    required this.sessionId,
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.coachingNote,
    required this.confidenceScore,
  });
}
