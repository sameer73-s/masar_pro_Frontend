import 'package:flutter/material.dart';
import '../injection/injection_container.dart';
import 'flavor_configuration/configuration.dart';

class AppColors {
  AppColors._();

  // ── Design Tokens (Figma) ──────────────────────────────────────────
  /// Main text / dark surface
  static const Color primary = Color(0xFF24252C);

  /// App background
  static const Color background = Color(0xFFFFFFFF);

  /// Primary CTA
  static const Color accentYellow = Color(0xFFFDAD00);

  static const Color accentPurple = Color(0xFF5F33E1);

  static const Color accentOrange = Color(0xFFEA6C00);

  // Shared presentation tokens for consistent premium surfaces and states.
  static const Color uiBorder = Color(0xFFE8E5F0);
  static const Color uiPending = Color(0xFFC5C0D3);
  static const Color uiPurpleTrack = Color(0xFFEEE9FF);
  static const Color uiPurpleProgress = Color(0xFF8764FF);
  static const Color uiSuccess = Color(0xFF22C55E);
  static const Color uiWarning = Color(0xFFD97706);
  static const Color uiDanger = Color(0xFFEF4444);
  static const Color uiMutedText = Color(0xFF4A4758);
  static const Color uiFabShadow = Color(0x7D5F33E1);

  /// Light purple background
  static const Color surfacePurple = Color(0xFFF3F0FF);

  /// Light yellow background
  static const Color surfaceYellow = Color(0xFFFEEEB7);

  /// Light orange background
  static const Color surfaceOrange = Color(0xFFFFF0E5);

  /// Light blue background (status / to-do)
  static const Color surfaceBlue = Color(0xFFE3F2FF);

  /// Light pink background
  static const Color surfacePink = Color(0xFFFFE4F2);

  /// Status blue text
  static const Color statusBlue = Color(0xFF0087FF);

  /// Secondary / muted body text
  static const Color textSecondary = Color(0xFF6E6A7C);

  /// Tertiary / soft accent text
  static const Color textTertiary = Color(0xFFAB94FF);

  /// For custom elevations
  static const Color shadowColor = Color(0xFF544A71);

  // ── Legacy / flavor-backed palette (kept for existing widgets) ─────
  static Color get primaryDark => locator<Configuration>().colors.primaryDark;
  static Color get secondary => locator<Configuration>().colors.secondary;
  static Color get accent => locator<Configuration>().colors.accent;

  // Neutrals
  static Color get black => locator<Configuration>().colors.black;
  static Color get white => locator<Configuration>().colors.white;
  static Color get offWhite => locator<Configuration>().colors.offWhite;
  static Color get transparent => locator<Configuration>().colors.transparent;
  static Color get dimBlack => locator<Configuration>().colors.dimBlack;
  static Color get pink => locator<Configuration>().colors.pink;
  static Color get red => locator<Configuration>().colors.red;
  static Color get green => locator<Configuration>().colors.green;
  static Color get blue => locator<Configuration>().colors.blue;
  static Color get orange => locator<Configuration>().colors.orange;

  // Grays
  static Color get gray => locator<Configuration>().colors.gray;
  static Color get grayHint => locator<Configuration>().colors.grayHint;
  static Color get grayLight => locator<Configuration>().colors.grayLight;
  static Color get grayMedium => locator<Configuration>().colors.grayMedium;
  static Color get grayDark => locator<Configuration>().colors.grayDark;
  static Color get grayField => locator<Configuration>().colors.grayField;

  // Semantic
  static Color get error => locator<Configuration>().colors.error;
  static Color get success => locator<Configuration>().colors.success;
  static Color get info => locator<Configuration>().colors.info;
  static Color get warning => locator<Configuration>().colors.warning;

  // Ported 1:1 from skey_ess's AppErrorDialog for visual parity.
  static Color get darkerRed => locator<Configuration>().colors.darkerRed;
  static Color get grayStatus => locator<Configuration>().colors.grayStatus;

  static Color get pickerBackgroundContentColor =>
      locator<Configuration>().colors.pickerBackgroundContentColor;
  static Color get positiveBtn => locator<Configuration>().colors.positiveBtn;
  static Color get headerBackground =>
      locator<Configuration>().colors.headerBackground;
  static Color get headerBorder => locator<Configuration>().colors.headerBorder;
  static Color get labelTeal => locator<Configuration>().colors.labelTeal;
  static Color get cardBorder => locator<Configuration>().colors.cardBorder;

  // Text
  static Color get textPrimary => locator<Configuration>().colors.textPrimary;
  static Color get hint => locator<Configuration>().colors.hint;
  static Color get textHeader => locator<Configuration>().colors.textHeader;

  // Surface
  static Color get scaffold => locator<Configuration>().colors.scaffold;
  static Color get card => locator<Configuration>().colors.card;
  static Color get shimmer => locator<Configuration>().colors.shimmer;
  static Color get border => locator<Configuration>().colors.border;

