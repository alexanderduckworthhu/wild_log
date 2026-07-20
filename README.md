# Wild Log

An offline personal expedition log for outdoor athletes who want session history, map memory, and consistency metrics without a social fitness feed.

## Why it exists

Most trail apps optimize for sharing and monetized coaching. Wild Log solves a narrower problem: keep a private, structured record of hikes, climbs, snowboard days, camps, range sessions, hunts, and water days, with activity-specific fields, and surface honest streaks and personal records on device. Existing tools either flatten every activity into “workout” fields or require an account and cloud sync before the first entry is useful.

## Technical decisions

- **Flutter + Riverpod**. Chosen for a single codebase that can demo on iOS Simulator and for an explicit provider graph (`AppDatabase` → repository → session stream → derived Summit stats). Considered Bloc (more ceremony for one user + offline) and setState-only (poor cross-screen reactivity).
- **Drift (SQLite) over Hive**. Chosen because Summit needs ordered history, type counts, and elevation/distance aggregates. Hive fits key-value prefs; relational queries fit an expedition log.
- **flutter_map + OpenStreetMap tiles**. Chosen to pin waypoints without a Google Maps billing account. Trade-off: must respect OSM tile usage policy; demo seeds a small pin set.
- **Shared columns + `detailsJson`**. Chosen so elevation/distance stay queryable while snow conditions, range distance, and route grade stay type-native without a nullable-column explosion.
- **Single `AppStrings` + `WildColors` / `WildSpace` tokens**. Chosen so French localization and design-system discipline are additive for Geneva/Neuchâtel audiences, without scattering hex and copy through widgets.

## Results & metrics

- **8** seeded demo sessions across **7** activity types on first launch (Pacific Northwest–flavored fixtures).
- **3** primary tabs + **1** write flow; Summit quick-log opens the form with activity preselected (**1** tap to start logging).
- Domain streak/records logic covered by unit test (`flutter test`); analyzer clean on the `lib/` tree.
- Offline-first: all reads/writes hit local SQLite; no network required except OSM map tiles when viewing Map.

## Setup & usage

```bash
# Requires Flutter 3.38+ and Xcode (for iOS Simulator)
cd wild_log
flutter pub get

# Only after editing Drift tables:
dart run build_runner build --delete-conflicting-outputs

# Prefer a path outside iCloud Desktop, codesign fails when Finder/File Provider
# xattrs attach to build products under ~/Desktop.
# If your Portfolio folder syncs via iCloud, copy or rsync to ~/wild_log first:
#   rsync -a --exclude build --exclude .dart_tool --exclude ios/Pods \
#     ~/Desktop/Portfolio/wild_log/ ~/wild_log/
#   cd ~/wild_log

flutter devices
flutter run -d <ios-simulator-id>
```

Hot reload after UI edits; full restart after Drift schema changes.

## Data

| Item | Detail |
| --- | --- |
| **Source** | User-entered sessions + optional demo seed on empty DB |
| **Storage** | Local SQLite via Drift (`wild_log` database name) |
| **PII** | Location names, coordinates, free-text notes stay on device |
| **License of tiles** | OpenStreetMap, follow [tile usage policy](https://operations.osmfoundation.org/policies/tiles) |
| **Production gap** | Add export/backup, optional encrypted-at-rest, and explicit consent copy before any cloud sync |

No third-party analytics. No account system. Suitable as a portfolio demo; not a production medical or regulated logging product.

## What I'd improve next

1. **GPX / HealthKit import**. Reduce manual lat/lng entry by importing a track and deriving distance/elevation.
2. **Encrypted export bundle**. JSON/ZIP export with optional passphrase for backup without full cloud sync.
3. **French locale (`fr_CH`)**. Wire `AppStrings` through `flutter_localizations` / ARB for Geneva interviews.

## Architecture

```
lib/
  core/           theme tokens, spacing, l10n strings, constants, errors
  domain/         ActivityType, AdventureSession, DashboardStats
  data/           Drift schema, repository
  providers/      Riverpod graph
  features/       shell, dashboard (Summit), logbook, map, session
```

Sibling folders under `Portfolio/` are independent; do not mix dependencies with them.

## License

Portfolio / personal use.
