# Balligh App - Living Project Map (balligh_map.md)

## 1. Project Overview & Architecture

**Pattern:** MVC-inspired with services/ and core/ layers. Service layer abstracts data access (abstract `ReportService` interface). Core/ layer provides Supabase-backed database, DAOs, and service implementations. "Controller" role is played by ChangeNotifier-based Provider classes that consume services/DAOs.

**Dependency Stack:**

| Concern | Library | Version |
|---------|---------|---------|
| State | provider | ^6.1.2 |
| Map | flutter_map + latlong2 | ^7.0.2 / ^0.9.1 |
| Tile Cache | flutter_map_tile_caching | ^10.0.0 |
| i18n | flutter_localizations + intl | SDK / ^0.20.2 |
| Fonts | google_fonts | ^8.1.0 (Cairo typeface) |
| Persistence | shared_preferences | ^2.3.2 |
| Backend | supabase_flutter | ^2.8.3 |

**Boot Sequence (main.dart):**
1. WidgetsFlutterBinding.ensureInitialized()
2. Lock portrait orientation
3. Set transparent status bar
4. await FMTCObjectBoxBackend().initialise() — FMTC tile cache init (mandatory before first map paint)
5. await FMTCStore('osm_cache').manage.create() — create the named store
6. await Supabase.initialize() — Supabase client init with URL + anon key
7. runApp(MultiProvider(providers: [...], child: BalighApp()))

**Routing:** Two-tier navigation:
- **Persistent shell:** MainLayout with IndexedStack (4 tab bodies) + BottomAppBar + center FAB. Tab switching via NavigationProvider (enum AppTab). All tabs alive simultaneously (no rebuilds on switch).
- **Push routes:** Standard Navigator.push(context, MaterialPageRoute(...)). Currently only one push route: AddReportView from the FAB. No named routes, no Navigator 2.0, no GoRouter.

