# AGENTS.md

This document explains what each important file in this workspace does.

## Root Files

- `README.md`: Project overview, setup, and run instructions.
- `iOS_SETUP_INSTRUCTIONS.md`: Manual iOS Share Extension setup steps.
- `pubspec.yaml`: App dependencies, SDK constraints, and Flutter package config.
- `pubspec.lock`: Resolved dependency versions for reproducible builds.
- `analysis_options.yaml`: Dart/Flutter lint and analyzer rules.

## App Source (`lib`)

### Entry Point

- `lib/main.dart`: Main app entry point; configures localization/theme and overlay entrypoint.

### Core Services

- `lib/core/services/fraud_api_service.dart`: Calls backend endpoints for URL analysis and global stats.
- `lib/core/services/protection_prefs.dart`: Reads/writes onboarding and protection counters via shared preferences.
- `lib/core/services/shared_intent_service.dart`: Listens for shared content intents and triggers URL analysis.

### Core Utilities

- `lib/core/utils/app_config.dart`: Central endpoint/config values.
- `lib/core/utils/overlay_handler.dart`: Overlay helper methods and data handoff logic.
- `lib/core/utils/supported_apps.dart`: Supported shopping app/package allowlist.

### Data Layer

- `lib/data/repositories/mock_trust_score_repository.dart`: Mock repository implementation for trust-score analysis.

### Domain Layer

- `lib/domain/entities/trust_score.dart`: Domain model for trust score response data.
- `lib/domain/repositories/trust_score_repository.dart`: Repository contract for trust-score analysis.

### Localization

- `lib/l10n/app_localizations.dart`: Generated localization delegate and translated strings.
- `lib/l10n/l10n_extensions.dart`: Convenience extension for localization access from BuildContext.

### State/Providers

- `lib/presentation/providers/app_state_providers.dart`: Global app providers (theme, locale, onboarding, app services).
- `lib/presentation/providers/trust_score_provider.dart`: Async notifier/provider for URL analysis state.

### Screens

- `lib/presentation/screens/app_root.dart`: Chooses onboarding flow or main shell based on app state.
- `lib/presentation/screens/activity_screen.dart`: Shows activity/events captured from monitored apps.
- `lib/presentation/screens/home_screen.dart`: Main control screen for overlay and protection actions.
- `lib/presentation/screens/main_screen.dart`: Legacy/prototype analysis UI with URL input and score display.
- `lib/presentation/screens/main_shell_screen.dart`: Bottom navigation shell hosting primary tabs.
- `lib/presentation/screens/onboarding_screen.dart`: First-run permissions/setup walkthrough.
- `lib/presentation/screens/setup_screen.dart`: User settings (theme/language) and permission status.

### Widgets

- `lib/presentation/widgets/overlay_widget.dart`: UI rendered in floating overlay mode.
- `lib/presentation/widgets/risk_flags_list.dart`: Renders fraud/risk flags list.
- `lib/presentation/widgets/trust_gauge.dart`: Custom-painted trust score gauge visualization.

## Plugin Package (`packages/fraud_accessibility_bridge`)

### Plugin API

- `packages/fraud_accessibility_bridge/lib/fraud_accessibility_bridge.dart`: Public Dart API for the plugin.
- `packages/fraud_accessibility_bridge/lib/fraud_accessibility_bridge_method_channel.dart`: MethodChannel bridge to native platform code.
- `packages/fraud_accessibility_bridge/lib/fraud_accessibility_bridge_platform_interface.dart`: Platform interface contract for implementations.

### Plugin Metadata

- `packages/fraud_accessibility_bridge/pubspec.yaml`: Plugin package dependencies and platform registration.
- `packages/fraud_accessibility_bridge/README.md`: Plugin usage documentation.
- `packages/fraud_accessibility_bridge/CHANGELOG.md`: Plugin version history.

### Plugin Example

- `packages/fraud_accessibility_bridge/example/lib/main.dart`: Example app demonstrating plugin usage.
- `packages/fraud_accessibility_bridge/example/pubspec.yaml`: Example app dependencies.
- `packages/fraud_accessibility_bridge/example/README.md`: Example app notes.

## Platform and Build Directories

- `android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/`: Platform-specific host runner files, manifests, build settings, and generated registrants.
- `build/`, `**/ephemeral/`, generated plugin registrant files: Build artifacts or generated files; avoid manual edits unless you know why.

## Practical Editing Rule

- Prefer editing files in `lib/` and plugin `lib/` for app behavior.
- Treat generated files (for example localization outputs and generated registrants) as derived artifacts.
