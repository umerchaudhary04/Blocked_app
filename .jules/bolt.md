# Performance Learnings - Bolt

## UI Sync and MethodChannel Latency
**What**: Cached the `isProtected` VPN status locally using `SharedPreferences`.
**Why**: During app startup, relying entirely on a native `MethodChannel` call to `getStatus` introduces an async delay. This delay can lead to brief flashes of incorrect UI state ("Unprotected" flashing before switching to "Protection Active").
**Impact**: The UI can render its correct (or highly probable) state immediately by reading a local cache on init, providing a snappier user experience. We must still sync with the real MethodChannel status afterward and update the cache if it fell out of sync (e.g. if the OS killed the VPN process while the app was closed).
**Measurement**: Because testing this relies on real native platform latency vs a mock channel data return in tests, measuring the exact microsecond impact locally isn't feasible, but visually the UI will not flash.
