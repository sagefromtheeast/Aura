# AGENTS.md — Autonomous Self-Learning & Self-Healing Protocol

This document governs the operational habits, continuous improvement loops, and project-specific institutional memory for all Antigravity and AI coding agents operating within the **Aura (Privacy-First Offline Music Player)** codebase.

---

## 1. Core Mandatory Operational Rules

<RULE>
1. **Automatic Git Synchronization**: After every task, command, or knowledge update you complete, automatically do a `git add`, `git commit` with a descriptive message, and `git push` directly to the active branch without asking the user for permission.
2. **Universal /goal and /andrej-karpathy Mode**: Every time the user issues a command or prompt, treat it as explicitly invoking `/goal` (long-running, extra thorough execution that never stops until the goal is completely verified and fulfilled) and `/andrej-karpathy` (surgical, simple, zero-slop, high-signal engineering). Never abandon a task halfway; audit and test until 100% completion.
</RULE>

---

## 2. Autonomous Self-Healing Engine (The Diagnostic Loop)

When an error, build failure, runtime exception, or test failure occurs during your session, you must act as an autonomous self-healing software engineer:
1. **Stop & Isolate**: Never guess or randomly swap code. Extract the exact error stack trace, failing widget name, C++ FFI error, or broken command output.
2. **Diagnose & Hypothesize**: Identify the precise root cause using systematic debugging (e.g., inspecting parent bounding constraints for RenderFlex errors, checking FFI pointer allocations, or verifying Drift database schema migration versioning).
3. **Surgical Healing**: Implement the smallest, cleanest, and most idiom-aligned fix (per Andrej Karpathy guidelines: *Simplicity First, Surgical Changes*).
4. **Verify Verification**: Proactively re-run verification checks (`flutter analyze`, test runs, or hot restarts) to mathematically confirm the system is restored to 100% health before concluding your turn.

---

## 3. Autonomous Self-Learning Protocol (Continuous Evolution)

To prevent future AI sessions or subagents from repeating the exact same errors, you are equipped with a **Self-Learning Feedback Loop**. 

### When to Learn (Trigger Conditions)
You MUST proactively record a new rule or engineering pattern into this file whenever you:
- Encounter and successfully fix a bug, RenderFlex overflow, FFI memory leak, or runtime crash.
- Discover a platform-specific quirk or command-line syntax limitation.
- Receive structural corrections, architectural feedback, or design steering directly from the USER.
- Solve a tricky integration problem (e.g., Drift SQLite migration gotchas, Riverpod state lifecycle issues, C++ FFI callbacks, or Liquid Glass rendering glitches).

### How to Persist Learned Rules
1. Format your learning into a clear, actionable instruction starting with **DO** or **NEVER**.
2. Categorize it under the appropriate domain inside `<LEARNED_KNOWLEDGE_BASE>` below.
3. Automatically edit this `AGENTS.md` file using your file editing tools to append the new rule.
4. Commit and push the updated `AGENTS.md` alongside your code fix so the knowledge immediately propagates to all future agents working on this repository!

---

<LEARNED_KNOWLEDGE_BASE>

### [Shell & Build Engineering]
- **Windows PowerShell Sequential Commands**: In Windows PowerShell 5.1, **NEVER** use bash command chaining (`&&`). Always use semicolons (`;`) to separate sequential terminal execution commands (e.g., `git add . ; git commit -m "message" ; git push`).
- **Clean Analysis First**: Always run `flutter analyze` prior to committing to ensure zero static lints or syntax anomalies enter the repository.
- **Android Core Library Desugaring**: When utilizing plugins that require modern Java APIs on Android (such as `flutter_local_notifications` or time packages), **ALWAYS** ensure core library desugaring is enabled in `android/app/build.gradle.kts` via `isCoreLibraryDesugaringEnabled = true` within `compileOptions` and adding `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` to `dependencies`.
- **Android APK Packaging Exclusions**: In modern AGP builds (e.g. AGP 8+), merging multiple third-party plugins can cause duplicate `META-INF/*.version` files, which may truncate or corrupt the debug APK's ZIP Central Directory table during `packageDebug` (causing `aapt` / `zipro` "Invalid file" errors during `flutter run`). **ALWAYS** configure a defensive `packaging { resources { excludes += "META-INF/*.version" ... } }` block in `android/app/build.gradle.kts` to guarantee valid APK archive generation.
- **C++ FFI Shared Library Compilation**: When building the C++ audio engine bindings for Android (`.so`) and iOS (`.dylib`), ensure `ffigen` configuration aligns with Dart 3.6 FFI signatures and native memory ownership rules.

### [Flutter UI & Layout Engineering]
- **RenderFlex Overflow Prevention in Rows**: When placing text, labels, or `Column` widgets inside a horizontal `Row` (especially within padded containers like `GlassCard` or modals), **ALWAYS** wrap the variable-width child (`Column` or `Text`) inside an `Expanded` or `Flexible` widget, accompanied by explicit spacer bounding (e.g., `SizedBox(width: 12)`). Never allow raw strings to freely expand side-by-side with secondary trailing chips.
- **Modal Bottom Sheet Vertical Overflow Prevention**: When displaying lists of multi-line items or selectable options inside a modal bottom sheet (with `isScrollControlled: true`), **NEVER** place all items directly inside a static vertical `Column`. Always constrain the sheet height (e.g., `constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.82)`) and wrap the option list inside a `Flexible` or `Expanded` widget containing a scrollable `ListView(shrinkWrap: true)` to permanently prevent bottom RenderFlex overflows on smaller devices or when system font scaling is enlarged.
- **Liquid Glass Performance**: Strictly enforce the "one blur layer per screen" rule per design guidelines. Do not layer multiple heavy `BackdropFilter` widgets across identical Z-index hierarchies to guarantee peak 60fps Impeller/Vulkan graphics rendering on Android and iOS devices.
- **Dynamic Color Extraction**: Extract dynamic accent colors from album art using `palette_generator` and apply platform-adaptive theming via `DynamicThemeProvider` (`dynamic_color` for Material You on Android, custom iOS style on iOS).
- **Custom Widget Semantics**: Ensure all custom widgets (e.g. `GlassCard`, custom sliders, playback controls) have explicit `Semantics` wrappers for screen readers and accessibility tree compliance.

### [Drift, C++ Audio Engine, Security & Architecture]
- **Local Drift Database Migrations**: All Drift (SQLite) schema migrations in data repositories must remain non-destructive. Always use additive schema modifications (`CREATE TABLE IF NOT EXISTS`, `ALTER TABLE ADD COLUMN`) and verify backward compatibility so existing user playlists, track metadata, and behavior statistics are never lost during app updates.
- **Privacy-First / Zero-Cloud Enclave**: Never introduce external cloud or internet auth dependencies (no Firebase, no telemetry network endpoints). Aura is strictly offline-only. All local database keys and sensitive preferences must utilize `flutter_secure_storage` encryption at rest.
- **C++ Audio Engine FFI Boundaries**: The C++ audio engine runs audio processing on native threads. Continuous position and status updates back to Dart must use `NativeCallable` callback ports to prevent blocking the Flutter UI thread.

### [State & Riverpod Patterns]
- **Controller Lifecycle & Provider Synchronization**: When updating state within Riverpod domain controllers (`PlaybackOrchestrator`, `IntelliShuffleEngine`, `SmartMixGenerator`, `DuplicateDetector`), ensure asynchronous state mutations properly await background Drift SQLite transactions before notifying listening UI consumer components. Use `freezed` for immutable state objects.

</LEARNED_KNOWLEDGE_BASE>
