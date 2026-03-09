import 'package:flutter/widgets.dart';

// ═══════════════════════════════════════════════════════════
// SCREEN SIZE RESOLUTION
// ═══════════════════════════════════════════════════════════

enum _ScreenSize { small, normal, large }

_ScreenSize _resolveScreenSize(double width) {
  if (width < 360) {
    return _ScreenSize.small;
  }
  if (width < 600) {
    return _ScreenSize.normal;
  }
  return _ScreenSize.large;
}

// ═══════════════════════════════════════════════════════════
// RAW SPACING TOKENS (from Figma)
// ═══════════════════════════════════════════════════════════

/// Raw spacing design tokens exported from Figma.
/// Three screen-size modes: Small (<360dp), Default (360–599dp), Large (≥600dp).
class AppSpacing {
  AppSpacing._();

  // --- Page margins ---
  static const double pageMarginSm = 16;
  static const double pageMarginDf = 20;
  static const double pageMarginLg = 24;

  static const double largePageBottomMarginSm = 32;
  static const double largePageBottomMarginDf = 40;
  static const double largePageBottomMarginLg = 52;

  static const double buttonBottomMarginSm = 8;
  static const double buttonBottomMarginDf = 8;
  static const double buttonBottomMarginLg = 12;

  // --- Input / label ---
  static const double inputBottomMarginSm = 16;
  static const double inputBottomMarginDf = 20;
  static const double inputBottomMarginLg = 24;

  static const double labelBottomMarginSm = 6;
  static const double labelBottomMarginDf = 8;
  static const double labelBottomMarginLg = 12;

  // --- Panel / modal / alert ---
  static const double panelPaddingSm = 16;
  static const double panelPaddingDf = 20;
  static const double panelPaddingLg = 24;

  static const double smallPanelPaddingSm = 8;
  static const double smallPanelPaddingDf = 12;
  static const double smallPanelPaddingLg = 20;

  static const double modalPaddingSm = 20;
  static const double modalPaddingDf = 24;
  static const double modalPaddingLg = 32;

  static const double alertPaddingSm = 16;
  static const double alertPaddingDf = 16;
  static const double alertPaddingLg = 16;

  // --- List items ---
  static const double listItemHPaddingSm = 12;
  static const double listItemHPaddingDf = 20;
  static const double listItemHPaddingLg = 24;

  static const double listItemVPaddingSm = 12;
  static const double listItemVPaddingDf = 16;
  static const double listItemVPaddingLg = 20;

  // --- Title / paragraph / section ---
  static const double titleBottomMarginSm = 16;
  static const double titleBottomMarginDf = 20;
  static const double titleBottomMarginLg = 28;

  static const double titleBottomMarginSmSm = 4;
  static const double titleBottomMarginSmDf = 8;
  static const double titleBottomMarginSmLg = 12;

  static const double paragraphBottomMarginSm = 24;
  static const double paragraphBottomMarginDf = 32;
  static const double paragraphBottomMarginLg = 40;

  static const double paragraphBottomMarginSmSm = 8;
  static const double paragraphBottomMarginSmDf = 12;
  static const double paragraphBottomMarginSmLg = 16;

  static const double sectionTitleBottomMarginSm = 12;
  static const double sectionTitleBottomMarginDf = 16;
  static const double sectionTitleBottomMarginLg = 20;

  static const double sectionTitleTopMarginSm = 16;
  static const double sectionTitleTopMarginDf = 20;
  static const double sectionTitleTopMarginLg = 24;

  // --- Snackbar ---
  static const double snackbarBottomSpaceSm = 80;
  static const double snackbarBottomSpaceDf = 80;
  static const double snackbarBottomSpaceLg = 80;

  // --- Generic gaps (flat: same across screen sizes) ---
  static const double gapXxs = 2;
  static const double gapXs = 4;
  static const double gapSm = 6;
  static const double gapMd = 8;

  // --- Generic gaps (responsive) ---
  static const double gapLgSm = 10;
  static const double gapLgDf = 12;
  static const double gapLgLg = 16;

  static const double gapXlSm = 14;
  static const double gapXlDf = 16;
  static const double gapXlLg = 20;

  static const double gapXxlSm = 20;
  static const double gapXxlDf = 24;
  static const double gapXxlLg = 32;
}

// ═══════════════════════════════════════════════════════════
// SEMANTIC SPACING (theme-aware, resolves by screen size)
// ═══════════════════════════════════════════════════════════

/// Theme-aware semantic spacing accessible via `context.spacing`.
/// Automatically resolves small / default / large variants based on screen width.
class SemanticSpacing {
  SemanticSpacing._(this._size);

  final _ScreenSize _size;

  double _resolve(double small, double normal, double large) {
    switch (_size) {
      case _ScreenSize.small:
        return small;
      case _ScreenSize.normal:
        return normal;
      case _ScreenSize.large:
        return large;
    }
  }

  // --- Page margins ---
  double get pageMargin => _resolve(
        AppSpacing.pageMarginSm,
        AppSpacing.pageMarginDf,
        AppSpacing.pageMarginLg,
      );
  double get largePageBottomMargin => _resolve(
        AppSpacing.largePageBottomMarginSm,
        AppSpacing.largePageBottomMarginDf,
        AppSpacing.largePageBottomMarginLg,
      );
  double get buttonBottomMargin => _resolve(
        AppSpacing.buttonBottomMarginSm,
        AppSpacing.buttonBottomMarginDf,
        AppSpacing.buttonBottomMarginLg,
      );

