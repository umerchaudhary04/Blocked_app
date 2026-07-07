## 2024-07-01 - [CRITICAL] IPv6 Traffic Leak in VpnService
**Vulnerability:** The Android VpnService was configured to route only IPv4 traffic (`0.0.0.0/0`), allowing IPv6 traffic to leak outside the VPN tunnel, bypassing the intended network policies and exposing the user's real IP for IPv6 connections.
**Learning:** By default, if a VpnService configuration doesn't explicitly add IPv6 addresses and routes, the system routes IPv6 traffic through the default non-VPN interface.
**Prevention:** Always configure dual-stack routing by adding both IPv4 (`0.0.0.0/0`) and IPv6 (`::/0`) routes, along with dummy addresses for both (e.g., `10.0.0.2` and `fd00::1`), when creating a `VpnService` builder.
## 2025-02-28 - Information Leakage via printStackTrace

**Vulnerability:** Use of `e.printStackTrace()` in production Android code (like `BlockedVpnService.kt`) can inadvertently leak sensitive exception stack trace details to standard error output or application logs, which could provide attackers with details about the app's inner workings.

**Learning:** `printStackTrace()` should not be used. Android's built-in `Log` class (`android.util.Log`) should be used to log exceptions correctly into Android logcat.

**Prevention:** Ensure that error handling blocks use `Log.e(TAG, message, e)` instead of `e.printStackTrace()`.
