## 2026-07-01 - AnimatedSwitcher State Transition Pattern
**Learning:** In Flutter, `AnimatedSwitcher` fails to trigger transitions if the new child has the same runtime type as the old child, unless a `ValueKey` is provided to differentiate them.
**Action:** Always include a unique `ValueKey` (e.g., based on state boolean) on widgets inside an `AnimatedSwitcher` when toggling between icons or similar widget types.
## 2026-07-04 - Floating and Rounded Error Snackbars
**Learning:** `SnackBarBehavior.floating` and explicit `margin` in Flutter `SnackBar` make a huge difference in visual appeal, moving the error from a stark banner to a more modern, contextual tooltip style.
**Action:** Default to floating Snackbars with rounded corners for generic errors in this application to maintain a polished look.

## 2026-07-04 - Preventing Layout Shifts in Buttons
**Learning:** Replacing a button entirely with a `CircularProgressIndicator` creates a jarring layout jump. Keeping the `ElevatedButton`, passing `null` to `onPressed` to disable it, and using an `AnimatedSwitcher` to show the spinner *inside* the button provides a vastly superior UX.
**Action:** Always prefer embedding loading spinners inside the disabled button rather than swapping the components out completely.

## 2026-07-04 - Avoid Testing State Hallucinations
**Learning:** It is extremely easy to accidentally pass nonexistent initial state arguments (`initialIsProtected: false`) into widget constructors during testing if the application reads from `SharedPreferences` instead of accepting explicit parameters.
**Action:** Do not hallucinate properties in widgets to force state for tests. Mock the underlying data source (e.g., `SharedPreferences.setMockInitialValues({})`) instead.
