import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/person.dart';
import '../../data/models/toy.dart';
import '../../data/services/local_child_data_service.dart';
import '../providers/api_provider.dart';
import '../providers/person_provider.dart';
import '../providers/toy_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class PersonsScreen extends ConsumerStatefulWidget {
  const PersonsScreen({super.key});

  @override
  ConsumerState<PersonsScreen> createState() => _PersonsScreenState();
}

class _PersonsScreenState extends ConsumerState<PersonsScreen> {
  bool _didLoad = false;
  bool _syncDismissed = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    await ref.read(personProvider.notifier).loadMyPersons();
  }

  @override
  Widget build(BuildContext context) {
    final personsState = ref.watch(personProvider);
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'persons.title'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: personsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(context, error),
        data: (persons) => _buildDataState(context, persons),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.colors.primary,
        onPressed: () => _showPersonForm(context),
        tooltip: 'persons.add_child'.tr(),
        child: ExcludeSemantics(
          child: Icon(Icons.add, color: context.colors.textOnFilled),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) => Center(
    child: Padding(
      padding: context.spacing.pageEdgeInsets,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: context.colors.error),
          SizedBox(height: context.spacing.titleBottomMargin),
          Text(
            'persons.error_loading'.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge,
          ),
          SizedBox(height: context.spacing.paragraphBottomMargin),
          CustomButton(
            text: 'common.retry'.tr(),
            onPressed: () => ref.read(personProvider.notifier).loadMyPersons(),
            variant: ButtonVariant.outline,
          ),
        ],
      ),
    ),
  );

  Widget _buildDataState(BuildContext context, List<Person> persons) {
    if (persons.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(personProvider.notifier).loadMyPersons(),
      child: ListView(
        padding: context.spacing.pageEdgeInsets,
        children: [
          // Sync banner
          if (!_syncDismissed) _buildSyncBanner(context),

          // Person cards
          for (final person in persons) ...[
            _PersonCard(
              person: person,
              onEdit: () => _showPersonForm(context, person: person),
              onDelete: () => _confirmDelete(context, person),
              onAssignToy: () => _showToyAssignment(context, person),
            ),
            SizedBox(height: context.spacing.gapLg),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) => Center(
    child: Padding(
      padding: context.spacing.pageEdgeInsets,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sync banner at top if applicable
          if (!_syncDismissed) _buildSyncBanner(context),

          Icon(Icons.family_restroom, size: 80, color: context.colors.grey500),
          SizedBox(height: context.spacing.titleBottomMargin),
          Text(
            'persons.empty_title'.tr(),
            style: context.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.spacing.paragraphBottomMarginSm),
          Text(
            'persons.empty_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.grey500,
            ),
          ),
          SizedBox(height: context.spacing.paragraphBottomMargin),
          CustomButton(
            text: 'persons.add_child'.tr(),
            onPressed: () => _showPersonForm(context),
            icon: Icons.add,
          ),
        ],
      ),
    ),
  );

  Widget _buildSyncBanner(BuildContext context) {
    final localChildService = ref.watch(localChildDataServiceProvider);

    return localChildService.when(
      data: (service) {
        if (!service.hasChildData()) {
          return const SizedBox.shrink();
        }

        final childName =
            service.getChildName() ?? 'persons.default_child'.tr();
        return Container(
          margin: EdgeInsets.only(bottom: context.spacing.panelPadding),
          padding: EdgeInsets.all(context.spacing.alertPadding),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.08),
            borderRadius: context.radius.panel,
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sync, color: context.colors.primary, size: 20),
                  SizedBox(width: context.spacing.gapMd),
                  Expanded(
                    child: Text(
                      'persons.sync_banner_title'.tr(args: [childName]),
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: context.colors.grey400,
                    ),
                    tooltip: 'persons.sync_dismiss'.tr(),
                    onPressed: () {
                      setState(() => _syncDismissed = true);
                    },
                  ),
                ],
              ),
              SizedBox(height: context.spacing.gapMd),
              Text(
                'persons.sync_banner_message'.tr(),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textNormal,
                ),
              ),
              SizedBox(height: context.spacing.gapLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'persons.sync_dismiss'.tr(),
                    variant: ButtonVariant.text,
                    onPressed: () {
                      setState(() => _syncDismissed = true);
                    },
                  ),
                  SizedBox(width: context.spacing.gapMd),
                  CustomButton(
                    text: 'persons.sync_now'.tr(),
                    isLoading: _isSyncing,
                    onPressed: _isSyncing
                        ? null
                        : () => _syncLocalData(service),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Future<void> _syncLocalData(LocalChildDataService service) async {
    if (_isSyncing) {
      return;
    }
    setState(() => _isSyncing = true);
    try {
      final name = service.getChildName();
      final person = await ref
          .read(personProvider.notifier)
          .createPerson(givenName: name);

      await service.clearChildData();

      if (!mounted) {
        return;
      }
      setState(() {
        _syncDismissed = true;
        _isSyncing = false;
      });
      context.showSuccessSnackBar(
        'persons.sync_success'.tr(args: [person.givenName ?? '']),
      );
    } on Exception catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSyncing = false);
      context.showErrorSnackBar('persons.save_error'.tr());
    }
  }

  Future<void> _showPersonForm(BuildContext context, {Person? person}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.spacing.panelPadding),
        ),
      ),
      builder: (ctx) =>
          SafeArea(top: false, child: _PersonFormSheet(person: person)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Person person) async {
    final name = person.givenName ?? 'persons.default_child'.tr();
    final confirmed = await showConfirmDialog(
      context,
      title: 'persons.confirm_delete_title'.tr(),
      content: 'persons.confirm_delete_message'.tr(args: [name]),
      destructive: true,
    );

    if (!confirmed || !mounted) {
      return;
    }

    try {
      // Collect toys to unassign BEFORE deleting the person
      // Use pattern-matching to avoid ?? [] masking an error state
      final toysToUnassign = switch (ref.read(toyProvider)) {
        AsyncData(:final value) =>
          value.where((t) => t.ownerId == person.id).toList(),
        _ => <Toy>[],
      };

      await ref.read(personProvider.notifier).deletePerson(person.id);

      // Best-effort unassign — continue on individual failure
      for (final toy in toysToUnassign) {
        if (!mounted) {
          return;
        }
        try {
          await ref
              .read(toyProvider.notifier)
              .updateToy(id: toy.id, ownerId: '');
        } on Exception catch (_) {
          // Person already deleted; log but continue with remaining toys
        }
      }

      if (!context.mounted) {
        return;
      }
      context.showSuccessSnackBar('persons.deleted'.tr(args: [name]));
    } on Exception catch (_) {
      if (!context.mounted) {
        return;
      }
      context.showErrorSnackBar('persons.delete_error'.tr());
    }
  }

  Future<void> _showToyAssignment(BuildContext context, Person person) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.spacing.panelPadding),
        ),
      ),
      builder: (ctx) =>
          SafeArea(top: false, child: _ToyAssignmentSheet(person: person)),
    );
  }
}