  // Status bar / AppBar
  static Color get statusBar => locator<Configuration>().colors.statusBar;
  static Color get appBar => locator<Configuration>().colors.appBar;

  static Color get blueLight => locator<Configuration>().colors.blueLight;
  static Color get grayLightMedium =>
      locator<Configuration>().colors.grayLightMedium;
  static Color get yellowLight => locator<Configuration>().colors.yellowLight;
  static Color get yellowLight2 => locator<Configuration>().colors.yellowLight2;

  static Color get blueLightMedium =>
      locator<Configuration>().colors.blueLightMedium;
  static Color get black20 => locator<Configuration>().colors.black20;
  static Color get greenLight => locator<Configuration>().colors.greenLight;
  static Color get blueLight3 => locator<Configuration>().colors.blueLight3;
  static Color get pinkLight => locator<Configuration>().colors.pinkLight;
  static Color get blueLight4 => locator<Configuration>().colors.blueLight4;
  static Color get blueDark => locator<Configuration>().colors.blueDark;
  static Color get grayDarkMedium =>
      locator<Configuration>().colors.grayDarkMedium;
  static Color get colorOrangeLight =>
      locator<Configuration>().colors.colorOrangeLight;
  static Color get accent3 => locator<Configuration>().colors.accent3;

  // Leave request palette
  static Color get leaveContainerHeader =>
      locator<Configuration>().colors.leaveContainerHeader;
  static Color get leaveExpandableBorder =>
      locator<Configuration>().colors.leaveExpandableBorder;
  static Color get leaveExpandableTitle =>
      locator<Configuration>().colors.leaveExpandableTitle;
  static Color get leaveListItemBg =>
      locator<Configuration>().colors.leaveListItemBg;
  static Color get leaveListItemBorder =>
      locator<Configuration>().colors.leaveListItemBorder;
  static Color get leaveTabTrack =>
      locator<Configuration>().colors.leaveTabTrack;
  static Color get leaveTabTrackBorder =>
      locator<Configuration>().colors.leaveTabTrackBorder;
  static Color get olive => locator<Configuration>().colors.olive;
  static Color get dashboardBalanceColor1 =>
      locator<Configuration>().colors.dashboardBalanceColor1;
  static Color get dashboardBalanceColor2 =>
      locator<Configuration>().colors.dashboardBalanceColor2;
  static Color get dashboardBalanceColor3 =>
      locator<Configuration>().colors.dashboardBalanceColor3;
  static Color get dashboardBalanceColor4 =>
      locator<Configuration>().colors.dashboardBalanceColor4;
  static Color get dashboardBalanceColor5 =>
      locator<Configuration>().colors.dashboardBalanceColor5;
  static Color get dashboardBalanceColor6 =>
      locator<Configuration>().colors.dashboardBalanceColor6;

  static Color get dashboardLatestColor =>
      locator<Configuration>().colors.dashboardLatestColor;
  static Color get dashboardRequestDelete =>
      locator<Configuration>().colors.dashboardRequestDelete;
  static Color get dashboardRequestEdit =>
      locator<Configuration>().colors.dashboardRequestEdit;

  // Report tables
  static Color get reportTableColumn =>
      locator<Configuration>().colors.reportTableColumn;
  static Color get reportTableTextColumn =>
      locator<Configuration>().colors.reportTableTextColumn;
  static Color get reportTableBorder =>
      locator<Configuration>().colors.reportTableBorder;
  static Color get reportTableTextRow =>
      locator<Configuration>().colors.reportTableTextRow;

  // Report
  static Color get filtterIcon => locator<Configuration>().colors.filtterIcon;
  static Color get salaryTotalcolor =>
      locator<Configuration>().colors.salaryTotalcolor;
  static Color get salaryTotalBackgroundColor =>
      locator<Configuration>().colors.salaryTotalBackgroundColor;

  // Request
  static Color get vacationsAccentColor =>
      locator<Configuration>().colors.vacationsAccentColor;
  static Color get permitAccentColor =>
      locator<Configuration>().colors.permitAccentColor;
  static Color get loanAccentColor =>
      locator<Configuration>().colors.loanAccentColor;
  static Color get customAccentColor =>
      locator<Configuration>().colors.customAccentColor;
  static Color get trustAccentColor =>
      locator<Configuration>().colors.trustAccentColor;

  static Color get cardShadowGray =>
      locator<Configuration>().colors.cardShadowGray;

  // Masar Pro legacy aliases (prefer design tokens above for new UI)
  static Color get deepNavy => locator<Configuration>().colors.deepNavy;
  static Color get slateGray => locator<Configuration>().colors.slateGray;
  static Color get accentGold => locator<Configuration>().colors.accentGold;
  static Color get surface => locator<Configuration>().colors.surface;
}
