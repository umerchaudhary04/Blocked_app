## 2024-06-28 - Avoid Information Leakage in Platform Exceptions
**Vulnerability:** PlatformExceptions originating from the native Android (Kotlin) `MethodChannel` calls were being caught in Flutter and their raw `e.message` exposed directly to the user via UI Snackbars.
**Learning:** Exposing raw system error messages directly to the UI risks leaking sensitive internal file paths, stack traces, or operational details about the VPN service state.
**Prevention:** Always sanitize exception messages caught from `MethodChannel` interactions before displaying them. Log the raw exception internally (`debugPrint` or a logger tool) and present a generic, secure fallback message to the end user.
