import 'package:flutter/material.dart';

export 'app_border_radius.dart';
export 'app_spacing.dart';

/// Color tokens exported from Figma design system.
/// Each color group has Light and Dark mode variants.
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════
  // PRIMARY (Purple)
  // ═══════════════════════════════════════════════════════════

  // --- Light Mode ---
  static const Color primaryMainLight = Color(0xFF704ADD);
  static const Color primaryN300Light = Color(0xFF270F6A);
  static const Color primaryN200Light = Color(0xFF412590);
  static const Color primaryN100Light = Color(0xFF5B36C2);
  static const Color primary100Light = Color(0xFF916AFF);
  static const Color primary200Light = Color(0xFFA788FF);
  static const Color primary300Light = Color(0xFFBDA6FF);
  static const Color primary400Light = Color(0xFFD3C3FF);
  static const Color primary500Light = Color(0xFFE9E1FF);
  static const Color primary600Light = Color(0xFFF4F1FF);

  // Transparent variants (Light)
  static const Color primary200TLight = Color(0xCC916AFF); // 80%
  static const Color primary300TLight = Color(0x99916AFF); // 60%
  static const Color primary400TLight = Color(0x66916AFF); // 40%
  static const Color primary500TLight = Color(0x33916AFF); // 20%
  static const Color primary600TLight = Color(0x1A916AFF); // 10%

  // --- Dark Mode ---
  static const Color primaryMainDark = Color(0xFFAF94FF);
  static const Color primaryN300Dark = Color(0xFFE8DFFF);
  static const Color primaryN200Dark = Color(0xFFD8CBFF);
  static const Color primaryN100Dark = Color(0xFFBDA6FF);
  static const Color primary100Dark = Color(0xFFA281FF);
  static const Color primary200Dark = Color(0xFF886CD6);
  static const Color primary300Dark = Color(0xFF6C57AC);
  static const Color primary400Dark = Color(0xFF524483);
  static const Color primary500Dark = Color(0xFF362F59);
  static const Color primary600Dark = Color(0xFF292444);

  // Transparent variants (Dark)
  static const Color primary200TDark = Color(0xCCA281FF); // 80%
  static const Color primary300TDark = Color(0x99A281FF); // 60%
  static const Color primary400TDark = Color(0x66A281FF); // 40%
  static const Color primary500TDark = Color(0x33A281FF); // 20%
  static const Color primary600TDark = Color(0x1AA281FF); // 10%

  // ═══════════════════════════════════════════════════════════
  // SECONDARY (Blue)
  // ═══════════════════════════════════════════════════════════

  // --- Light Mode ---
  static const Color secondaryMainLight = Color(0xFF01649C);
  static const Color secondaryN300Light = Color(0xFF002940);
  static const Color secondaryN200Light = Color(0xFF003E62);
  static const Color secondaryN100Light = Color(0xFF005382);
  static const Color secondary100Light = Color(0xFF0078BC);
  static const Color secondary200Light = Color(0xFF3393C9);
  static const Color secondary300Light = Color(0xFF66AED7);
  static const Color secondary400Light = Color(0xFF99C9E4);
  static const Color secondary500Light = Color(0xFFCCE4F2);
  static const Color secondary600Light = Color(0xFFE6F2F9);

  // Transparent variants (Light)
  static const Color secondary200TLight = Color(0xCC0078BC); // 80%
  static const Color secondary300TLight = Color(0x990078BC); // 60%
  static const Color secondary400TLight = Color(0x660078BC); // 40%
  static const Color secondary500TLight = Color(0x330078BC); // 20%
  static const Color secondary600TLight = Color(0x1A0078BC); // 10%

  // --- Dark Mode ---
  static const Color secondaryMainDark = Color(0xFF28B2FF);
  static const Color secondaryN300Dark = Color(0xFFC6EAFF);
  static const Color secondaryN200Dark = Color(0xFF86D3FF);
  static const Color secondaryN100Dark = Color(0xFF40BAFF);
  static const Color secondary100Dark = Color(0xFF069BEF);
  static const Color secondary200Dark = Color(0xFF0B81C9);
  static const Color secondary300Dark = Color(0xFF0F67A2);
  static const Color secondary400Dark = Color(0xFF134E7D);
  static const Color secondary500Dark = Color(0xFF173456);
  static const Color secondary600Dark = Color(0xFF1A2643);

  // Transparent variants (Dark)
  static const Color secondary200TDark = Color(0xCC069BEF); // 80%
  static const Color secondary300TDark = Color(0x99069BEF); // 60%
  static const Color secondary400TDark = Color(0x66069BEF); // 40%
  static const Color secondary500TDark = Color(0x33069BEF); // 20%
  static const Color secondary600TDark = Color(0x1A069BEF); // 10%

  // ═══════════════════════════════════════════════════════════
  // GREEN
  // ═══════════════════════════════════════════════════════════

  // --- Light Mode ---
  static const Color greenMainLight = Color(0xFF007830);
  static const Color greenN300Light = Color(0xFF002F13);
  static const Color greenN200Light = Color(0xFF00461C);
  static const Color greenN100Light = Color(0xFF006428);
  static const Color green100Light = Color(0xFF00A040);
  static const Color green200Light = Color(0xFF33B366);
  static const Color green300Light = Color(0xFF66C68C);
  static const Color green400Light = Color(0xFF99D9B3);
  static const Color green500Light = Color(0xFFCCECD9);
  static const Color green600Light = Color(0xFFE6F6EC);

  // --- Dark Mode ---
  static const Color greenMainDark = Color(0xFF21E470);
  static const Color greenN300Dark = Color(0xFFD4FEE5);
  static const Color greenN200Dark = Color(0xFFA4F8C5);
  static const Color greenN100Dark = Color(0xFF4ADE85);
  static const Color green100Dark = Color(0xFF0ED75E);
  static const Color green200Dark = Color(0xFF11B155);
  static const Color green300Dark = Color(0xFF138B4B);
  static const Color green400Dark = Color(0xFF176643);
  static const Color green500Dark = Color(0xFF194039);
  static const Color green600Dark = Color(0xFF1A2C34);

  // ═══════════════════════════════════════════════════════════
  // AMBER (Orange)
  // ═══════════════════════════════════════════════════════════

  // --- Light Mode ---
  static const Color amberMainLight = Color(0xFFC33B00);
  static const Color amberN300Light = Color(0xFF4E1700);
  static const Color amberN200Light = Color(0xFF752300);
  static const Color amberN100Light = Color(0xFF9D3000);
  static const Color amber100Light = Color(0xFFF54A00);
  static const Color amber200Light = Color(0xFFF76E33);
  static const Color amber300Light = Color(0xFFF99266);
  static const Color amber400Light = Color(0xFFFBB799);
  static const Color amber500Light = Color(0xFFFDDBCC);
  static const Color amber600Light = Color(0xFFFEEDE6);

  // --- Dark Mode ---
  static const Color amberMainDark = Color(0xFFFF783F);
  static const Color amberN300Dark = Color(0xFFFFE0D2);
  static const Color amberN200Dark = Color(0xFFFFBFA4);
  static const Color amberN100Dark = Color(0xFFFFA27A);
  static const Color amber100Dark = Color(0xFFFF6522);
  static const Color amber200Dark = Color(0xFFD25625);
  static const Color amber300Dark = Color(0xFFA44727);
  static const Color amber400Dark = Color(0xFF77382B);
  static const Color amber500Dark = Color(0xFF49292D);
  static const Color amber600Dark = Color(0xFF32212E);

  // ═══════════════════════════════════════════════════════════
  // RED
  // ═══════════════════════════════════════════════════════════

  // --- Light Mode ---
  static const Color redMainLight = Color(0xFFD61134);
  static const Color redN300Light = Color(0xFF51000F);
  static const Color redN200Light = Color(0xFF760016);
  static const Color redN100Light = Color(0xFFA70825);
  static const Color red100Light = Color(0xFFFF2950);
  static const Color red200Light = Color(0xFFFF5473);
  static const Color red300Light = Color(0xFFFF7F96);
  static const Color red400Light = Color(0xFFFFA9B9);
  static const Color red500Light = Color(0xFFFFD4DC);
  static const Color red600Light = Color(0xFFFFEAEE);

  // --- Dark Mode ---
  static const Color redMainDark = Color(0xFFFF6984);
  static const Color redN300Dark = Color(0xFFFFE1E7);
  static const Color redN200Dark = Color(0xFFFFC0CC);
  static const Color redN100Dark = Color(0xFFFF90A4);
  static const Color red100Dark = Color(0xFFFF4466);
  static const Color red200Dark = Color(0xFFD23B5C);
  static const Color red300Dark = Color(0xFFA43350);
  static const Color red400Dark = Color(0xFF772B46);
  static const Color red500Dark = Color(0xFF49233A);
  static const Color red600Dark = Color(0xFF321E35);

  // ═══════════════════════════════════════════════════════════
  // GREY
  // ═══════════════════════════════════════════════════════════

  // --- Light Mode ---
  static const Color grey100Light = Color(0xFF212B4D);
  static const Color grey200Light = Color(0xFF424A67);
  static const Color grey300Light = Color(0xFF646B83);
  static const Color grey400Light = Color(0xFF7A8094);
  static const Color grey500Light = Color(0xFFA6AAB8);
  static const Color grey600Light = Color(0xFFBDC0CA);
  static const Color grey700Light = Color(0xFFD3D5DB);
  static const Color grey800Light = Color(0xFFE4E5E9);
  static const Color grey900Light = Color(0xFFEFF0F2);

  // Transparent variants (Light)
  static const Color grey200TLight = Color(0xD9212B4D); // 85%
  static const Color grey300TLight = Color(0xB3212B4D); // 70%
  static const Color grey400TLight = Color(0x99212B4D); // 60%
  static const Color grey500TLight = Color(0x66212B4D); // 40%
  static const Color grey600TLight = Color(0x4D212B4D); // 30%
  static const Color grey700TLight = Color(0x33212B4D); // 20%
  static const Color grey800TLight = Color(0x1F212B4D); // 12%
  static const Color grey900TLight = Color(0x12212B4D); // 7%

  // --- Dark Mode ---
  static const Color grey100Dark = Color(0xFFD3D7E4);
  static const Color grey200Dark = Color(0xFFB7BBC9);
  static const Color grey300Dark = Color(0xFF9C9EAE);
  static const Color grey400Dark = Color(0xFF8A8B9C);
  static const Color grey500Dark = Color(0xFF656678);
  static const Color grey600Dark = Color(0xFF535266);
  static const Color grey700Dark = Color(0xFF404054);
  static const Color grey800Dark = Color(0xFF323145);
  static const Color grey900Dark = Color(0xFF29273D);

  // Transparent variants (Dark)
  static const Color grey200TDark = Color(0xD9D3D7E4); // 85%
  static const Color grey300TDark = Color(0xB3D3D7E4); // 70%
  static const Color grey400TDark = Color(0x99D3D7E4); // 60%
  static const Color grey500TDark = Color(0x66D3D7E4); // 40%
  static const Color grey600TDark = Color(0x4DD3D7E4); // 30%
  static const Color grey700TDark = Color(0x33D3D7E4); // 20%
  static const Color grey800TDark = Color(0x1FD3D7E4); // 12%
  static const Color grey900TDark = Color(0x12D3D7E4); // 7%

  // ═══════════════════════════════════════════════════════════
  // TEXT
  // ═══════════════════════════════════════════════════════════

  // --- Light Mode ---
  static const Color textNormalLight = Color(0xFF253059);
  static const Color textLowPriorityLight = Color(0xFF5C6483);
  static const Color textFilledButtonLight = Color(0xFFFFFFFF);
  static const Color textNormalDisabledLight = Color(0x80253059); // 50%

  // --- Dark Mode ---
  static const Color textNormalDark = Color(0xE6FFFFFF); // 90%
  static const Color textLowPriorityDark = Color(0xB3FFFFFF); // 70%
  static const Color textFilledButtonDark = Color(0xCC000000); // 80%
  static const Color textNormalDisabledDark = Color(0x80FFFFFF); // 50%

  // ═══════════════════════════════════════════════════════════
  // BACKGROUND
  // ═══════════════════════════════════════════════════════════

  // --- Light Mode ---
  static const Color bgPrimaryLight = Color(0xFFFFFFFF);
  static const Color bgSecondaryLight = Color(0xFFEFF0F2);
  static const Color bgModalLight = Color(0x99191131); // 60%
  static const Color bgModalBorderLight = Color(0x00FFFFFF); // 0%
  static const Color bgPopoverLight = Color(0xFF191131);

  // --- Dark Mode ---
  static const Color bgPrimaryDark = Color(0xFF1C1A30);
  static const Color bgSecondaryDark = Color(0xFF0B0B12);
  static const Color bgModalDark = Color(0xCC000000); // 80%
  static const Color bgModalBorderDark = Color(0x12FFFFFF); // 7%
  static const Color bgPopoverDark = Color(0xFFE6E9F3);

  // ═══════════════════════════════════════════════════════════
  // OS COLORS
  // ═══════════════════════════════════════════════════════════

  static const Color osMainLight = Color(0xFF000000);
  static const Color osMainDark = Color(0xFFFFFFFF);
}