**Theme:** Centralized in AppTheme class within main.dart:269-508. Light + dark with Material 3, Cairo Google Fonts, brand green (#2E7D32) + yellow (#FDD835). Everything defined here (AppBar, BottomNavBar, Buttons, Inputs, Cards, Chips, FAB, Divider, Typography). ThemeProvider persists selection via SharedPreferences (key `app_theme`).

## 2. Directory & Module Relationships
lib/
├── main.dart # Entry, root providers, theme definitions, SplashView as home
├── core/
│ ├── database/
│ │ ├── user_dao.dart # Supabase-backed User CRUD + findByUsername/Email
│ │ ├── report_dao.dart # Supabase-backed Report CRUD + filter by category/status + getByUserId + getNearby
│ │ ├── vote_dao.dart # Supabase-backed Vote CRUD + getVote + vote counts + hasVoted
│ │ └── notification_dao.dart # Supabase-backed Notification CRUD + unread count + markAllRead
│ ├── models/
│ │ ├── user_model.dart # UserModel with reputation badge logic (String UUID id, no passwordHash)
│ │ ├── vote_model.dart # VoteModel (confirm/deny enum, String userId)
│ │ └── notification_model.dart # NotificationModel with isRead flag (String userId)
│ └── services/
│ ├── auth_service.dart # Supabase Auth: email+password signUp/signIn, auto session mgmt
│ ├── report_service_db.dart # Supabase-backed ReportService implementation
│ ├── notification_service.dart # Creates notifications for ALL users when a report is submitted
│ └── location_service.dart # Haversine distance calculation (currently unused)
├── l10n/
│ ├── app_localizations.dart # Abstract base + delegate (90+ keys, 12 categories)
│ ├── app_localizations_ar.dart # Arabic impl (12 categories)
│ ├── app_localizations_fr.dart # French impl (12 categories)
│ ├── app_ar.arb # Arabic source strings
│ └── app_fr.arb # French source strings
├── models/
│ └── report_model.dart # ReportModel + 12 categories + 3 statuses + SQLite fields (userId, confirmCount, denyCount)
├── services/
│ └── report_service.dart # Abstract ReportService interface (used by providers, implemented by ReportServiceDb)
├── providers/ # Controllers — ChangeNotifier classes
│ ├── navigation_provider.dart # Tab index state (global)
│ ├── locale_provider.dart # Locale + persistence (global)
│ ├── theme_provider.dart # ThemeMode + persistence (global)
│ ├── auth_provider.dart # Current user, register/login/logout, session persistence (global)
│ ├── report_provider.dart # Report CRUD + filtering via ReportServiceDb (global)
│ ├── map_provider.dart # Map camera, filters, selection, markers (scoped to MapView tab)
│ ├── add_report_provider.dart # Wizard state: category, description, location, photo (scoped to AddReportView route)
│ └── alert_provider.dart # DB-backed alerts via NotificationDao (global)
├── views/
│ ├── main_layout.dart # App shell — BottomAppBar + IndexedStack + FAB
│ ├── splash/splash_view.dart # Animated splash — Start/Skip → MainLayout
│ ├── home/home_view.dart # Home feed — SliverAppBar, stats bar, filter chips, report list
│ ├── map/map_view.dart # Map tab — flutter_map, search, filter chips, markers, preview sheet
│ ├── add_report/add_report_view.dart # Multi-step wizard (Steps 1–4 done; Step 3 photo is placeholder UI only)
│ ├── my_reports/my_reports_view.dart # Full list + status filter bottom sheet
│ ├── alerts/alerts_view.dart # Full notification list from AlertProvider
│ ├── account/account_view.dart # Profile header, stats, menu → Settings/Emergency
│ ├── settings/settings_view.dart # Theme toggle, language, about, privacy/contact
│ ├── report_detail/report_detail_view.dart # Full report + credibility bar + confirm/reject votes
│ └── emergency/emergency_numbers_view.dart # Emergency contact tiles with call buttons
└── widgets/
    ├── report_card.dart # Shared card: category icon, status chip, elapsed time, location, credibility badge
    └── empty_state.dart # Shared empty-state widget


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
| AlertProvider | List<AppAlert>, unread count, DB-backed via NotificationDao | fetchAlerts, markAsRead, markAllAsRead, refresh |
| AuthProvider | Current user, register/login/logout, session persistence | tryAutoLogin, register, login, logout |

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

5. **_CategoryGrid in add_report_view.dart:292** uses `context.watch<AddReportProvider>()` which rebuilds all 12 grid tiles on every provider change. Fine for step transitions, but when the description field updates (via the listener in _DescriptionField), the grid does NOT rebuild because setDescription intentionally skips `notifyListeners()`. This is a deliberate optimization but fragile — if another method is added that calls `notifyListeners()` unrelated to category, the grid unnecessarily rebuilds.

6. **_BottomActionBar in add_report_view.dart:604** uses `context.watch<AddReportProvider>()` which rebuilds the entire bottom bar on every provider change, including irrelevant description updates. Minor impact due to small widget tree.

## 4. Current Feature Status (The "Done" List)

### Fully Functional

| Screen/Feature | Status | Details |
|----------------|--------|---------|
| App boot + init | ✅ | FMTC init, DB init, portrait lock, MultiProvider wiring |
| i18n (Arabic/French) | ✅ | 90+ keys in both languages. 12 categories with Arabic/French labels. 3 new statuses. LocaleProvider persists choice. RTL auto-resolved. **Locale switch fix:** MaterialApp has `key: ValueKey(localeProvider.locale.languageCode)` to force full tree rebuild on locale change. `MainLayout._tabBodies` changed from `static const` to getter creating fresh instances. |
| Theme (light/dark/system) | ✅ | Full Material 3 light + dark. Persisted. |
| Bottom Navigation Shell | ✅ | MainLayout with IndexedStack (4 tabs), BottomAppBar with notch for FAB, animated nav items |
| FAB + entrance animation | ✅ | Pulsing scale animation on first build, press-scale animation on tap. Pushes AddReportView. |
| HomeView — SliverAppBar | ✅ | Gradient header (expanded 120, collapsed 56), pinned. Complex content in `background` (SafeArea + Row: title, subtitle, notification icon), simple `title` for collapsed state. No overflow. |
| HomeView — Stats Bar | ✅ | 3 pills (total, pending, validated) with Selector optimization |
| HomeView — Category Filter Chips | ✅ | Horizontal scrollable, dynamically from ReportCategory.values (12 categories), selects into ReportProvider |
| HomeView — Report List | ✅ | Staggered fade+slide animation, loading skeleton (4 shimmer cards), error state with retry, empty state |
| MapView — OSM Tiles | ✅ | FMTC-cached tile layer, cache-first strategy, 30-day validity, max zoom 19 |
| MapView — Markers | ✅ | Category-coloured circles with icons, selected state (larger, thicker border, glow shadow) |
| MapView — Search Bar | ✅ | Floating glass-morphism, filters by description/address, result count pill, clear button |
| MapView — Category Filter Chips | ✅ | Floating below search bar, dynamic from ReportCategory.values (12 categories), coloured chips with icons |
| MapView — Preview Sheet | ✅ | Slide-up animation, report card, confirm/reject vote buttons (UI only, not wired) |
| MapView — Location Button | ✅ | Bottom-right, reset camera + clear filters when active |
| AddReport — Step 1 (Category) | ✅ | 12-category 3x? grid with animated tiles, selection state with colour, deselection on re-tap |
| AddReport — Step 1 (Description) | ✅ | Multi-line TextField, 280-char limit with custom counter, near-limit warning |
| AddReport — Step 1 (Validation) | ✅ | Error banner when no category selected, form discard confirmation dialog |
| AddReport — Step Progress Bar | ✅ | 4-segment animated bar in AppBar |
| AddReport — Step 2 (Location Map) | ✅ | Full OSM map with FMTC cache, fixed center pin, instruction banner, confirm button. Auto-centers on user GPS on mount (`_autoLocate()` in `initState` post-frame callback). Falls back to Nouakchott center if permission denied or GPS fails. Reverse geocoding via Nominatim (free, no API key) — `_reverseGeocode` calls `https://nominatim.openstreetmap.org/reverse?lat=...&lon=...&format=json&accept-language=ar` with `User-Agent: BalighApp/1.0`. Extracts `display_name`, shows detected address below map, and saves it to the report's `address` field. |
| ReportCard widget | ✅ | Shared across HomeView and MapView. Category icon, status pill (pending/validated/false_report), elapsed time, description (2 lines), location, credibility badge. Entrance animation (staggered fade+slide). |

### Partially Functional / Placeholder

| Screen/Feature | Status | Details |
|----------------|--------|---------|
| MyReportsView | ✅ | Full implementation: status filter bottom sheet, report list filtered by current user, pull-to-refresh, navigates to ReportDetailView. Edit/delete buttons on own cards. Edit opens bottom sheet form (category, description, photo). Delete with confirmation dialog. |
| AlertsView | ✅ | Full implementation: DB-backed AlertProvider via NotificationDao, unread badge, mark-all-read (requires auth), pull-to-refresh, time display |
| AccountView | ✅ | Full implementation: profile header with avatar + join date, stats card (submitted/validated), menu tiles → Settings, Emergency Numbers, Logout dialog |
| AddReport Step 3 (Photo) | ✅ | Bottom sheet with camera/gallery choice. `image_picker` picks from `ImageSource.camera` or `ImageSource.gallery` → upload to Supabase Storage "reports" bucket → public URL saved in report's `photo_url` field. CAMERA permission in AndroidManifest. |
| AddReport Step 4 (Review) | ✅ | Read-only summary (category, description, location). Submit wired to `buildDraft()` → `ReportProvider.addReport()`. Loading spinner + SnackBar on success/failure. |
| AddReport submission | ✅ | `buildDraft()` called in `_Step4ReviewBodyState._submit()`. Report saved to Supabase via ReportServiceDb/ReportDao. Navigator.pop + success SnackBar on completion. |
| Map vote buttons | ❌ Not wired | `onTap` has // TODO comments |
| ReportCard onTap | ✅ Wired | Both HomeView and MyReportsView navigate to ReportDetailView |
| Report Detail View | ✅ | Full screen: header with category icon + status, photo card (if available), info section, description, credibility bar, confirm/reject votes, location coordinates open Google Maps via `url_launcher` (green + underlined), share via `share_plus` with formatted message (emoji, credibility %, map link) |
| Settings Screen | ✅ | Theme toggle (Light/Dark/System), Language toggle (Arabic/French), About dialog, Privacy/Contact (coming soon), version display |
| Emergency Numbers Screen | ✅ | Police (17), Ambulance (101), Fire (18), Civil Protection (115) — styled tiles with call button |
| Splash/Welcome Screen | ✅ | Animated splash with logo + title + tagline, animated entrance, Start button + Skip link → navigates to LoginView. **Auto-login wired** — `tryAutoLogin()` called on first frame; skips splash if session exists, routes to LoginView otherwise. |
| Auth (Register/Login) | ✅ | **Supabase Auth** (email + password). AuthProvider for state management, auto session persistence. Login and Register screens at `lib/views/auth/`. Login/register are the entry point when user is not authenticated. |
| Database (Supabase) | ✅ | 4 tables (users, reports, votes, notifications) + storage bucket "reports". RLS enabled. Supabase client with auto session management. Admin role support (`is_admin` column + policies). |
| Admin Dashboard | ✅ | Standalone HTML/CSS/JS page deployed on Vercel at `admin-dashboard/`. Login via Supabase Auth, view/manage all reports (filter, status change, delete), view all users, view all notifications. Reports table with photo thumbnail, confirm/deny counts, credibility % bar, location (lat,lng), category color dots, zebra-striped rows. Report detail modal with full info (photo, description, votes, credibility bar, category, date, user). Users table with avatar, username, email, join date, reports/confirmed/reputation stats, is_admin toggle, delete button. Chart.js bar chart of reports by category. Arabic/French UI. RLS: added `"Admins can update any report"` policy. |
| Geolocation | ✅ Splash + MapView + Step 2 | First launch requests location permission automatically via `Geolocator.requestPermission()` (fired from splash `_checkAuth`). `MapProvider.goToMyLocation()` wired to device GPS via `Geolocator`. Report Step 2 location picker auto-centers on user GPS on mount via `_autoLocate()` and has its own "my location" button. Platform permissions handled at both splash and Step 2. |
| Camera / Photo | ✅ | `image_picker` wired in Step 3. Uploads to Supabase Storage "reports" public bucket. Saves public URL in `photo_url` column. |
| API / Backend | ✅ Supabase | SQLite fully replaced with Supabase. Auth, reports, votes, and notifications all read/write via Supabase client. Abstract ReportService interface preserved. |

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
- FMTC initialization happens at app boot (main.dart) before runApp.
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
- `_LocationPickerBody` does NOT have an `errorTileCallback` on its TileLayer

## 6. Known Bugs, Tech Debt & "Heavy" Code

### Bugs

| # | File:Line | Severity | Issue |
|---|-----------|----------|-------|
| 1 | report_card.dart:314-326 | ✅ Fixed | `_ElapsedTime` now uses `l10n.timeAgoMinutes/Hours/Days` with ICU plural rules. |
| 2 | map_provider.dart:120 vs report_card.dart:511 | Low | Category colour inconsistency: lighting is `Color(0xFFF9A825)` in MapProvider but `Color(0xFFFDD835)` in `_CategoryMeta`. Different yellow shades for the same category. |
| 3 | add_report_view.dart:228-238 | Low | `Consumer<AddReportProvider>` wrapping AnimatedSize for error banner — the consumer scope is correct but the error banner only depends on `showCategoryError`; unrelated provider changes (step transitions) also rebuild the error banner. Minor issue. |
| 4 | main_layout.dart | ✅ Fixed | Removed dead `_onFabTapped` method. |
| 5 | admin-dashboard/ | ✅ Fixed | Status update failed because RLS only allowed creators to update reports (not admins). Added new RLS policy `"Admins can update any report"`. Also revamped CSS: professional green/yellow theme (#1B6B2F / #F5C518), mobile hamburger menu, filter card, better spacing. |
| 6 | home_view.dart:151-224 | ✅ Fixed | SliverAppBar title overflow + subtitle cut off. `FlexibleSpaceBar.title` constrains its child width, causing the Row (app name + subtitle + notification icon) to overflow. Moved complex content to `background` with `SafeArea`, used `SliverAppBar.title` for collapsed state. |
| 7 | main.dart:77 | ✅ Fixed | Language stuck in French after switching to Arabic. Root cause: `MainLayout._tabBodies` was `static const` — `IndexedStack` kept alive the const widget instances, which the framework skipped updating via `identical()` check when InheritedWidget (Localizations) changed. Fix: added `key: ValueKey(localeProvider.locale.languageCode)` to MaterialApp to force full tree rebuild on locale change. |
| 5 | ~~add_report_view.dart:884~~ | ~~Critical~~ ✅ **Fixed** | **mouse_tracker + Scaffold.geometryOf dual crash** — `_LocationPickerBodyState._onPositionChanged` called `setState(() => _pickedPoint = camera.center)` on every drag frame (60–120×/sec). `setState` during pointer dispatch caused `_debugDuringDeviceUpdate` assertion spam (`mouse_tracker.dart`). The same rebuild flood propagated to `MainLayout`'s Scaffold during layout phase, causing `_BottomAppBarClipper.getClip` to access `ScaffoldGeometry` while `debugDoingPaint` was false → `Scaffold.geometryOf() must only be accessed during the paint phase`. **Fix 1 (primary):** bare field assignment `_pickedPoint = camera.center` — zero rebuilds during drag. **Fix 2 (structural):** `_MainLayoutState.build()` replaced `context.watch<NavigationProvider>()` with two `Selector<NavigationProvider, int>` wrappers (one for IndexedStack, one for BottomNav). The Scaffold shell + BottomAppBar + notch clipper now NEVER rebuild from provider notifications — only the two interior widgets that consume `currentIndex` do. |
| 6 | ~~add_report_view.dart:1149~~ | ~~Critical~~ ✅ **Fixed** | **Scaffold.geometryOf() crash + zombie UI on submission** — Confirmed by debugPrint instrumentation. `_submit()` itself ran to completion cleanly. The crash fired as a *scheduler callback* on the next frame, in `MouseTracker.updateAllDevices` → `_BottomAppBarClipper.getClip()` → `ScaffoldGeometryNotifier.value` → assertion `debugDoingPaint == true` fails. Root cause: `ReportProvider._setStatus(idle)` fires `notifyListeners()` (marks HomeView dirty) in the same microtask as `navigator.pop()` is called. Frame N therefore had two competing jobs: flush the pending HomeView rebuild AND start the route exit animation. `RendererBinding._scheduleMouseTrackerUpdate` fired during that frame's scheduler callbacks; the hit-test reached `_BottomAppBarClipper.getClip()` before the Scaffold had completed layout+paint, so `ScaffoldGeometry` was stale → assertion crash. The discard-path `navigator.pop()` never crashes because no `notifyListeners()` is pending when it fires. **Fix:** `WidgetsBinding.instance.addPostFrameCallback` defers SnackBar + pop to frame N+1. Frame N flushes all pending rebuilds and repaints the Scaffold (setting valid geometry). Frame N+1's pop fires into a fully-painted scaffold; mouse tracker hit-test finds a valid `ScaffoldGeometry` → no crash. SnackBar is shown before `navigator.pop()` inside the callback (standard Flutter ordering). |
| 7 | ~~supabase_migration.sql:18-30~~ | ~~Critical~~ ✅ **Fixed** | **All report inserts fail — missing `photo_url` column.** `ReportModel.toDbMap()` always sends `'photo_url': photoUrl` in the insert payload. The column didn't exist in the `reports` table, so PostgREST rejected every insert with "column 'photo_url' does not exist". **Fix:** Added `photo_url TEXT` column to the `reports` table definition + `ALTER TABLE ADD COLUMN IF NOT EXISTS` for existing databases. |
| 8 | ~~N/A~~ | ~~High~~ ✅ **Fixed** | **Photo upload fails — `reports` Storage bucket doesn't exist.** `SupabaseConfig.uploadReportPhoto()` tries `client.storage.from('reports')` but no such bucket existed. **Fix:** Added SQL to create `reports` public bucket + storage RLS policies (upload/view/delete) in migration. |
| 9 | my_reports_view.dart + report_card.dart | ✅ Done | **Feature: Edit/delete own reports.** Added edit/delete buttons on owner's report cards in MyReportsView. Edit opens a bottom sheet with pre-filled form, delete shows confirmation dialog. Added `deleteReport` and `editReport` methods to ReportProvider. |
| 10 | admin-dashboard/ | ✅ Done | **Feature: Admin dashboard.** Deployed on Vercel. Login, manage reports (filter/status/delete), view users, view notifications. Added `is_admin` column + RLS policies. |
| 11 | notification_service.dart + notification_dao.dart | ✅ Fixed | **Notifications never created.** Two bugs: (1) Haversine check used hardcoded coordinates `(18.0735, -15.9582)` — filtered out ALL users. (2) `NotificationDao.insert()` did a direct `.from('notifications').insert()` but no INSERT RLS policy existed → inserts silently failed. **Fix:** Removed Haversine check entirely — creates notification for every user except the reporter. `NotificationDao.insert()` now calls the existing `create_notification()` RPC function (SECURITY DEFINER, bypasses RLS). Console prints notification count per report submission. `location_service.dart` is now dead code. |
| 12 | AndroidManifest.xml | ✅ Fixed | **Release APK network and geolocation failure.** In `android/app/src/main/AndroidManifest.xml`, the `INTERNET` permission was accidentally nested inside an HTML/XML comment block, disabling network access on release builds and triggering unexpected errors on login ("حدث خطأ غير متوقع"). Geolocation permissions (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`) were also missing from the main manifest. **Fix:** Added internet and location permissions properly outside comments. |


### Tech Debt

| # | Item | Priority | Details |
|---|------|----------|---------|
| 2 | No error handling for FMTC init | Medium | main.dart:53-54 has no try/catch — if `FMTCObjectBoxBackend().initialise()` throws (e.g., corrupted DB), the app crashes at boot with no user feedback. |
| 3 | Unused localization keys | Low | `navMap`, `navReport`, `navSettings`, `homeQuickReport`, `homeViewMap`, `reportValidationDescription`, `reportPhoto`, `reportAddPhoto`, `reportChangePhoto`, `reportSubmit`, `reportSubmitSuccess`, `reportSubmitError`, `reportDetailTitle`, `reportDetailDate`, `reportDetailStatus`, `reportDetailCategory`, `reportDetailDescription`, `reportDetailLocation`, `settingsTitle`, `settingsLanguage`, `settingsNotifications`, `settingsNotificationsSubtitle`, `settingsAbout`, `settingsVersion`, `settingsPrivacy`, `settingsContact`, `settingsTheme`, `settingsThemeLight`, `settingsThemeDark`, `settingsThemeSystem`, `permissionLocationTitle`, `permissionLocationMessage`, `permissionLocationGrant`, `permissionLocationDeny`, `reportCount` — many keys defined but no UI uses them. |
| 4 | Duplicate FMTC store config strings | Low | `'osm_cache'` hardcoded in 3 files (main.dart:54, map_view.dart:204, add_report_view.dart:989). Extract to a constant or singleton. |
| 5 | ~~http package declared but unused~~ | Low | Removed with sqflite migration. |
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

2. ~~**Wire map vote buttons** — `_ReportPreviewSheet` had `// TODO` for `reportProvider.updateCredibility`.~~ ✅ **Done** — confirm/reject buttons now call `_vote()` which reads `AuthProvider.currentUserId` and delegates to `ReportProvider.updateCredibility()`. SnackBar feedback on success/error.

3. **Report detail view** — ✅ Done. `ReportDetailView` at `lib/views/report_detail/report_detail_view.dart` implements full report detail with:
    - Header: category icon + status chip
    - Info section: category, date, location
    - Description section
    - Credibility section: progress bar + confirm/reject vote chips
    - Action buttons: confirm/reject (wired to `ReportProvider.updateCredibility()`), open map
    - Both `HomeView` and `MyReportsView` navigate to it on card tap.

4. **Replace _ElapsedTime hardcoded strings** with proper localized plural messages via ARB (e.g., `timeAgoMinutes`, `timeAgoHours`, `timeAgoDays` with ICU plural rules).

5. **Remove dead code** `_onFabTapped` in main_layout.dart:71-85.

### Strongly Recommended

6. **Add geolocation** — `Geolocator` package added. `MapProvider.goToMyLocation()` wired to device GPS (added in previous session). **New:** Report Step 2 location picker now has a "my location" button using the same `Geolocator` flow. Platform permissions handled.

7. ~~**Extract ReportService**~~ ✅ **Done** — `lib/services/report_service.dart` defines abstract `ReportService` interface. `ReportServiceDb` in `lib/core/services/` implements it via SQLite. Drop-in replacement for HTTP backend.

8. **Remaining tab views:** ✅ **Done** (MyReportsView, AlertsView, AccountView all fully implemented).

9. **Consolidate duplicate category metadata** — map_provider.dart:120-136, report_card.dart:509-518, add_report_view.dart:279-286 all define the same category→icon→color mappings. Extract to a single source of truth (e.g., `ReportCategoryMeta` in the model or a dedicated utils/ file).

10. **Add try/catch around FMTC init** at main.dart:53-54.

### Polish / Nice-to-Have

11. Implement AddReport Step 3 — photo via `image_picker`. Step 4 (review + submit) is ✅ **Done**.

12. Build Settings screen (theme toggle, locale selector, about, version).

13. Replace Consumer2 in MapView with granular Selector per overlay widget, possibly memoizing the marker list.

14. Add `errorTileCallback` to `_LocationPickerBody` TileLayer.

15. Remove unused localization keys and unused http dependency.
