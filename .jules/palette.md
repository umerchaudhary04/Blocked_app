## 2026-07-01 - AnimatedSwitcher State Transition Pattern
**Learning:** In Flutter, `AnimatedSwitcher` fails to trigger transitions if the new child has the same runtime type as the old child, unless a `ValueKey` is provided to differentiate them.
**Action:** Always include a unique `ValueKey` (e.g., based on state boolean) on widgets inside an `AnimatedSwitcher` when toggling between icons or similar widget types.

## 2024-07-07 - AnimatedSwitcher Loading State
**Learning:** `AnimatedSwitcher` isn't just for switching icons; it can be used to smoothly transition between a loading indicator and a functional element like a button, making actions feel less abrupt.
**Action:** When a button disables itself or replaces its content with a loading spinner (e.g., `CircularProgressIndicator`), wrap the conditional in an `AnimatedSwitcher` and use `ValueKey` to ensure a smooth transition.
