import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/models/trainee.dart';
import 'package:trainer_app/core/constants/mock_data.dart';

final traineeListProvider = Provider<List<Trainee>>((ref) {
  return MockData.trainees;
});

final traineeSearchProvider = StateProvider<String>((ref) => '');

final tradeFilterProvider = StateProvider<Trade?>((ref) => null);

final filteredTraineesProvider = Provider<List<Trainee>>((ref) {
  final search = ref.watch(traineeSearchProvider).toLowerCase();
  final tradeFilter = ref.watch(tradeFilterProvider);
  final all = ref.watch(traineeListProvider);
  return all.where((t) {
    final matchesSearch =
        search.isEmpty || t.name.toLowerCase().contains(search);
    final matchesTrade = tradeFilter == null || t.trade == tradeFilter;
    return matchesSearch && matchesTrade;
  }).toList();
});

final selectedTraineeProvider = StateProvider<Trainee?>((ref) => null);
