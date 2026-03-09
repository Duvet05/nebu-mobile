import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../providers/api_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_input.dart';

/// Local avatar path, stored in secure storage.
final localAvatarProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return storage.read(key: StorageKeys.localAvatar);
});

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  bool _isUpdatingAvatar = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).value;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final user = ref.read(authProvider).value;
    if (user == null || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userService = ref.read(userServiceProvider);
      final updatedUser = await userService.updateCurrentUserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
      if (!mounted) {
        return;
      }

      await ref.read(authProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        context
          ..pop()
          ..showInfoSnackBar('profile.update_success'.tr());
      }
    } on Exception catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showAvatarOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('profile.avatar_camera'.tr()),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('profile.avatar_gallery'.tr()),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) {
      return;
    }

    await _pickAndSaveAvatar(source);
  }

  Future<void> _pickAndSaveAvatar(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null || !mounted) {
        return;
      }

      setState(() {
        _isUpdatingAvatar = true;
      });

      // Copy to app documents dir with a stable filename
      final appDir = await getApplicationDocumentsDirectory();
      final avatarFile = File('${appDir.path}/avatar.jpg');
      await File(image.path).copy(avatarFile.path);

      // Persist the path
      await ref
          .read(secureStorageProvider)
          .write(key: StorageKeys.localAvatar, value: avatarFile.path);

      // Refresh the provider so UI updates everywhere
      ref.invalidate(localAvatarProvider);

      if (mounted) {
        context.showSuccessSnackBar('profile.avatar_updated'.tr());
      }
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('profile.avatar_error'.tr());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAvatar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final localAvatar = ref.watch(localAvatarProvider).value;
    final colorScheme = context.theme.colorScheme;
    final theme = context.theme;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('profile.edit_profile'.tr())),
        body: Center(child: Text('profile.user_not_found'.tr())),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('profile.edit_profile'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _updateProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacing.alertPadding),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _isUpdatingAvatar ? null : _showAvatarOptions,
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: _isUpdatingAvatar
                        ? const Center(child: CircularProgressIndicator())
                        : _buildAvatarImage(
                            localAvatar: localAvatar,
                            networkAvatar: user.avatar,
                            name: user.name,
                            theme: theme,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: context.spacing.paragraphBottomMargin),

            _buildTextField(
              controller: _firstNameController,
              label: 'auth.first_name'.tr(),
              icon: Icons.person,
              colorScheme: colorScheme,
            ),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),
            _buildTextField(
              controller: _lastNameController,
              label: 'auth.last_name'.tr(),
              icon: Icons.person_outline,
              colorScheme: colorScheme,
            ),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),
            _buildTextField(
              controller: _emailController,
              label: 'auth.email'.tr(),
              icon: Icons.email,
              colorScheme: colorScheme,
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  /// Priority: local file > network URL > initials fallback.
  Widget _buildAvatarImage({
    required String? localAvatar,
    required String? networkAvatar,
    required String? name,
    required ThemeData theme,
  }) {
    if (localAvatar != null && File(localAvatar).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(localAvatar),
          width: 96,
          height: 96,
          fit: BoxFit.cover,
        ),
      );
    }

    if (networkAvatar != null) {
      return ClipOval(
        child: Image.network(
          networkAvatar,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitials(name, theme),
        ),
      );
    }

    return _buildInitials(name, theme);
  }

  Widget _buildInitials(String? name, ThemeData theme) => Center(
    child: Text(
      (name ?? 'U')[0].toUpperCase(),
      style: theme.textTheme.headlineLarge?.copyWith(
        color: context.colors.primary,
      ),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    bool enabled = true,
  }) => CustomInput(
    controller: controller,
    label: label,
    prefixIcon: Icon(icon, color: colorScheme.primary),
    enabled: enabled,
  );
}
