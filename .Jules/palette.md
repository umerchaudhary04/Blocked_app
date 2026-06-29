## 2024-06-29 - AnimatedSwitcher Key Binding in Flutter
**Learning:** When using `AnimatedSwitcher` to animate between two different states of the *same* widget type (e.g. `Icon` to `Icon`), the widget must have a unique `Key` (like `ValueKey<bool>(state)`) so the framework knows the child has changed and triggers the animation. Simply changing parameters on the same widget type without a new key will skip the animation.
**Action:** Always provide explicit `ValueKey`s on children of `AnimatedSwitcher` when toggling properties instead of swapping completely different widget types.
