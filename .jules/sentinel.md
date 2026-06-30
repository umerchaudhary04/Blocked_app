## 2024-05-24 - [IPv6 Leak in VpnService]
**Vulnerability:** Android `VpnService` only routing IPv4 traffic, leaving IPv6 traffic to bypass the VPN and leak to the external network interface.
**Learning:** By default, if a `VpnService` doesn't explicitly declare handling for IPv6 (e.g., via `Builder.addAddress` and `Builder.addRoute`), the Android system routes IPv6 traffic through the default non-VPN interface. This defeats the privacy/security purpose of the VPN.
**Prevention:** Always explicitly configure dual-stack routing in `VpnService.Builder`. Add a generic IPv6 address (e.g., `fd00::1/128`) and route all IPv6 traffic (`::/0`) into the VPN.
