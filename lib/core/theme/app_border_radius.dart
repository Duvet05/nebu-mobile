import 'package:flutter/widgets.dart';

// ═══════════════════════════════════════════════════════════
// RAW BORDER RADIUS TOKENS (from Figma — Rounded mode)
// ═══════════════════════════════════════════════════════════

/// Raw border-radius design tokens exported from Figma (Hypr UI v1.1).
/// Mode: **Rounded**.
class AppRadius {
  AppRadius._();

  static const double input = 8;
  static const double smallInput = 6;
  static const double checkbox = 4;
  static const double modal = 16;
  static const double bottomSheet = 24;
  static const double alert = 8;
  static const double panel = 16;
  static const double tile = 8;
  static const double largeIcon = 100;
  static const double chartBar = 4;
  static const double tag = 32;
  static const double artboard = 32;
  static const double listItem = 8;
  static const double tabGroup = 40;
  static const double button = 40;
}

// ═══════════════════════════════════════════════════════════
// SEMANTIC BORDER RADIUS
// ═══════════════════════════════════════════════════════════

/// Semantic border-radius accessible via `context.radius`.
/// Provides pre-built [BorderRadius] values for each token.
class SemanticRadius {
  const SemanticRadius._();

  BorderRadius get input => BorderRadius.circular(AppRadius.input);
  BorderRadius get smallInput => BorderRadius.circular(AppRadius.smallInput);
  BorderRadius get checkbox => BorderRadius.circular(AppRadius.checkbox);
  BorderRadius get modal => BorderRadius.circular(AppRadius.modal);
  BorderRadius get bottomSheet => BorderRadius.circular(AppRadius.bottomSheet);
  BorderRadius get alert => BorderRadius.circular(AppRadius.alert);
  BorderRadius get panel => BorderRadius.circular(AppRadius.panel);
  BorderRadius get tile => BorderRadius.circular(AppRadius.tile);
  BorderRadius get largeIcon => BorderRadius.circular(AppRadius.largeIcon);
  BorderRadius get chartBar => BorderRadius.circular(AppRadius.chartBar);
  BorderRadius get tag => BorderRadius.circular(AppRadius.tag);
  BorderRadius get artboard => BorderRadius.circular(AppRadius.artboard);
  BorderRadius get listItem => BorderRadius.circular(AppRadius.listItem);
  BorderRadius get tabGroup => BorderRadius.circular(AppRadius.tabGroup);
  BorderRadius get button => BorderRadius.circular(AppRadius.button);

  /// Bottom-sheet top corners only (topLeft + topRight).
  BorderRadius get bottomSheetTop => const BorderRadius.only(
    topLeft: Radius.circular(AppRadius.bottomSheet),
    topRight: Radius.circular(AppRadius.bottomSheet),
  );
}

// ═══════════════════════════════════════════════════════════
// BUILD CONTEXT EXTENSION
// ═══════════════════════════════════════════════════════════

extension ThemeRadiusExtension on BuildContext {
  SemanticRadius get radius => const SemanticRadius._();
}
