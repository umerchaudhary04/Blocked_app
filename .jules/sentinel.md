## 2024-07-01 - [CRITICAL] IPv6 Traffic Leak in VpnService
**Vulnerability:** The Android VpnService was configured to route only IPv4 traffic (`0.0.0.0/0`), allowing IPv6 traffic to leak outside the VPN tunnel, bypassing the intended network policies and exposing the user's real IP for IPv6 connections.
**Learning:** By default, if a VpnService configuration doesn't explicitly add IPv6 addresses and routes, the system routes IPv6 traffic through the default non-VPN interface.
**Prevention:** Always configure dual-stack routing by adding both IPv4 (`0.0.0.0/0`) and IPv6 (`::/0`) routes, along with dummy addresses for both (e.g., `10.0.0.2` and `fd00::1`), when creating a `VpnService` builder.
