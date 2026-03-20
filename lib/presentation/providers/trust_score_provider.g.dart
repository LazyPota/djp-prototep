// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trust_score_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trustScoreRepository)
final trustScoreRepositoryProvider = TrustScoreRepositoryProvider._();

final class TrustScoreRepositoryProvider
    extends
        $FunctionalProvider<
          TrustScoreRepository,
          TrustScoreRepository,
          TrustScoreRepository
        >
    with $Provider<TrustScoreRepository> {
  TrustScoreRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trustScoreRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trustScoreRepositoryHash();

  @$internal
  @override
  $ProviderElement<TrustScoreRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrustScoreRepository create(Ref ref) {
    return trustScoreRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrustScoreRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrustScoreRepository>(value),
    );
  }
}

String _$trustScoreRepositoryHash() =>
    r'f966c74db020efd027021744a4e499adf7093367';

@ProviderFor(TrustScoreNotifier)
final trustScoreProvider = TrustScoreNotifierProvider._();

final class TrustScoreNotifierProvider
    extends $AsyncNotifierProvider<TrustScoreNotifier, TrustScore?> {
  TrustScoreNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trustScoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trustScoreNotifierHash();

  @$internal
  @override
  TrustScoreNotifier create() => TrustScoreNotifier();
}

String _$trustScoreNotifierHash() =>
    r'52b23007fab2063cfd418c1efe656da2d6757663';

abstract class _$TrustScoreNotifier extends $AsyncNotifier<TrustScore?> {
  FutureOr<TrustScore?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TrustScore?>, TrustScore?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TrustScore?>, TrustScore?>,
              AsyncValue<TrustScore?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
