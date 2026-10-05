import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/models/session.dart';
import 'package:trainer_app/models/trainee.dart';
import 'package:trainer_app/models/assessment.dart';
import 'package:trainer_app/models/ai_feedback.dart';
import 'package:trainer_app/core/constants/mock_data.dart';

final sessionListProvider =
    StateNotifierProvider<SessionListNotifier, List<TrainingSession>>(
  (ref) => SessionListNotifier(),
);

class SessionListNotifier extends StateNotifier<List<TrainingSession>> {
  SessionListNotifier() : super(MockData.sessions);

  void addSession(TrainingSession session) {
    state = [session, ...state];
  }

  void updateSession(TrainingSession updated) {
    state = state.map((s) => s.id == updated.id ? updated : s).toList();
  }
}

final activeSessionProvider = StateProvider<TrainingSession?>((ref) => null);

final assessmentProvider = Provider<Map<String, Assessment>>((ref) {
  return MockData.assessments;
});

final aiFeedbackProvider = Provider<Map<String, AiFeedback>>((ref) {
  return MockData.aiFeedbacks;
});

// Session creation form state
class SessionFormState {
  final String? traineeId;
  final String? traineeName;
  final String? droneId;
  final ExerciseType? exercise;
  final SkillLevel difficulty;

  const SessionFormState({
    this.traineeId,
    this.traineeName,
    this.droneId,
    this.exercise,
    this.difficulty = SkillLevel.intermediate,
  });

  SessionFormState copyWith({
    String? traineeId,
    String? traineeName,
    String? droneId,
    ExerciseType? exercise,
    SkillLevel? difficulty,
  }) {
    return SessionFormState(
      traineeId: traineeId ?? this.traineeId,
      traineeName: traineeName ?? this.traineeName,
      droneId: droneId ?? this.droneId,
      exercise: exercise ?? this.exercise,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

final sessionFormProvider =
    StateNotifierProvider<SessionFormNotifier, SessionFormState>(
  (ref) => SessionFormNotifier(),
);

class SessionFormNotifier extends StateNotifier<SessionFormState> {
  SessionFormNotifier() : super(const SessionFormState());

  void setTrainee(String id, String name) =>
      state = state.copyWith(traineeId: id, traineeName: name);
  void setDrone(String id) => state = state.copyWith(droneId: id);
  void setExercise(ExerciseType ex) => state = state.copyWith(exercise: ex);
  void setDifficulty(SkillLevel lvl) => state = state.copyWith(difficulty: lvl);
  void reset() => state = const SessionFormState();
}
