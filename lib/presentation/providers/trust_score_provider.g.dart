// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trust_score_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trustScoreRepositoryHash() =>
    r'f966c74db020efd027021744a4e499adf7093367';

/// See also [trustScoreRepository].
@ProviderFor(trustScoreRepository)
final trustScoreRepositoryProvider =
    AutoDisposeProvider<TrustScoreRepository>.internal(
      trustScoreRepository,
      name: r'trustScoreRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trustScoreRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrustScoreRepositoryRef = AutoDisposeProviderRef<TrustScoreRepository>;
String _$trustScoreNotifierHash() =>
    r'52b23007fab2063cfd418c1efe656da2d6757663';

/// See also [TrustScoreNotifier].
@ProviderFor(TrustScoreNotifier)
final trustScoreNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TrustScoreNotifier, TrustScore?>.internal(
      TrustScoreNotifier.new,
      name: r'trustScoreNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trustScoreNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TrustScoreNotifier = AutoDisposeAsyncNotifier<TrustScore?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