  // --- Input / label ---
  double get inputBottomMargin => _resolve(
        AppSpacing.inputBottomMarginSm,
        AppSpacing.inputBottomMarginDf,
        AppSpacing.inputBottomMarginLg,
      );
  double get labelBottomMargin => _resolve(
        AppSpacing.labelBottomMarginSm,
        AppSpacing.labelBottomMarginDf,
        AppSpacing.labelBottomMarginLg,
      );

  // --- Panel / modal / alert ---
  double get panelPadding => _resolve(
        AppSpacing.panelPaddingSm,
        AppSpacing.panelPaddingDf,
        AppSpacing.panelPaddingLg,
      );
  double get smallPanelPadding => _resolve(
        AppSpacing.smallPanelPaddingSm,
        AppSpacing.smallPanelPaddingDf,
        AppSpacing.smallPanelPaddingLg,
      );
  double get modalPadding => _resolve(
        AppSpacing.modalPaddingSm,
        AppSpacing.modalPaddingDf,
        AppSpacing.modalPaddingLg,
      );
  double get alertPadding => _resolve(
        AppSpacing.alertPaddingSm,
        AppSpacing.alertPaddingDf,
        AppSpacing.alertPaddingLg,
      );

  // --- List items ---
  double get listItemHPadding => _resolve(
        AppSpacing.listItemHPaddingSm,
        AppSpacing.listItemHPaddingDf,
        AppSpacing.listItemHPaddingLg,
      );
  double get listItemVPadding => _resolve(
        AppSpacing.listItemVPaddingSm,
        AppSpacing.listItemVPaddingDf,
        AppSpacing.listItemVPaddingLg,
      );

  // --- Title / paragraph / section ---
  double get titleBottomMargin => _resolve(
        AppSpacing.titleBottomMarginSm,
        AppSpacing.titleBottomMarginDf,
        AppSpacing.titleBottomMarginLg,
      );
  double get titleBottomMarginSm => _resolve(
        AppSpacing.titleBottomMarginSmSm,
        AppSpacing.titleBottomMarginSmDf,
        AppSpacing.titleBottomMarginSmLg,
      );
  double get paragraphBottomMargin => _resolve(
        AppSpacing.paragraphBottomMarginSm,
        AppSpacing.paragraphBottomMarginDf,
        AppSpacing.paragraphBottomMarginLg,
      );
  double get paragraphBottomMarginSm => _resolve(
        AppSpacing.paragraphBottomMarginSmSm,
        AppSpacing.paragraphBottomMarginSmDf,
        AppSpacing.paragraphBottomMarginSmLg,
      );
  double get sectionTitleBottomMargin => _resolve(
        AppSpacing.sectionTitleBottomMarginSm,
        AppSpacing.sectionTitleBottomMarginDf,
        AppSpacing.sectionTitleBottomMarginLg,
      );
  double get sectionTitleTopMargin => _resolve(
        AppSpacing.sectionTitleTopMarginSm,
        AppSpacing.sectionTitleTopMarginDf,
        AppSpacing.sectionTitleTopMarginLg,
      );

  // --- Snackbar ---
  double get snackbarBottomSpace => _resolve(
        AppSpacing.snackbarBottomSpaceSm,
        AppSpacing.snackbarBottomSpaceDf,
        AppSpacing.snackbarBottomSpaceLg,
      );

  // --- Generic gaps ---
  double get gapXxs => AppSpacing.gapXxs;
  double get gapXs => AppSpacing.gapXs;
  double get gapSm => AppSpacing.gapSm;
  double get gapMd => AppSpacing.gapMd;
  double get gapLg => _resolve(
        AppSpacing.gapLgSm,
        AppSpacing.gapLgDf,
        AppSpacing.gapLgLg,
      );
  double get gapXl => _resolve(
        AppSpacing.gapXlSm,
        AppSpacing.gapXlDf,
        AppSpacing.gapXlLg,
      );
  double get gapXxl => _resolve(
        AppSpacing.gapXxlSm,
        AppSpacing.gapXxlDf,
        AppSpacing.gapXxlLg,
      );

  // ═══════════════════════════════════════════════════════════
  // CONVENIENCE EdgeInsets GETTERS
  // ═══════════════════════════════════════════════════════════

  EdgeInsets get pageEdgeInsets =>
      EdgeInsets.symmetric(horizontal: pageMargin);

  EdgeInsets get panelEdgeInsets => EdgeInsets.all(panelPadding);

  EdgeInsets get smallPanelEdgeInsets => EdgeInsets.all(smallPanelPadding);

  EdgeInsets get modalEdgeInsets => EdgeInsets.all(modalPadding);

  EdgeInsets get alertEdgeInsets => EdgeInsets.all(alertPadding);

  EdgeInsets get listItemEdgeInsets =>
      EdgeInsets.symmetric(horizontal: listItemHPadding, vertical: listItemVPadding);
}

// ═══════════════════════════════════════════════════════════
// BUILD CONTEXT EXTENSION
// ═══════════════════════════════════════════════════════════

extension ThemeSpacingExtension on BuildContext {
  SemanticSpacing get spacing => SemanticSpacing._(
        _resolveScreenSize(MediaQuery.sizeOf(this).width),
      );
}
