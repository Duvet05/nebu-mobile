import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../providers/api_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_input.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  final bool _isUpdatingAvatar = false;

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
    if (user == null) {
      return;
    }

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

      // TODO(backend): Upload image to storage and get URL.
      // Backend accepts avatarUrl (PATCH /users/me/avatar).
      // Needs a file upload endpoint or external storage (S3/Firebase).
      context.showInfoSnackBar('profile.avatar_upload_pending'.tr());
    } on Exception {
      if (mounted) {
        context.showErrorSnackBar('profile.avatar_error'.tr());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.value;
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
          IconButton(icon: const Icon(Icons.check), onPressed: _updateProfile),
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
                        : user.avatar != null
                            ? ClipOval(
                                child: Image.network(
                                  user.avatar!,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _buildInitials(
                                    user.name,
                                    theme,
                                  ),
                                ),
                              )
                            : _buildInitials(user.name, theme),
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