/// Theme-aware semantic colors accessible via `context.colors`.
/// Automatically resolves light/dark variants based on current theme.
class SemanticColors {
  SemanticColors._(this._isDark);

  final bool _isDark;

  // Primary
  Color get primary =>
      _isDark ? AppColors.primaryMainDark : AppColors.primaryMainLight;
  Color get primaryLight => AppColors.primary100Light;
  Color get primary100 =>
      _isDark ? AppColors.primary100Dark : AppColors.primary100Light;
  Color get primary200 =>
      _isDark ? AppColors.primary200Dark : AppColors.primary200Light;
  Color get primary300 =>
      _isDark ? AppColors.primary300Dark : AppColors.primary300Light;
  Color get primary400 =>
      _isDark ? AppColors.primary400Dark : AppColors.primary400Light;
  Color get primary500 =>
      _isDark ? AppColors.primary500Dark : AppColors.primary500Light;
  Color get primary600 =>
      _isDark ? AppColors.primary600Dark : AppColors.primary600Light;

  // Secondary
  Color get secondary =>
      _isDark ? AppColors.secondaryMainDark : AppColors.secondaryMainLight;
  Color get secondary100 =>
      _isDark ? AppColors.secondary100Dark : AppColors.secondary100Light;

  // Semantic
  Color get error => _isDark ? AppColors.redMainDark : AppColors.redMainLight;
  Color get error100 => _isDark ? AppColors.red100Dark : AppColors.red100Light;
  Color get errorBg => _isDark ? AppColors.red600Dark : AppColors.red600Light;
  Color get success =>
      _isDark ? AppColors.greenMainDark : AppColors.greenMainLight;
  Color get success100 =>
      _isDark ? AppColors.green100Dark : AppColors.green100Light;
  Color get successBg =>
      _isDark ? AppColors.green600Dark : AppColors.green600Light;
  Color get warning =>
      _isDark ? AppColors.amberMainDark : AppColors.amberMainLight;
  Color get warning100 =>
      _isDark ? AppColors.amber100Dark : AppColors.amber100Light;
  Color get warningBg =>
      _isDark ? AppColors.amber600Dark : AppColors.amber600Light;
  Color get info =>
      _isDark ? AppColors.secondaryMainDark : AppColors.secondaryMainLight;

