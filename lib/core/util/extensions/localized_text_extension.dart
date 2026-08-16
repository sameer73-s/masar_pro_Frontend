import '../../entity/value_objects/localized_text.dart';

extension LocalizedTextExtension on LocalizedText {
  /// Returns the local or foreign name based on the current language
  String getDisplayName(String langName) {
    if (langName.toLowerCase() == 'ar') {
      return local;
    } else {
      if (foreign.trim().isEmpty) {
        return local;
      } else {
        return foreign;
      }
    }
  }
}
