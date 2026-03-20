import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/trust_score.dart';
import '../../domain/repositories/trust_score_repository.dart';
import '../../data/repositories/mock_trust_score_repository.dart';

part 'trust_score_provider.g.dart';

@riverpod
TrustScoreRepository trustScoreRepository(Ref ref) {
  return MockTrustScoreRepository();
}

@riverpod
class TrustScoreNotifier extends _$TrustScoreNotifier {
  @override
  FutureOr<TrustScore?> build() {
    return null;
  }

  Future<void> analyzeUrl(String url) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(trustScoreRepositoryProvider);
      final score = await repository.analyzeProductUrl(url);
      state = AsyncValue.data(score);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}