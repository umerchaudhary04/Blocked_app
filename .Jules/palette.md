## 2024-07-28 - AnimatedSwitcher state requirement
**Learning:** `AnimatedSwitcher` transitions in Flutter require a `key` parameter (like `ValueKey<bool>`) that changes to trigger the animation; changing just properties like `icon` or `color` on the child widget will not initiate the transition.
**Action:** Always verify `key` properties are set correctly when implementing state-based transition animations.