  // Grey scale
  Color get grey100 => _isDark ? AppColors.grey100Dark : AppColors.grey100Light;
  Color get grey200 => _isDark ? AppColors.grey200Dark : AppColors.grey200Light;
  Color get grey300 => _isDark ? AppColors.grey300Dark : AppColors.grey300Light;
  Color get grey400 => _isDark ? AppColors.grey400Dark : AppColors.grey400Light;
  Color get grey500 => _isDark ? AppColors.grey500Dark : AppColors.grey500Light;
  Color get grey600 => _isDark ? AppColors.grey600Dark : AppColors.grey600Light;
  Color get grey700 => _isDark ? AppColors.grey700Dark : AppColors.grey700Light;
  Color get grey800 => _isDark ? AppColors.grey800Dark : AppColors.grey800Light;
  Color get grey900 => _isDark ? AppColors.grey900Dark : AppColors.grey900Light;

  // Text
  Color get textNormal =>
      _isDark ? AppColors.textNormalDark : AppColors.textNormalLight;
  Color get textLowPriority =>
      _isDark ? AppColors.textLowPriorityDark : AppColors.textLowPriorityLight;
  Color get textDisabled => _isDark
      ? AppColors.textNormalDisabledDark
      : AppColors.textNormalDisabledLight;
  Color get textOnFilled => _isDark
      ? AppColors.textFilledButtonDark
      : AppColors.textFilledButtonLight;

  // Background
  Color get bgPrimary =>
      _isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimaryLight;
  Color get bgSecondary =>
      _isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondaryLight;
  Color get bgModal => _isDark ? AppColors.bgModalDark : AppColors.bgModalLight;
}

extension ThemeColorsExtension on BuildContext {
  SemanticColors get colors =>
      SemanticColors._(Theme.of(this).brightness == Brightness.dark);
}

extension ThemeDataExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;
}
