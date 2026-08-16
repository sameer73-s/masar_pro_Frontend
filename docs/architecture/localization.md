# Localization

Localization (i18n) is fully managed by the **`easy_localization`** package.

## Setup and Configuration

The setup is strictly handled in `lib/main.dart`:

1. **Initialization**: `EasyLocalization.ensureInitialized()` is called before `runApp()`.
2. **App Wrapper**: The root `MyApp` widget is wrapped inside an `EasyLocalization` widget.
3. **Configuration**:
   * `supportedLocales`: Defines the available languages: `[Locale('ar'), Locale('en'), Locale('fr')]`.
   * `path`: Specifies the asset directory containing translation files (`assets/translations`).
   * `fallbackLocale`: Defaults to Arabic (`Locale('ar')`) if a system locale is unsupported or a translation key is missing.
   * `useOnlyLangCode`: Set to `true`, meaning the app uses `en.json` rather than `en_US.json`.

## Translation Files

The actual translations are JSON files located in the `assets/translations/` directory (as declared in `pubspec.yaml`).
* `ar.json` (Arabic)
* `en.json` (English)
* `fr.json` (French)

Each JSON file contains key-value pairs where the key is a constant string and the value is the translated text.

## Usage in Code

### The `Strings` Class
To prevent typos and magic strings, translation keys are centralized in `lib/config/strings.dart`.
```dart
class Strings {
  static const String loginCredentialsRequired = 'login_credentials_required';
  static const String cancel = 'cancel';
  static const String error = 'error';
  // ...
}
```

### Applying Translations
In the UI or within BLoCs, the `.tr()` extension method provided by `easy_localization` is called on the string key.

```dart
// Example from LoginBloc
emit(LoginFailure(Strings.fingerprintNotSetup.tr(), ...));
```

When `.tr()` is called, the package looks up the key in the currently active JSON file (e.g., `en.json`) and returns the mapped string. If the user changes the language within the app, `easy_localization` automatically rebuilds the widget tree to reflect the new locale.
