import '../entities/trust_score.dart';

abstract class TrustScoreRepository {
  Future<TrustScore> analyzeProductUrl(String url);
}
