## 2026-06-29 - [Fix IPv6 Leak in Android VpnService]
**Vulnerability:** Android VpnService only routed IPv4 traffic (0.0.0.0/0), allowing all IPv6 traffic to bypass the VPN and leak outside the protected tunnel.
**Learning:** When configuring Android's VpnService, specifying an IPv4 address and route is not enough. Without explicitly routing IPv6, the system will use the default non-VPN interface for IPv6 traffic.
**Prevention:** Always configure dual-stack routing in VpnService implementations. Add an IPv6 address (e.g., fd00::1) and route (::/0) alongside IPv4 to ensure all traffic goes through the VPN.
