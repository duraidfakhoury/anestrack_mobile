# AnesTrack Mobile - CLAUDE.md

## Project Context
- **Name:** anestrack_mobile
- **Description:** Flutter mobile application built using Domain-Driven Design (DDD) / Clean Architecture.
- **Completion:** ~40% built.
- **External Specs:**
  - API Swagger spec: `./swagger.json`
  - Design specs/screenshots: `./design_specs/`

## Core Architecture & Guidelines

### 1. Architectural Pattern (DDD / Clean Architecture)
Each feature module inside `lib/modules/<feature_name>/` must follow this structure:
- **`data/`**: Data sources (`_data_source.dart`, `_impl.dart`), Models (`_model.dart`), and Repositories (`_repository_impl.dart`).
- **`domain/`**: Entities (`.dart`), Parameters (`_parameters.dart`), Repositories contracts (`_repository.dart`), and Use Cases (`_usecase.dart`).
- **`presentation/`**: Blocs (`_bloc.dart`, `_event.dart`, `_state.dart`), Screens (`_screen.dart`), Routes (`_route.dart`), and Widgets (`_widgets.dart`).

### 2. Key Libraries & Conventions
- **State Management:** `flutter_bloc` (v9.1.1) with `equatable` for value comparison.
- **Dependency Injection:** `get_it` (service locator managed in `lib/core/services/service_locator.dart`). Register new data sources, repos, use cases, and BLoCs here.
- **Networking:** `dio` (v5.9.0) managed via `DioNetworkHelper` in `lib/core/network/`. Wrap async repository results with `dartz` (`Either<Failure, T>`).
- **Routing:** `go_router` (v17.0.0) with modular route definitions inside each module's `presentation/routes/` folder.
- **Localization:** `easy_localization` (v3.0.8). Translations are stored at `resources/langs/ar-SY.json` and `resources/langs/en-US.json`. Generated keys are in `lib/generated/locale_keys.g.dart`.
- **Styling & Assets:**
  - Colors: `AppColors` (`lib/core/constants/app_colors.dart`)
  - Typography/Fonts: `AppFonts` (`Kanit`, `Almarai`, `ReadexPro`)
  - Screen Sizing: `responsive_sizer` (`ResponsiveSizer`)
  - Icons: `lucide_icons_flutter` and `cupertino_icons`

## Development Rules
1. **Never break existing patterns:** Inspect neighboring modules (e.g., `modules/auth/` or `modules/student/procedures/`) before creating new files to mirror existing code style.
2. **Localization first:** Do not hardcode strings in UI widgets. Always use `LocaleKeys.<key>.tr()`.
3. **Immutability:** Use `Equatable` for entities, parameters, models, and BLoC states/events.
4. **Validation:** Run `flutter analyze` after creating or modifying files to fix lint issues immediately.