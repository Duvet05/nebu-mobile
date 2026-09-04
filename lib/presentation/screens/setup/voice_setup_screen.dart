import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart' as auth_provider;
import '../../widgets/nebu_voice_options.dart';
import '../../widgets/setup_widgets.dart';

class VoiceSetupScreen extends ConsumerStatefulWidget {
  const VoiceSetupScreen({super.key});

  @override
  ConsumerState<VoiceSetupScreen> createState() => _VoiceSetupScreenState();
}

class _VoiceSetupScreenState extends ConsumerState<VoiceSetupScreen> {
  String? _selectedVoice;
  String? _authenticatedUserId;
  bool _isConsentLoading = true;
  bool _hasCurrentParentalConsent = false;
  bool _consentLookupFailed = false;
  bool _guardianDeclaration = false;
  bool _childDataConsent = false;
  bool _sensitiveDataConsent = false;

  bool get _allConsentDeclarationsAccepted =>
      _guardianDeclaration && _childDataConsent && _sensitiveDataConsent;

  @override
  void initState() {
    super.initState();
    _loadSavedSelection();
  }

  Future<void> _loadSavedSelection() async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    final saved = prefs.getString(StorageKeys.setupVoicePreference);
    final User? user = await ref.read(auth_provider.authProvider.future);
    final pendingConsentUserId = prefs.getString(
      StorageKeys.setupParentalConsentUserId,
    );
    final pendingConsent =
        user != null &&
        pendingConsentUserId != null &&
        user.id == pendingConsentUserId;
    var hasCurrentConsent = false;
    var lookupFailed = false;
    if (user != null) {
      try {
        hasCurrentConsent = await ref
            .read(userSetupServiceProvider)
            .hasCurrentParentalConsent(user.id);
      } on Exception catch (error, stackTrace) {
        lookupFailed = true;
        ref
            .read(loggerProvider)
            .w(
              'Could not verify parental consent',
              error: error,
              stackTrace: stackTrace,
            );
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      if (saved != null && saved.isNotEmpty) {
        _selectedVoice = saved;
      }
      _authenticatedUserId = user?.id;
      _hasCurrentParentalConsent = hasCurrentConsent;
      _consentLookupFailed = lookupFailed;
      _guardianDeclaration = pendingConsent;
      _childDataConsent = pendingConsent;
      _sensitiveDataConsent = pendingConsent;
      _isConsentLoading = false;
    });
  }

  Future<void> _saveAndContinue() async {
    if (_selectedVoice == null || _isConsentLoading) {
      return;
    }
    if (_authenticatedUserId != null &&
        !_hasCurrentParentalConsent &&
        !_allConsentDeclarationsAccepted) {
      return;
    }

    final nav = GoRouter.of(context);
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    await prefs.setString(StorageKeys.setupVoicePreference, _selectedVoice!);
    if (_authenticatedUserId != null && !_hasCurrentParentalConsent) {
      await prefs.setString(
        StorageKeys.setupParentalConsentUserId,
        _authenticatedUserId!,
      );
    } else {
      await prefs.remove(StorageKeys.setupParentalConsentUserId);
    }
    if (mounted) {
      await nav.push(AppRoutes.favoritesSetup.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final canProceed =
        _selectedVoice != null &&
        !_isConsentLoading &&
        (_authenticatedUserId == null ||
            _hasCurrentParentalConsent ||
            _allConsentDeclarationsAccepted);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SetupHeader(currentStep: 6, totalSteps: 7),

            // Content
            Expanded(
              child: Padding(
                padding: context.constrainedPageEdgeInsets,
                child: Column(
                  children: [
                    SizedBox(height: context.spacing.titleBottomMargin),

                    Text(
                      'setup.voice.title'.tr(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    Text(
                      'setup.voice.subtitle'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Voice options and the adult-controlled consent gate.
                    Expanded(
                      child: ListView(
                        children: [
                          for (final voice in nebuVoiceOptions)
                            _buildVoiceOption(context, voice),
                          SizedBox(height: context.spacing.gapSm),
                          _buildConsentCard(context),
                          SizedBox(height: context.spacing.gapLg),
                        ],
                      ),
                    ),

                    SetupPrimaryButton(
                      text: 'common.next'.tr(),
                      isEnabled: canProceed,
                      onPressed: _saveAndContinue,
                    ),

                    SizedBox(height: context.spacing.sectionTitleBottomMargin),

                    SetupSkipButton(
                      onTap: () => context.go(AppRoutes.home.path),
                    ),

                    SizedBox(height: context.spacing.panelPadding),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceOption(BuildContext context, NebuVoiceOption voice) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedVoice == voice.id;

    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.gapLg),
      child: Semantics(
        button: true,
        label: voice.labelKey.tr(),
        selected: isSelected,
        child: GestureDetector(
          onTap: () => setState(() => _selectedVoice = voice.id),
          child: Container(
            padding: EdgeInsets.all(context.spacing.gapXl),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colors.primary.withValues(alpha: 0.08)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: context.radius.panel,
              border: Border.all(
                color: isSelected
                    ? context.colors.primary
                    : colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.primary.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: context.radius.panel,
                  ),
                  child: Icon(
                    voice.icon,
                    size: 24,
                    color: isSelected
                        ? context.colors.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: context.spacing.gapXl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voice.labelKey.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? context.colors.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: context.spacing.gapXs),
                      Text(
                        voice.descriptionKey.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? context.colors.primary.withValues(alpha: 0.7)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: context.colors.textOnFilled,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsentCard(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    if (_isConsentLoading) {
      return Container(
        key: const ValueKey<String>('voiceConsent.loading'),
        padding: EdgeInsets.all(context.spacing.panelPadding),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: context.radius.panel,
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_authenticatedUserId == null) {
      return _ConsentNotice(
        key: const ValueKey<String>('voiceConsent.guestNotice'),
        icon: Icons.account_circle_outlined,
        title: 'setup.voice.consent_guest_title'.tr(),
        message: 'setup.voice.consent_guest_message'.tr(),
      );
    }

    if (_hasCurrentParentalConsent) {
      return _ConsentNotice(
        key: const ValueKey<String>('voiceConsent.current'),
        icon: Icons.verified_user_outlined,
        title: 'setup.voice.consent_current_title'.tr(),
        message: 'setup.voice.consent_current_message'.tr(),
      );
    }

    return Container(
      key: const ValueKey<String>('voiceConsent.required'),
      padding: EdgeInsets.all(context.spacing.gapLg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: context.radius.panel,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'setup.voice.consent_title'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.spacing.gapSm),
          Text(
            (_consentLookupFailed
                    ? 'setup.voice.consent_verify_failed'
                    : 'setup.voice.consent_message')
                .tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          _consentCheckbox(
            key: 'voiceConsent.guardian',
            value: _guardianDeclaration,
            label: 'setup.voice.consent_guardian'.tr(),
            onChanged: (value) => setState(() => _guardianDeclaration = value),
          ),
          _consentCheckbox(
            key: 'voiceConsent.childData',
            value: _childDataConsent,
            label: 'setup.voice.consent_child_data'.tr(),
            onChanged: (value) => setState(() => _childDataConsent = value),
          ),
          _consentCheckbox(
            key: 'voiceConsent.sensitiveData',
            value: _sensitiveDataConsent,
            label: 'setup.voice.consent_sensitive_data'.tr(),
            onChanged: (value) => setState(() => _sensitiveDataConsent = value),
          ),
          Wrap(
            spacing: context.spacing.gapSm,
            children: [
              TextButton(
                key: const ValueKey<String>('voiceConsent.privacyLink'),
                onPressed: () => context.push(AppRoutes.privacyPolicy.path),
                child: Text('setup.voice.review_privacy'.tr()),
              ),
              TextButton(
                key: const ValueKey<String>('voiceConsent.termsLink'),
                onPressed: () => context.push(AppRoutes.termsOfService.path),
                child: Text('setup.voice.review_terms'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _consentCheckbox({
    required String key,
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
  }) => Material(
    type: MaterialType.transparency,
    child: CheckboxListTile(
      key: ValueKey<String>(key),
      value: value,
      onChanged: (checked) => onChanged(checked ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
    ),
  );
}

class _ConsentNotice extends StatelessWidget {
  const _ConsentNotice({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.spacing.panelPadding),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.08),
        borderRadius: context.radius.panel,
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.colors.primary),
          SizedBox(width: context.spacing.gapLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.spacing.gapXs),
                Text(message, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
