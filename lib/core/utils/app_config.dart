class AppConfig {
  static const String analyzeUrlEndpoint = String.fromEnvironment(
    'FRAUD_SERVER_URL',
    defaultValue: 'http://10.0.2.2:8080/analyze',
  );

  static const String globalStatsEndpoint = String.fromEnvironment(
    'FRAUD_STATS_URL',
    defaultValue: 'http://10.0.2.2:8080/stats',
  );
}
