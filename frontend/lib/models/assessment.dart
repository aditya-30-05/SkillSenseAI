class AssessmentCategory {
  final String name;
  final int score;
  final int maxScore;
  final String feedback;

  const AssessmentCategory({
    required this.name,
    required this.score,
    required this.maxScore,
    required this.feedback,
  });

  double get percentage => score / maxScore;
}

class Assessment {
  final String id;
  final String sessionId;
  final String traineeId;
  final List<AssessmentCategory> categories;
  final int totalScore;
  final int maxScore;
  final DateTime generatedAt;
  final String overallRemark;

  const Assessment({
    required this.id,
    required this.sessionId,
    required this.traineeId,
    required this.categories,
    required this.totalScore,
    required this.maxScore,
    required this.generatedAt,
    required this.overallRemark,
  });

  double get percentage => totalScore / maxScore;
}
