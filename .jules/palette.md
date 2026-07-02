## 2026-07-01 - AnimatedSwitcher State Transition Pattern
**Learning:** In Flutter, `AnimatedSwitcher` fails to trigger transitions if the new child has the same runtime type as the old child, unless a `ValueKey` is provided to differentiate them.
**Action:** Always include a unique `ValueKey` (e.g., based on state boolean) on widgets inside an `AnimatedSwitcher` when toggling between icons or similar widget types.
