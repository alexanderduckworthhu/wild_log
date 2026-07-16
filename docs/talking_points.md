# Interview talking points (90 seconds)

1. **Why:** Private expedition log for outdoor life — not a social calorie tracker. Offline SQLite owns the data.
2. **Architecture:** Riverpod wires Drift → reactive sessions → derived Summit stats. UI does not own analytics math.
3. **Model:** Shared metrics (elevation, distance, lat/lng) plus activity-specific JSON (snow, range distance, grade).
4. **Maps & charts:** flutter_map + OSM waypoints; fl_chart sessions-by-type — no paid map SDK.
5. **Craft:** Design tokens + `AppStrings` for localization readiness; muted alpine kit, not stock Material.
6. **Judgment:** Streaks motivate consistency without leaderboards. Demo seed makes Summit/Map interview-ready.
