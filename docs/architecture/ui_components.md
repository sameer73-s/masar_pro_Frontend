# UI Components and Styling

The Onyx ESS application leverages a highly customized Material Design language.

## Global Styling

Styling configuration is centralized in the `lib/config/` directory to ensure consistency.

### `app_theme.dart`
* Defines the global `ThemeData` for the `MaterialApp`.
* Configures default styles for `AppBar`, `ElevatedButton`, `InputDecoration` (text fields), and `Card`s.
* Injects custom typography into the text themes using `google_fonts`.
* Configures `SystemUiOverlayStyle` to control the status bar appearance.

### `app_colors.dart`
* Acts as a central repository for all color constants (e.g., primary colors, background colors, text colors, error colors).
* Avoids hardcoding hex values directly into widgets.

### `app_assets.dart`
* Centralizes asset paths (images, SVGs, Lottie JSONs). Prevents typos and makes it easy to locate assets.

## Common & Reusable Components

While specific feature UIs live in `lib/features/{feature}/presentation/views/`, common UI patterns utilize standard packages:

* **Animations**: `lottie` is used for empty states, success indicators, and complex graphical animations. `flutter_staggered_animations` provides smooth entry animations for list items and grid items.
* **Loading States**: `shimmer` is used to create skeleton loading effects (grey pulsing boxes) instead of basic circular progress indicators when fetching data.
* **Bottom Sheets**: `modal_bottom_sheet` is used to present complex, scrollable menus and options seamlessly.
* **Refresh**: `pull_to_refresh` wraps list views to standardized pull-to-refresh headers (`MaterialClassicHeader`) and pagination footers (`ClassicFooter`).
* **Snackbars/Toasts**: `another_flushbar` is typically used for beautiful, animated toast notifications (especially for BLoC failure states).

## Responsive Design
* A custom `ResponsiveService` (`lib/core/util/responsive_service.dart`) is initialized in `MyApp`. It is likely used to scale fonts and paddings based on screen size, ensuring a consistent look across different mobile devices.
