# Balligh App - Living Project Map (balligh_map.md)

## 1. Project Overview & Architecture

**Pattern:** MVC-inspired, called "Controller + View" in code comments. No services/ layer exists yet. The "Controller" role is played by ChangeNotifier-based Provider classes. No models/ ↔ services/ ↔ providers/ ↔ views/ clean architecture — services are stubbed with inline mock data inside providers.

**Dependency Stack:**

| Concern | Library | Version |
|---------|---------|---------|
| State | provider | ^6.1.2 |
| Map | flutter_map + latlong2 | ^7.0.2 / ^0.9.1 |
| Tile Cache | flutter_map_tile_caching | ^10.0.0 |
| i18n | flutter_localizations + intl | SDK / ^0.20.2 |
| HTTP | http | ^1.2.0 (declared, never used) |
| Fonts | google_fonts | ^8.1.0 (Cairo typeface) |
| Persistence | shared_preferences | ^2.3.2 |

**Boot Sequence (main.dart:32-68):**
1. WidgetsFlutterBinding.ensureInitialized()
2. Lock portrait orientation
3. Set transparent status bar
4. await FMTCObjectBoxBackend().initialise() — FMTC tile cache init (mandatory before first map paint)
5. await FMTCStore('osm_cache').manage.create() — create the named store
6. runApp(MultiProvider(providers: [...], child: BalighApp()))

**Routing:** Two-tier navigation:
- **Persistent shell:** MainLayout with IndexedStack (4 tab bodies) + BottomAppBar + center FAB. Tab switching via NavigationProvider (enum AppTab). All tabs alive simultaneously (no rebuilds on switch).
- **Push routes:** Standard Navigator.push(context, MaterialPageRoute(...)). Currently only one push route: AddReportView from the FAB. No named routes, no Navigator 2.0, no GoRouter.

