import '../../domain/entities/trust_score.dart';
import '../../domain/repositories/trust_score_repository.dart';

class MockTrustScoreRepository implements TrustScoreRepository {
  @override
  Future<TrustScore> analyzeProductUrl(String url) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock API response based on provided JSON structure
    final Map<String, dynamic> mockJsonResponse = {
      "fri_score": 25,
      "risk_level": "High Risk",
      "flags": [
        "High Negative Sentiment Density",
        "Product Description Contradiction",
        "Premature Shop Age"
      ],
      "metrics": {
        "negative_review_ratio": 0.45,
        "price_anomaly": true
      }
    };

    return TrustScore.fromJson(mockJsonResponse);
  }
}
