## 2024-07-01 - [CRITICAL] IPv6 Traffic Leak in VpnService
**Vulnerability:** The Android VpnService was configured to route only IPv4 traffic (`0.0.0.0/0`), allowing IPv6 traffic to leak outside the VPN tunnel, bypassing the intended network policies and exposing the user's real IP for IPv6 connections.
**Learning:** By default, if a VpnService configuration doesn't explicitly add IPv6 addresses and routes, the system routes IPv6 traffic through the default non-VPN interface.
**Prevention:** Always configure dual-stack routing by adding both IPv4 (`0.0.0.0/0`) and IPv6 (`::/0`) routes, along with dummy addresses for both (e.g., `10.0.0.2` and `fd00::1`), when creating a `VpnService` builder.
## 2024-05-XX - Remove hardcoded DNS servers

**Vulnerability:** A DNS Server IP address (`1.1.1.3`) was hardcoded directly in `BlockedVpnService.kt`, creating a security and operational risk as it cannot be updated without a release and is inflexible.
**Learning:** Hardcoded IPs, especially in native security components like `VpnService`, should be passed through secure configuration channels. In a Flutter app, this means pushing the configuration from Dart to Kotlin/Java using a `MethodChannel` and `Intent` extras, allowing it to be managed dynamically or remotely.
**Prevention:** Avoid hardcoding IPs or configuration directly in native Android code. Expose these settings as parameters from the Flutter layer to the native MethodChannel and intent configuration. When updating Dart widgets with new required parameters, ensure tests are updated with `pumpWidget(MaterialApp(home: Dashboard(initialIsProtected: false)))` and mock `SharedPreferences`.