// ─── Person Card ──────────────────────────────────────────────────────────────

class _PersonCard extends ConsumerWidget {
  const _PersonCard({
    required this.person,
    required this.onEdit,
    required this.onDelete,
    required this.onAssignToy,
  });

  final Person person;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAssignToy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final toys = ref.watch(toyProvider).value ?? [];
    final assignedToys = toys.where((t) => t.ownerId == person.id).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: context.radius.panel,
        boxShadow: [
          BoxShadow(
            color: context.colors.textNormal.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.spacing.panelPadding,
              vertical: context.spacing.gapMd,
            ),
            leading: ExcludeSemantics(
              child: CircleAvatar(
                backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                child: Text(
                  _initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            title: Text(
              _displayName(context),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: _subtitle(context),
            trailing: PopupMenuButton<String>(
              tooltip: 'common.edit'.tr(),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                  case 'assign':
                    onAssignToy();
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: context.spacing.gapMd),
                      Text('common.edit'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'assign',
                  child: Row(
                    children: [
                      const Icon(Icons.toys_outlined, size: 20),
                      SizedBox(width: context.spacing.gapMd),
                      Text('persons.assign_toy'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: context.colors.error,
                      ),
                      SizedBox(width: context.spacing.gapMd),
                      Text(
                        'common.delete'.tr(),
                        style: TextStyle(color: context.colors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Assigned toys
          if (assignedToys.isNotEmpty) ...[
            Divider(height: 1, color: theme.dividerColor),
            Padding(
              padding: EdgeInsets.all(context.spacing.panelPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'persons.assigned_toys'.tr(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: context.colors.grey500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.spacing.gapMd),
                  Wrap(
                    spacing: context.spacing.gapMd,
                    runSpacing: context.spacing.gapMd,
                    children: assignedToys
                        .map(
                          (toy) => Chip(
                            avatar: Icon(
                              Icons.smart_toy,
                              size: 16,
                              color: context.colors.primary,
                            ),
                            label: Text(toy.name),
                            backgroundColor: context.colors.primary.withValues(
                              alpha: 0.08,
                            ),
                            labelStyle: theme.textTheme.labelMedium?.copyWith(
                              color: context.colors.primary,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: context.colors.primary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get _initials {
    final g = person.givenName;
    final f = person.familyName;
    if (g != null && g.isNotEmpty && f != null && f.isNotEmpty) {
      return '${g[0]}${f[0]}'.toUpperCase();
    }
    if (g != null && g.isNotEmpty) {
      return g[0].toUpperCase();
    }
    return '?';
  }

  String _displayName(BuildContext context) {
    final parts = <String>[
      if (person.givenName != null && person.givenName!.isNotEmpty)
        person.givenName!,
      if (person.familyName != null && person.familyName!.isNotEmpty)
        person.familyName!,
    ];
    return parts.isNotEmpty ? parts.join(' ') : 'persons.default_child'.tr();
  }

  Widget? _subtitle(BuildContext context) {
    final parts = <String>[];
    if (person.gender != null && person.gender!.isNotEmpty) {
      parts.add(person.gender!);
    }
    if (person.birthDate != null) {
      parts.add(DateFormat.yMMMd().format(person.birthDate!));
    }
    if (parts.isEmpty) {
      return null;
    }
    return Text(
      parts.join(' · '),
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colors.grey500,
      ),
    );
  }
}

// ─── Person Form Sheet ────────────────────────────────────────────────────────

class _PersonFormSheet extends ConsumerStatefulWidget {
  const _PersonFormSheet({this.person});

  final Person? person;

  @override
  ConsumerState<_PersonFormSheet> createState() => _PersonFormSheetState();
}

class _PersonFormSheetState extends ConsumerState<_PersonFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _givenNameController;
  late final TextEditingController _familyNameController;
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  bool _isSaving = false;

  bool get _isEditing => widget.person != null;

  @override
  void initState() {
    super.initState();
    _givenNameController = TextEditingController(
      text: widget.person?.givenName ?? '',
    );
    _familyNameController = TextEditingController(
      text: widget.person?.familyName ?? '',
    );
    _selectedGender = widget.person?.gender;
    _selectedBirthDate = widget.person?.birthDate;
  }

  @override
  void dispose() {
    _givenNameController.dispose();
    _familyNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final givenName = _givenNameController.text.trim();
      final familyName = _familyNameController.text.trim();

      if (_isEditing) {
        await ref
            .read(personProvider.notifier)
            .updatePerson(
              id: widget.person!.id,
              givenName: givenName.isNotEmpty ? givenName : null,
              familyName: familyName.isNotEmpty ? familyName : null,
              gender: _selectedGender,
              birthDate: _selectedBirthDate,
            );
      } else {
        await ref
            .read(personProvider.notifier)
            .createPerson(
              givenName: givenName.isNotEmpty ? givenName : null,
              familyName: familyName.isNotEmpty ? familyName : null,
              gender: _selectedGender,
              birthDate: _selectedBirthDate,
            );
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      context.showSuccessSnackBar(
        _isEditing ? 'persons.updated'.tr() : 'persons.created'.tr(),
      );
    } on Exception catch (_) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar('persons.save_error'.tr());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(now.year - 5),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: EdgeInsets.only(
        left: context.spacing.panelPadding,
        right: context.spacing.panelPadding,
        top: context.spacing.panelPadding,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            context.spacing.panelPadding,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.grey400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const SizedBox(width: 40, height: 4),
                ),
              ),
              SizedBox(height: context.spacing.titleBottomMargin),

              // Title
              Text(
                _isEditing
                    ? 'persons.edit_child'.tr()
                    : 'persons.add_child'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.spacing.paragraphBottomMargin),

              // Given name
              CustomInput(
                controller: _givenNameController,
                label: 'persons.given_name'.tr(),
                prefixIcon: const Icon(Icons.person_outline),
                enabled: !_isSaving,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'persons.name_required'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: context.spacing.titleBottomMargin),

              // Family name
              CustomInput(
                controller: _familyNameController,
                label: 'persons.family_name'.tr(),
                prefixIcon: const Icon(Icons.people_outline),
                enabled: !_isSaving,
              ),
              SizedBox(height: context.spacing.titleBottomMargin),

              // Gender dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'persons.gender'.tr(),
                  prefixIcon: const Icon(Icons.wc_outlined),
                  border: OutlineInputBorder(
                    borderRadius: context.radius.input,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text('persons.gender_male'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text('persons.gender_female'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('persons.gender_other'.tr()),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() => _selectedGender = value);
                      },
              ),
              SizedBox(height: context.spacing.titleBottomMargin),

              // Birth date picker
              InkWell(
                onTap: _isSaving ? null : _pickBirthDate,
                borderRadius: context.radius.input,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'persons.birth_date'.tr(),
                    prefixIcon: const Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(
                      borderRadius: context.radius.input,
                    ),
                  ),
                  child: Text(
                    _selectedBirthDate != null
                        ? DateFormat.yMMMd().format(_selectedBirthDate!)
                        : 'persons.select_date'.tr(),
                    style: _selectedBirthDate != null
                        ? theme.textTheme.bodyLarge
                        : theme.textTheme.bodyLarge?.copyWith(
                            color: context.colors.grey500,
                          ),
                  ),
                ),
              ),
              SizedBox(height: context.spacing.paragraphBottomMargin),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'common.cancel'.tr(),
                      variant: ButtonVariant.outline,
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ),
                  SizedBox(width: context.spacing.gapLg),
                  Expanded(
                    child: CustomButton(
                      text: _isEditing
                          ? 'common.save'.tr()
                          : 'persons.add_child'.tr(),
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Toy Assignment Sheet ─────────────────────────────────────────────────────

class _ToyAssignmentSheet extends ConsumerStatefulWidget {
  const _ToyAssignmentSheet({required this.person});

  final Person person;

  @override
  ConsumerState<_ToyAssignmentSheet> createState() =>
      _ToyAssignmentSheetState();
}

class _ToyAssignmentSheetState extends ConsumerState<_ToyAssignmentSheet> {
  String? _savingToyId;

  Future<void> _toggleAssignment(Toy toy) async {
    if (_savingToyId != null) {
      return;
    }

    final isAssigned = toy.ownerId == widget.person.id;
    setState(() => _savingToyId = toy.id);

    try {
      // Skip API for local toys
      if (toy.id.startsWith('local_')) {
        if (!mounted) {
          return;
        }
        context.showErrorSnackBar('persons.local_toy_no_assign'.tr());
        return;
      }

      await ref
          .read(toyProvider.notifier)
          .updateToy(id: toy.id, ownerId: isAssigned ? '' : widget.person.id);

      if (!mounted) {
        return;
      }
      context.showSuccessSnackBar(
        isAssigned
            ? 'persons.toy_unassigned'.tr(args: [toy.name])
            : 'persons.toy_assigned'.tr(args: [toy.name]),
      );
    } on Exception catch (_) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar('persons.assign_error'.tr());
    } finally {
      if (mounted) {
        setState(() => _savingToyId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final toys = ref.watch(toyProvider).value ?? [];

    return Padding(
      padding: EdgeInsets.all(context.spacing.panelPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.grey400,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const SizedBox(width: 40, height: 4),
            ),
          ),
          SizedBox(height: context.spacing.titleBottomMargin),

          Text(
            'persons.assign_toy_title'.tr(
              args: [widget.person.givenName ?? 'persons.default_child'.tr()],
            ),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.spacing.paragraphBottomMarginSm),

          if (toys.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: context.spacing.paragraphBottomMargin,
              ),
              child: Center(
                child: Text(
                  'persons.no_toys_to_assign'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: context.colors.grey500,
                  ),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: toys.map((toy) {
                    final isAssigned = toy.ownerId == widget.person.id;
                    final isSaving = _savingToyId == toy.id;

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: context.spacing.gapMd,
                      ),
                      leading: Icon(
                        Icons.smart_toy,
                        color: isAssigned
                            ? context.colors.primary
                            : context.colors.grey400,
                      ),
                      title: Text(
                        toy.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isAssigned ? FontWeight.w600 : null,
                        ),
                      ),
                      subtitle:
                          toy.ownerId != null &&
                              toy.ownerId!.isNotEmpty &&
                              toy.ownerId != widget.person.id
                          ? Text(
                              'persons.assigned_elsewhere'.tr(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: context.colors.grey500,
                              ),
                            )
                          : null,
                      trailing: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Checkbox(
                              value: isAssigned,
                              onChanged: _savingToyId != null
                                  ? null
                                  : (_) => _toggleAssignment(toy),
                              activeColor: context.colors.primary,
                            ),
                      onTap: _savingToyId != null
                          ? null
                          : () => _toggleAssignment(toy),
                    );
                  }).toList(),
                ),
              ),
            ),

          SizedBox(height: context.spacing.panelPadding),
        ],
      ),
    );
  }
}
