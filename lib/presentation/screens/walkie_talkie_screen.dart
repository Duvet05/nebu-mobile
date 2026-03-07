import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/toy.dart';
import '../providers/walkie_talkie_provider.dart';
import '../widgets/connection_status_indicator.dart';
import '../widgets/push_to_talk_button.dart';

class WalkieTalkieScreen extends ConsumerStatefulWidget {
  const WalkieTalkieScreen({required this.toy, super.key});

  final Toy toy;

  @override
  ConsumerState<WalkieTalkieScreen> createState() => _WalkieTalkieScreenState();
}

class _WalkieTalkieScreenState extends ConsumerState<WalkieTalkieScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSession());
  }

  Future<void> _initSession() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('walkie_talkie.mic_permission_required'.tr()),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }
    await ref.read(walkieTalkieProvider.notifier).startSession(widget.toy);
  }

  Future<void> _endSession() async {
    await ref.read(walkieTalkieProvider.notifier).endSession();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walkieTalkieProvider);
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        await _endSession();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('walkie_talkie.title'.tr())),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(context.spacing.pageMargin),
            child: Column(
              children: [
                SizedBox(height: context.spacing.panelPadding),

                // Toy info
                CircleAvatar(
                  radius: 40,
                  backgroundColor: context.colors.primary.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.smart_toy,
                    size: 48,
                    color: context.colors.primary,
                  ),
                ),
                SizedBox(height: context.spacing.paragraphBottomMarginSm),
                Text(
                  widget.toy.name,
                  style: theme.textTheme.titleLarge,
                ),

                SizedBox(height: context.spacing.panelPadding),

                // Connection status
                ConnectionStatusIndicator(
                  phase: state.phase.name,
                  isRemoteConnected: state.isRemoteConnected,
                  remoteName: state.remoteParticipantName,
                ),

                const Spacer(),

                // Main content based on phase
                if (state.phase == WalkieTalkiePhase.connecting)
                  const CircularProgressIndicator()
                else if (state.phase == WalkieTalkiePhase.error)
                  _buildErrorState(state)
                else if (state.phase == WalkieTalkiePhase.connected) ...[
                  PushToTalkButton(
                    onTalkStart: () =>
                        ref.read(walkieTalkieProvider.notifier).startTalking(),
                    onTalkEnd: () =>
                        ref.read(walkieTalkieProvider.notifier).stopTalking(),
                    isTalking: state.isTalking,
                    isEnabled: state.phase == WalkieTalkiePhase.connected,
                  ),
                  if (state.isRemoteConnected) ...[
                    SizedBox(height: context.spacing.panelPadding),
                    _buildRemoteMuteButton(state),
                  ],
                ],

                const Spacer(),

                // End session button
                if (state.phase == WalkieTalkiePhase.connected ||
                    state.phase == WalkieTalkiePhase.error)
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _endSession();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(Icons.call_end, color: context.colors.error),
                    label: Text(
                      'walkie_talkie.end_session'.tr(),
                      style: TextStyle(color: context.colors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.colors.error),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                SizedBox(height: context.spacing.panelPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRemoteMuteButton(WalkieTalkieState state) => OutlinedButton.icon(
        onPressed: () =>
            ref.read(walkieTalkieProvider.notifier).toggleRemoteMute(),
        icon: Icon(
          state.isRemoteMuted ? Icons.volume_off : Icons.volume_up,
          color: state.isRemoteMuted
              ? context.colors.error
              : context.colors.success,
        ),
        label: Text(
          state.isRemoteMuted
              ? 'walkie_talkie.unmute_toy'.tr()
              : 'walkie_talkie.mute_toy'.tr(),
          style: TextStyle(
            color: state.isRemoteMuted
                ? context.colors.error
                : context.colors.success,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: state.isRemoteMuted
                ? context.colors.error
                : context.colors.success,
          ),
        ),
      );

  Widget _buildErrorState(WalkieTalkieState state) {
    final errorKey = state.error ?? 'connection_failed';
    final translationKey = 'walkie_talkie.$errorKey';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 48, color: context.colors.error),
        SizedBox(height: context.spacing.paragraphBottomMarginSm),
        Text(
          translationKey.tr(),
          style: TextStyle(color: context.colors.error, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.spacing.sectionTitleBottomMargin),
        ElevatedButton.icon(
          onPressed: () =>
              ref.read(walkieTalkieProvider.notifier).startSession(widget.toy),
          icon: const Icon(Icons.refresh),
          label: Text('walkie_talkie.retry'.tr()),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
          ),
        ),
      ],
    );
  }
}
