import 'package:flutter/material.dart';
import 'configuration.dart';

class MasarProProdConfig implements Configuration {
  @override
  String get appName => 'Masar Pro';

  @override
  String get appLogo => 'assets/logo.png';

  @override
  String get baseUrl => 'https://masar-pro-backend.onrender.com';

  @override
  Widget get splashScreen => const Scaffold(body: Center(child: Text('Masar Pro')));

  @override
  ConfigurationColors get colors => _MasarProProdColors();
}

class _MasarProProdColors implements ConfigurationColors {
  @override
  Color get primary => Color(0xFF420039);
  @override
  Color get primaryDark => Color(0xFF420039);
  @override
  Color get secondary => Color(0xFF004D40);
  @override
  Color get accent => Color(0XFF004F62);
  @override
  Color get black => Color(0xff1F1F1F);
  @override
  Color get white => Color(0xffFFFFFF);
  @override
  Color get offWhite => Color(0xffF6F6F6);
  @override
  Color get transparent => Color(0x00000000);
  @override
  Color get dimBlack => Color(0x69000000);
  @override
  Color get pink => Color(0xffFFEAEB);
  @override
  Color get red => Color(0xffFF0000);
  @override
  Color get green => Color(0xff1D9502);
  @override
  Color get blue => Color(0xFF0B3B75);
  @override
  Color get orange => Color(0xFFD32F2F);
  @override
  Color get gray => Color(0xff777777);
  @override
  Color get grayHint => Color(0xFFA7A7A7);
  @override
  Color get grayLight => Color(0xffEEEEEE);
  @override
  Color get grayMedium => Color(0xffE4E6E8);
  @override
  Color get grayDark => Color(0xFF757575);
  @override
  Color get grayField => Color(0xffF2F2F2);
  @override
  Color get error => Color(0xFFCE0C0C);
  @override
  Color get success => Color(0xff1D9502);
  @override
  Color get info => Color(0xff018AFE);
  @override
  Color get warning => Color(0xffFBB03B);
  @override
  Color get darkerRed => Color(0xFF9F0303);
  @override
  Color get grayStatus => Color(0xFF838384);
  @override
  Color get pickerBackgroundContentColor => Color(0xFF004E62);
  @override
  Color get positiveBtn => Color(0xFF35B54D);
  @override
  Color get headerBackground => Color(0xFFFDF2F2);
  @override
  Color get headerBorder => Color(0xFFF48FB1);
  @override
  Color get labelTeal => Color(0xFF004F62);
  @override
  Color get cardBorder => Color(0xFFEEEEEE);
  @override
  Color get textPrimary => Colors.black;
  @override
  Color get textSecondary => Color(0xff666B88);
  @override
  Color get hint => Color(0XFFAAA8A8);
  @override
  Color get textHeader => Color(0xFF024B74);
  @override
  Color get scaffold => Color(0xFFFFF2FD);
  @override
  Color get card => Color(0xffffffff);
  @override
  Color get shimmer => Color(0xFFE0E0E0);
  @override
  Color get border => Color(0xffF9DCBF);
  @override
  Color get statusBar => primary;
  @override
  Color get appBar => primary;
  @override
  Color get blueLight => Color(0xFFF0F3FC);
  @override
  Color get grayLightMedium => Color(0xFFCBCED3);
  @override
  Color get yellowLight => Color(0xFFFBF7EC);
  @override
  Color get yellowLight2 => Color.fromARGB(255, 251, 248, 206);
  @override
  Color get blueLightMedium => Color(0xFFC3CBDB);
  @override
  Color get black20 => Color(0x33000000);
  @override
  Color get greenLight => Color(0xFFD2F9E6);
  @override
  Color get blueLight3 => Color(0xFFD2DEF9);
  @override
  Color get pinkLight => Color(0xFFFFD9DA);
  @override
  Color get blueLight4 => Color(0xFFB3CBDC);
  @override
  Color get blueDark => Color(0xFF03326a);
  @override
  Color get grayDarkMedium => Color(0xFFE2E2E2);
  @override
  Color get colorOrangeLight => Color(0XFFFFD9DA);
  @override
  Color get accent3 => Color(0xFFE8F2FE);
  @override
  Color get leaveContainerHeader => Color(0xFFC9E8EF);
  @override
  Color get leaveExpandableBorder => Color(0xFF004F62);
  @override
  Color get leaveExpandableTitle => Color(0xFF004F62);
  @override
  Color get leaveListItemBg => Color(0xFFD1F5EC);
  @override
  Color get leaveListItemBorder => Color(0xFF005642);
  @override
  Color get leaveTabTrack => Color(0xFFF5EEF8);
  @override
  Color get leaveTabTrackBorder => Color(0xFFE1D7EC);
  @override
  Color get olive => Color(0xFF808000);
  @override
  Color get dashboardBalanceColor1 => Color(0xFF004F62);
  @override
  Color get dashboardBalanceColor2 => Color(0xFF420039);
  @override
  Color get dashboardBalanceColor3 => Color(0xFF419D78);
  @override
  Color get dashboardBalanceColor4 => Color(0xFF7E5920);
  @override
  Color get dashboardBalanceColor5 => Color(0xFF5DB7DE);
  @override
  Color get dashboardBalanceColor6 => Color(0xFFED6A5A);
  @override
  Color get dashboardLatestColor => Color(0xFFFCF4F1);
  @override
  Color get dashboardRequestDelete => Color(0xFFFF3B3B);
  @override
  Color get dashboardRequestEdit => Color(0xFF005642);
  @override
  Color get reportTableColumn => Color(0Xfff0f3fc);
  @override
  Color get reportTableTextColumn => Color(0XFF00286F);
  @override
  Color get reportTableBorder => Color(0XFFf2f2f2);
  @override
  Color get reportTableTextRow => Color(0xFFF0F3FC);
  @override
  Color get filtterIcon => Color(0xFFDAEDFD);
  @override
  Color get salaryTotalcolor => Color(0xff0B8017);
  @override
  Color get salaryTotalBackgroundColor => Color(0xffD9FFE0);
  @override
  Color get vacationsAccentColor => Color(0XFFC9E8EF);
  @override
  Color get permitAccentColor => Color(0XFFFFE7DB);
  @override
  Color get loanAccentColor => Color(0XFFF9F6D2);
  @override
  Color get customAccentColor => Color(0XFFD2F9E6);
  @override
  Color get trustAccentColor => Color(0XFFD2DEF9);
  @override
  Color get cardShadowGray => Color(0xFFA7A7A7);
  @override
  Color get deepNavy => Color(0xFF0F172A);
  @override
  Color get slateGray => Color(0xFF64748B);
  @override
  Color get accentGold => Color(0xFFF59E0B);
  @override
  Color get background => Color(0xFFF8FAFC);
  @override
  Color get surface => Colors.white;
}
