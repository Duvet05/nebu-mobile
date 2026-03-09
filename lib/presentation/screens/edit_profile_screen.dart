import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../providers/api_provider.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

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

      await ref.read(authProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        context.pop();
        context.showInfoSnackBar('profile.update_success'.tr());
      }
    } on Exception catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final colorScheme = Theme.of(context).colorScheme;

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
      body: Padding(
        padding: EdgeInsets.all(context.spacing.alertPadding),
        child: Column(
          children: [
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    bool enabled = true,
  }) => TextField(
    controller: controller,
    enabled: enabled,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colorScheme.primary),
      border: OutlineInputBorder(borderRadius: context.radius.input),
      focusedBorder: OutlineInputBorder(
        borderRadius: context.radius.input,
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: enabled
          ? colorScheme.surface
          : colorScheme.surface.withValues(alpha: 0.5),
    ),
  );
}
