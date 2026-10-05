import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/models/ai_feedback.dart';
import 'package:trainer_app/core/constants/mock_data.dart';

// Settings providers
final demoModeProvider = StateProvider<bool>((ref) => true);
final darkModeProvider = StateProvider<bool>((ref) => true);
final aiEnabledProvider = StateProvider<bool>((ref) => true);
final notificationsProvider = StateProvider<bool>((ref) => true);
final alertThresholdProvider = StateProvider<double>((ref) => 5.0);

// Auth providers
final isLoggedInProvider = StateProvider<bool>((ref) => false);
final trainerNameProvider = StateProvider<String>((ref) => 'Demo Trainer');

// AI Chat provider
final aiChatHistoryProvider =
    StateNotifierProvider<AiChatNotifier, List<AiChatMessage>>(
  (ref) => AiChatNotifier(),
);

class AiChatNotifier extends StateNotifier<List<AiChatMessage>> {
  AiChatNotifier() : super([]);

  void addMessage(AiChatMessage msg) {
    state = [...state, msg];
  }

  void updateLastMessage(AiChatMessage updated) {
    final list = [...state];
    if (list.isNotEmpty) list[list.length - 1] = updated;
    state = list;
  }

  Future<void> sendUserMessage(String text) async {
    final userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
    addMessage(AiChatMessage(
      id: userId,
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    // Typing indicator
    final loadingId = 'ai-loading-${DateTime.now().millisecondsSinceEpoch}';
    addMessage(AiChatMessage(
      id: loadingId,
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    ));

    // Simulate AI delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final response = MockData.getMockAiResponse(text);
    final aiId = 'ai-${DateTime.now().millisecondsSinceEpoch}';
    updateLastMessage(AiChatMessage(
      id: aiId,
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void clear() => state = [];
}

// Navigation index
final navIndexProvider = StateProvider<int>((ref) => 0);