**Theme:** Centralized in AppTheme class within main.dart:269-508. Light + dark with Material 3, Cairo Google Fonts, brand green (#2E7D32) + yellow (#FDD835). Everything defined here (AppBar, BottomNavBar, Buttons, Inputs, Cards, Chips, FAB, Divider, Typography). ThemeProvider persists selection via SharedPreferences (key `app_theme`).

## 2. Directory & Module Relationships
lib/
├── main.dart # Entry, root providers, theme definitions, dev PlaceholderHome (unused)
├── l10n/
│ ├── app_localizations.dart # Abstract base + delegate (generated-style, manually written)
│ ├── app_localizations_ar.dart # Arabic impl
│ ├── app_localizations_fr.dart # French impl
│ ├── app_ar.arb # Arabic source strings (270 lines, 58 keys)
│ └── app_fr.arb # French source strings (270 lines, 58 keys)
├── models/
│ └── report_model.dart # ReportModel + ReportLocation + CredibilityScore + enums
├── providers/ # Controllers — ChangeNotifier classes
│ ├── navigation_provider.dart # Tab index state (global)
│ ├── locale_provider.dart # Locale + persistence (global)
│ ├── theme_provider.dart # ThemeMode + persistence (global)
│ ├── report_provider.dart # Report list CRUD + filtering + mock API (global)
│ ├── map_provider.dart # Map camera, filters, selection, markers (scoped to MapView tab)
│ └── add_report_provider.dart # Wizard state: category, description, location, photo (scoped to AddReportView route)
├── views/
│ ├── main_layout.dart # App shell — BottomAppBar + IndexedStack + FAB
│ ├── home/home_view.dart # Home feed — SliverAppBar, stats bar, filter chips, report list
│ ├── map/map_view.dart # Map tab — flutter_map, search, filter chips, markers, preview sheet
│ ├── add_report/add_report_view.dart # Multi-step wizard (Steps 1–4 done; Step 3 photo is placeholder UI only)
│ ├── my_reports/my_reports_view.dart # Placeholder
│ ├── alerts/alerts_view.dart # Placeholder
│ └── account/account_view.dart # Placeholder
└── widgets/
└── report_card.dart # Shared card: category icon, status chip, elapsed time, location, credibility badge


**"Glue" files:**
- `main.dart` wires providers → BalighApp (MaterialApp) → MainLayout
- `main_layout.dart` wires NavigationProvider → IndexedStack + BottomNavigationBar + FAB → push to AddReportView
- `report_provider.dart` is consumed by HomeView, MapView; also the target for AddReportProvider.buildDraft() submission
- `map_provider.dart` scoped inside MapView; receives reportProvider.allReports to compute filteredReports
- `report_card.dart` shared by HomeView (list items) and MapView (preview sheet)

## 3. State Management Paradigm

**Primary solution:** Provider + ChangeNotifier. No Riverpod, no Bloc.

**Global providers (registered in MultiProvider at main.dart:59-67):**

| Provider | Role | Notifies On |
|----------|------|-------------|
| LocaleProvider | Current locale, persisted | setLocale() |
| ThemeProvider | ThemeMode, persisted | setThemeMode() |
| ReportProvider | List<ReportModel>, status, filters, credibility votes | fetch, add, update, filter, clearFilter |
| NavigationProvider | AppTab enum (current tab) | navigateTo() |

**Scoped providers:**

| Provider | Scope | Created At |
|----------|-------|-------------|
| MapProvider | MapView tab (kept alive by AutomaticKeepAliveClientMixin) | ChangeNotifierProvider(create: (_) => MapProvider()) inside MapView.build() |
| AddReportProvider | AddReportView route lifecycle | ChangeNotifierProvider(create: (_) => AddReportProvider()) inside AddReportView.build() |

**Data flow (typical):**
View (context.watch/Consumer/Selector)
→ reads Provider getters
→ user action calls Provider method
→ Provider mutates private state
→ Provider.notifyListeners()
→ View rebuilds affected widgets



**Bad practices detected:**

1. **context.watch at top of build causing unnecessary subtree rebuilds:** BalighApp.build() (main.dart:82-83) watches both LocaleProvider and ThemeProvider, causing the entire MaterialApp to rebuild on locale or theme change. This is acceptable since MaterialApp must rebuild for those, but still worth noting.

2. ~~**MainLayout.build()** watches NavigationProvider at the top level~~ ✅ **Fixed** — replaced with two `Selector<NavigationProvider, int>` wrappers. The Scaffold shell + BottomAppBar never rebuild from provider notifications; only the `IndexedStack` and `_BalighBottomNav` react to `currentIndex` changes.

3. **Good practice:** HomeView uses `Selector<ReportProvider, (int, int, int)>` at home_view.dart:64-78 to extract only counts for the stats bar, and `Selector<ReportProvider, ReportCategory?>` at line 88-98 for the filter bar, avoiding full-list rebuilds. The list body uses `Consumer<ReportProvider>` at line 104 which is appropriate since it needs to react to all state transitions.

4. **MapView anti-pattern:** Uses `Consumer2<ReportProvider, MapProvider>` at map_view.dart:111 which wraps the entire Scaffold including all children. Every filter change, search keystroke, or report selection rebuilds the entire map + search bar + chips + location button + preview sheet. Should use narrower Selector/Consumer wrappers per widget, especially since only the MarkerLayer content changes on most interactions.

5. **_CategoryGrid in add_report_view.dart:303** uses `context.watch<AddReportProvider>()` which rebuilds all 6 grid tiles on every provider change. Fine for step transitions, but when the description field updates (via the listener in _DescriptionField), the grid does NOT rebuild because setDescription intentionally skips `notifyListeners()`. This is a deliberate optimization but fragile — if another method is added that calls `notifyListeners()` unrelated to category, the grid unnecessarily rebuilds.

6. **_BottomActionBar in add_report_view.dart:604** uses `context.watch<AddReportProvider>()` which rebuilds the entire bottom bar on every provider change, including irrelevant description updates. Minor impact due to small widget tree.

## 4. Current Feature Status (The "Done" List)

### Fully Functional

| Screen/Feature | Status | Details |
|----------------|--------|---------|
| App boot + init | ✅ | FMTC init, portrait lock, MultiProvider wiring |
| i18n (Arabic/French) | ✅ | 58 keys in both languages. LocaleProvider persists choice. RTL auto-resolved. |
| Theme (light/dark/system) | ✅ | Full Material 3 light + dark. Persisted. |
| Bottom Navigation Shell | ✅ | MainLayout with IndexedStack (4 tabs), BottomAppBar with notch for FAB, animated nav items |
| FAB + entrance animation | ✅ | Pulsing scale animation on first build, press-scale animation on tap. Pushes AddReportView. |
| HomeView — SliverAppBar | ✅ | Parallax gradient header (expanded 120, collapsed 56), pinned, notification icon |
| HomeView — Stats Bar | ✅ | 3 pills (total, pending, resolved) with Selector optimization |
| HomeView — Category Filter Chips | ✅ | Horizontal scrollable, selects into ReportProvider |
| HomeView — Report List | ✅ | Staggered fade+slide animation, loading skeleton (4 shimmer cards), error state with retry, empty state |
| MapView — OSM Tiles | ✅ | FMTC-cached tile layer, cache-first strategy, 30-day validity, max zoom 19 |
| MapView — Markers | ✅ | Category-coloured circles with icons, selected state (larger, thicker border, glow shadow) |
| MapView — Search Bar | ✅ | Floating glass-morphism, filters by description/address, result count pill, clear button |
| MapView — Category Filter Chips | ✅ | Floating below search bar, coloured chips with icons |
| MapView — Preview Sheet | ✅ | Slide-up animation, report card, confirm/reject vote buttons (UI only, not wired) |
| MapView — Location Button | ✅ | Bottom-right, reset camera + clear filters when active |
| AddReport — Step 1 (Category) | ✅ | 6-category 3x2 grid with animated tiles, selection state with colour, deselection on re-tap |
| AddReport — Step 1 (Description) | ✅ | Multi-line TextField, 280-char limit with custom counter, near-limit warning |
| AddReport — Step 1 (Validation) | ✅ | Error banner when no category selected, form discard confirmation dialog |
| AddReport — Step Progress Bar | ✅ | 4-segment animated bar in AppBar |
| AddReport — Step 2 (Location Map) | ✅ | Full OSM map with FMTC cache, fixed center pin, instruction banner, confirm button |
| ReportCard widget | ✅ | Shared across HomeView and MapView. Category icon, status pill, elapsed time, description (2 lines), location, credibility badge. Entrance animation (staggered fade+slide). |

### Partially Functional / Placeholder

| Screen/Feature | Status | Details |
|----------------|--------|---------|
| MyReportsView | ⚠️ Placeholder | Icon + title, no data, no filters, no report list |
| AlertsView | ⚠️ Placeholder | Icon + title only |
| AccountView | ⚠️ Placeholder | Icon + title only |
| AddReport Step 3 (Photo) | ⚠️ Placeholder UI | Camera icon + disabled "Add Photo" button. "Continue" skips to review. No camera/image_picker logic. |
| AddReport Step 4 (Review) | ✅ | Read-only summary (category, description, location). Submit wired to `buildDraft()` → `ReportProvider.addReport()`. Loading spinner + SnackBar on success/failure. |
| AddReport submission | ✅ | `buildDraft()` called in `_Step4ReviewBodyState._submit()`. Optimistic insert via `ReportProvider.addReport()`. Navigator.pop + success SnackBar on completion. |
| Map vote buttons | ❌ Not wired | `onTap` has // TODO comments |
| ReportCard onTap | ❌ Not wired | Both HomeView and MapView have `// TODO: Navigator.push to ReportDetailView` |
| Report Detail View | ❌ Not built | No detail screen exists |
| Settings Screen | ❌ Not built | 22 localized keys exist, no UI |
| Geolocation | ❌ Not built | `goToMyLocation` is a stub; location package not in pubspec |
| Camera / Photo | ❌ Not built | No `image_picker` dependency |
| API / Backend | ❌ Mock only | All data in `_buildMockReports()`; http package unused |

## 5. The Map Implementation Status

**Library:** `flutter_map ^7.0.2` with `flutter_map_tile_caching ^10.0.0` (OSM — no API key needed).

**Tile fetching & caching:**
- Both map instances (`MapView._BalighMap` at map_view.dart:189-221 and `AddReportView._LocationPickerBody` at add_report_view.dart:974-996) use identical FMTC configuration:
  - Store name: `'osm_cache'`
  - `BrowseLoadingStrategy.cacheFirst` — tiles served from cache if available, fallback to network
  - `cachedValidDuration: Duration(days: 30)` — tile re-fetch interval
  - `urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'`
  - `maxNativeZoom: 19`
  - `userAgentPackageName: 'com.baligh.app'`
- FMTC initialization happens at app boot (main.dart:53-54) before runApp.
- Error callback: `errorTileCallback` prints to debug console for the `_BalighMap` instance; missing on the `_LocationPickerBody` map.

**Markers (map_view.dart:53-100):**
- Built in `_buildMarkers()` method — iterates over visibleReports, creates Marker widgets for each
- Marker sizing: 38×38 normal, 48×48 selected
- Category colour via `MapProvider.markerColor()` — matches category enum
- Icon via `MapProvider.markerIcon()` — per category
- Gesture: tap selects the report (`MapProvider.selectReport`) + animates camera to location (`MapProvider.focusOn`)
- Centered on Nouakchott, Mauritania (`LatLng(18.0735, -15.9582)`) at zoom 13

**Map ↔ Add Report interaction:**
- The `AddReportView` has its own `FlutterMap` instance in Step 2 (`_LocationPickerBody`), completely separate from the `MapView` tab map
- Step 2 uses a fixed center pin approach: user drags the map, pin stays centered, `onPositionChanged` captures the center LatLng, `_confirmLocation` writes `ReportLocation` to `AddReportProvider.setLocation()` and advances to Step 3
- No shared map state between the two — each manages its own `MapController`

**Performance concerns:**
- `Consumer2<ReportProvider, MapProvider>` in MapView rebuilds ALL markers + ALL overlay widgets on every provider change. For 100+ reports this creates 100+ Marker widgets per rebuild. Recommendation: split into Selector per overlay widget; use MarkerLayer with a memoized marker list.
- Two separate FMTC store configurations with duplicated strings — if you change store name in one place, the other breaks silently.
- The `_buildMarkers()` method creates new Marker objects on every rebuild — no const or caching.

**Known map issues:**
- "My Location" button (`_LocationButton`) calls `mapProvider.resetCamera()` instead of actual device GPS — no geolocation package (geolocator, location) in pubspec
- Voting buttons in preview sheet are UI-only — `// TODO: wire to reportProvider.updateCredibility`
- `_LocationPickerBody` does NOT have an `errorTileCallback` on its TileLayer

## 6. Known Bugs, Tech Debt & "Heavy" Code

### Bugs

| # | File:Line | Severity | Issue |
|---|-----------|----------|-------|
| 1 | report_card.dart:314-326 | Medium | `_ElapsedTime._format()` returns hardcoded Arabic/French strings ('منذ $m دقيقة', 'il y a $m min'). These should be localized ARB keys with ICU/Intl plural messages, not inline conditionals. If a new locale is added (e.g., English), the hardcoded check `isAr ? ... : ...` breaks. |
| 2 | map_provider.dart:120 vs report_card.dart:511 | Low | Category colour inconsistency: lighting is `Color(0xFFF9A825)` in MapProvider but `Color(0xFFFDD835)` in `_CategoryMeta`. Different yellow shades for the same category. |
| 3 | add_report_view.dart:228-238 | Low | `Consumer<AddReportProvider>` wrapping AnimatedSize for error banner — the consumer scope is correct but the error banner only depends on `showCategoryError`; unrelated provider changes (step transitions) also rebuild the error banner. Minor issue. |
| 4 | main_layout.dart:71-85 | Low | Dead code: `_onFabTapped` method exists but is never called — the actual FAB uses inline `Navigator.push(context, MaterialPageRoute(builder: (_) => const AddReportView()))` at line 112. Remove dead method. |
| 5 | ~~add_report_view.dart:884~~ | ~~Critical~~ ✅ **Fixed** | **mouse_tracker + Scaffold.geometryOf dual crash** — `_LocationPickerBodyState._onPositionChanged` called `setState(() => _pickedPoint = camera.center)` on every drag frame (60–120×/sec). `setState` during pointer dispatch caused `_debugDuringDeviceUpdate` assertion spam (`mouse_tracker.dart`). The same rebuild flood propagated to `MainLayout`'s Scaffold during layout phase, causing `_BottomAppBarClipper.getClip` to access `ScaffoldGeometry` while `debugDoingPaint` was false → `Scaffold.geometryOf() must only be accessed during the paint phase`. **Fix 1 (primary):** bare field assignment `_pickedPoint = camera.center` — zero rebuilds during drag. **Fix 2 (structural):** `_MainLayoutState.build()` replaced `context.watch<NavigationProvider>()` with two `Selector<NavigationProvider, int>` wrappers (one for IndexedStack, one for BottomNav). The Scaffold shell + BottomAppBar + notch clipper now NEVER rebuild from provider notifications — only the two interior widgets that consume `currentIndex` do. |
| 6 | ~~add_report_view.dart:1149~~ | ~~Critical~~ ✅ **Fixed** | **Scaffold.geometryOf() crash + zombie UI on submission** — Confirmed by debugPrint instrumentation. `_submit()` itself ran to completion cleanly. The crash fired as a *scheduler callback* on the next frame, in `MouseTracker.updateAllDevices` → `_BottomAppBarClipper.getClip()` → `ScaffoldGeometryNotifier.value` → assertion `debugDoingPaint == true` fails. Root cause: `ReportProvider._setStatus(idle)` fires `notifyListeners()` (marks HomeView dirty) in the same microtask as `navigator.pop()` is called. Frame N therefore had two competing jobs: flush the pending HomeView rebuild AND start the route exit animation. `RendererBinding._scheduleMouseTrackerUpdate` fired during that frame's scheduler callbacks; the hit-test reached `_BottomAppBarClipper.getClip()` before the Scaffold had completed layout+paint, so `ScaffoldGeometry` was stale → assertion crash. The discard-path `navigator.pop()` never crashes because no `notifyListeners()` is pending when it fires. **Fix:** `WidgetsBinding.instance.addPostFrameCallback` defers SnackBar + pop to frame N+1. Frame N flushes all pending rebuilds and repaints the Scaffold (setting valid geometry). Frame N+1's pop fires into a fully-painted scaffold; mouse tracker hit-test finds a valid `ScaffoldGeometry` → no crash. SnackBar is shown before `navigator.pop()` inside the callback (standard Flutter ordering). |

### Tech Debt

| # | Item | Priority | Details |
|---|------|----------|---------|
| 1 | No API service layer | High | ReportProvider contains mock data + mock delays inline (`_buildMockReports()`, `Future.delayed`). Any real backend integration requires rewriting the entire provider. Must extract a ReportService interface. |
| 2 | No error handling for FMTC init | Medium | main.dart:53-54 has no try/catch — if `FMTCObjectBoxBackend().initialise()` throws (e.g., corrupted DB), the app crashes at boot with no user feedback. |
| 3 | Unused localization keys | Low | `navMap`, `navReport`, `navSettings`, `homeQuickReport`, `homeViewMap`, `reportValidationDescription`, `reportPhoto`, `reportAddPhoto`, `reportChangePhoto`, `reportSubmit`, `reportSubmitSuccess`, `reportSubmitError`, `reportDetailTitle`, `reportDetailDate`, `reportDetailStatus`, `reportDetailCategory`, `reportDetailDescription`, `reportDetailLocation`, `settingsTitle`, `settingsLanguage`, `settingsNotifications`, `settingsNotificationsSubtitle`, `settingsAbout`, `settingsVersion`, `settingsPrivacy`, `settingsContact`, `settingsTheme`, `settingsThemeLight`, `settingsThemeDark`, `settingsThemeSystem`, `permissionLocationTitle`, `permissionLocationMessage`, `permissionLocationGrant`, `permissionLocationDeny`, `reportCount` — many keys defined but no UI uses them. |
| 4 | Duplicate FMTC store config strings | Low | `'osm_cache'` hardcoded in 3 files (main.dart:54, map_view.dart:204, add_report_view.dart:989). Extract to a constant or singleton. |
| 5 | http package declared but unused | Low | In pubspec.yaml, no usage in code. Should be removed or a stub service created. |
| 6 | MapProvider not registered as global | Medium | Created per MapView via `ChangeNotifierProvider(create:)`. This means if a push route (e.g., future ReportDetailView) needs map state, it can't access it. |
| 7 | description field isolation | Low | `setDescription` intentionally skips `notifyListeners()`. Works because only the TextField and submit action read it. But if future features need to react to description state, this breaks silently. |
| 8 | Missing const constructors in marker list | Low | `_buildMarkers()` creates new Marker objects every time — no key optimization. Could memoize by report ID. |
| 9 | README is generic | Low | Default Flutter template — no project-specific setup instructions. |

### Heavy / Slow Code

| # | File:Line | Severity | Issue |
|---|-----------|----------|-------|
| 1 | map_view.dart:111-173 | High | `Consumer2<ReportProvider, MapProvider>` rebuilding entire map Scaffold (search bar, chips, markers, location button, preview sheet) on every state change in either provider. For example, a search keystroke triggers `notifyListeners` via `setSearchQuery` → rebuilds ALL markers. |
| 2 | home_view.dart:104-129 | Medium | `Consumer<ReportProvider>` wraps the entire list section — every time ReportProvider notifies (including credibility vote updates), it rebuilds the Consumer builder which re-evaluates all control flow conditions. Could be split into narrower consumers. |
| 3 | add_report_view.dart:604 | Low | `_BottomActionBar` uses `context.watch` on the full provider when only `currentStepIndex` and `hasCategory` matter. |

## 7. Unfinished Parts & Immediate Next Steps

### Must-Fix Before Production

1. ~~**Wire AddReportProvider.buildDraft() → ReportProvider.addReport()**~~ ✅ Done — `_Step4ReviewBody` submits the draft, handles loading and SnackBar feedback, and pops the route on success.

2. **Wire map vote buttons** — `_ReportPreviewSheet` at map_view.dart:688-703 has `// TODO` for `reportProvider.updateCredibility`. Without this, the credibility feature is a UI mirage.

3. **Add report detail view** — Both `HomeView._ReportList` (home_view.dart:475) and `MapView._ReportPreviewSheet` (map_view.dart:672-673) have `// TODO: Navigator.push to ReportDetailView`. Users can see reports but not open them.

4. **Replace _ElapsedTime hardcoded strings** with proper localized plural messages via ARB (e.g., `timeAgoMinutes`, `timeAgoHours`, `timeAgoDays` with ICU plural rules).

5. **Remove dead code** `_onFabTapped` in main_layout.dart:71-85.

### Strongly Recommended

6. **Add geolocation** — Add `geolocator` or `location` package. Wire `MapProvider.goToMyLocation()` to actual device location. Add platform permissions handling for Android/iOS.

7. **Extract ReportService** — Create `lib/services/report_service.dart` with an abstract interface and at minimum a `MockReportService` that replaces the inline mock data in `ReportProvider`. This makes the real API integration a drop-in replacement.

8. **Build remaining tab views:** MyReportsView (report list filtered by submittedBy), AlertsView (push notifications or status updates), AccountView (profile, settings link, theme/locale controls).

9. **Consolidate duplicate category metadata** — map_provider.dart:120-136, report_card.dart:509-518, add_report_view.dart:279-286 all define the same category→icon→color mappings. Extract to a single source of truth (e.g., `ReportCategoryMeta` in the model or a dedicated utils/ file).

10. **Add try/catch around FMTC init** at main.dart:53-54.

### Polish / Nice-to-Have

11. Implement AddReport Steps 3 (photo via `image_picker`) and 4 (review + submit).

12. Build Settings screen (theme toggle, locale selector, about, version).

13. Replace Consumer2 in MapView with granular Selector per overlay widget, possibly memoizing the marker list.

14. Add `errorTileCallback` to `_LocationPickerBody` TileLayer.

15. Remove unused localization keys and unused http dependency.
