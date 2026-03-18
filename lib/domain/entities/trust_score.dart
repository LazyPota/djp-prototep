class TrustMetrics {
  final double negativeReviewRatio;
  final bool priceAnomaly;

  TrustMetrics({
    required this.negativeReviewRatio,
    required this.priceAnomaly,
  });

  factory TrustMetrics.fromJson(Map<String, dynamic> json) {
    return TrustMetrics(
      negativeReviewRatio: (json['negative_review_ratio'] as num?)?.toDouble() ?? 0.0,
      priceAnomaly: json['price_anomaly'] as bool? ?? false,
    );
  }
}

class TrustScore {
  final int friScore;
  final String riskLevel;
  final List<String> flags;
  final TrustMetrics metrics;

  TrustScore({
    required this.friScore,
    required this.riskLevel,
    required this.flags,
    required this.metrics,
  });

  factory TrustScore.fromJson(Map<String, dynamic> json) {
    return TrustScore(
      friScore: json['fri_score'] as int? ?? 0,
      riskLevel: json['risk_level'] as String? ?? 'Unknown',
      flags: (json['flags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      metrics: TrustMetrics.fromJson(json['metrics'] as Map<String, dynamic>? ?? {}),
    );
  }
}
