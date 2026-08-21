import 'package:flutter/material.dart';

import '../../../../../core/constants/reference_data.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../domain/params/teacher_query_params.dart';

/// The editor behind the search field's filter button.
///
/// Pops the query to apply, or `null` when it is dismissed — the caller keeps
/// what it had, so backing out changes nothing. `search`, `limit` and the rest
/// of the query ride along untouched: this sheet only owns the narrowing
/// filters and the sort order.
abstract final class TeacherFilterSheet {
  static Future<TeacherQueryParams?> show(
    BuildContext context, {
    required TeacherQueryParams query,
  }) {
    return showModalBottomSheet<TeacherQueryParams>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (context) => _TeacherFilterSheet(query: query),
    );
  }
}

class _TeacherFilterSheet extends StatefulWidget {
  const _TeacherFilterSheet({required this.query});

  final TeacherQueryParams query;

  @override
  State<_TeacherFilterSheet> createState() => _TeacherFilterSheetState();
}

class _TeacherFilterSheetState extends State<_TeacherFilterSheet> {
  /// A working copy. Nothing here reaches the list until "Show teachers" is
  /// tapped, so the list does not re-fetch on every chip.
  late List<String> _subjects = [...widget.query.subjects];
  late List<String> _classes = [...widget.query.classes];
  late List<String> _languages = [...widget.query.languages];
  late String _gender = widget.query.gender;
  late bool? _hasProfilePhoto = widget.query.hasProfilePhoto;
  late TeacherSortOrder _sortOrder = widget.query.sortOrder;

  late final TextEditingController _cityController = TextEditingController(
    text: widget.query.city,
  );

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  bool get _hasSelection =>
      _subjects.isNotEmpty ||
      _classes.isNotEmpty ||
      _languages.isNotEmpty ||
      _gender.isNotEmpty ||
      _hasProfilePhoto != null ||
      _cityController.text.trim().isNotEmpty ||
      _sortOrder != TeacherSortOrder.desc;

  void _reset() => setState(() {
    _subjects = [];
    _classes = [];
    _languages = [];
    _gender = '';
    _hasProfilePhoto = null;
    _sortOrder = TeacherSortOrder.desc;
    _cityController.clear();
  });

  void _apply() {
    Navigator.of(context).pop(
      widget.query.copyWith(
        // Filters changed means the pages already held describe a different
        // result set — the caller reloads from the top.
        page: 1,
        subjects: _subjects,
        classes: _classes,
        languages: _languages,
        gender: _gender,
        city: _cityController.text.trim(),
        sortOrder: _sortOrder,
        hasProfilePhoto: _hasProfilePhoto,
        clearHasProfilePhoto: _hasProfilePhoto == null,
      ),
    );
  }

  /// Adds or removes [option] from a multi-value group.
  List<String> _toggled(List<String> values, String option, bool isSelected) =>
      isSelected
      ? [...values, option]
      : [...values.where((value) => value != option)];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        // Lifts the sheet clear of the keyboard the city field raises.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Filters', style: theme.textTheme.titleLarge),
                    ),
                    // Listens to the city field so the button enables on the
                    // first character typed, without rebuilding the chips.
                    ListenableBuilder(
                      listenable: _cityController,
                      builder: (context, _) => TextButton(
                        onPressed: _hasSelection ? _reset : null,
                        child: const Text('Reset'),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.xs,
                    AppSpacing.xxl,
                    AppSpacing.lg,
                  ),
                  children: [
                    _FilterGroup(
                      label: 'Subjects',
                      child: _ChipWrap(
                        options: ReferenceData.subjects,
                        selected: _subjects,
                        onToggled: (option, isSelected) => setState(
                          () => _subjects = _toggled(
                            _subjects,
                            option,
                            isSelected,
                          ),
                        ),
                      ),
                    ),
                    _FilterGroup(
                      label: 'Classes',
                      child: _ChipWrap(
                        options: ReferenceData.classes,
                        selected: _classes,
                        onToggled: (option, isSelected) => setState(
                          () =>
                              _classes = _toggled(_classes, option, isSelected),
                        ),
                      ),
                    ),
                    _FilterGroup(
                      label: 'Languages',
                      child: _ChipWrap(
                        options: ReferenceData.languages,
                        selected: _languages,
                        onToggled: (option, isSelected) => setState(
                          () => _languages = _toggled(
                            _languages,
                            option,
                            isSelected,
                          ),
                        ),
                      ),
                    ),
                    _FilterGroup(
                      label: 'Gender',
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final option in _genderOptions)
                            ChoiceChip(
                              label: Text(option.label),
                              selected: _gender == option.wireValue,
                              // Tapping the chosen one again clears the filter:
                              // there is no "any" chip to go back to.
                              onSelected: (isSelected) => setState(
                                () => _gender = isSelected
                                    ? option.wireValue
                                    : '',
                              ),
                            ),
                        ],
                      ),
                    ),
                    _FilterGroup(
                      label: 'City',
                      child: AppTextField(
                        controller: _cityController,
                        hint: 'Any city',
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    _FilterGroup(
                      label: 'Profile',
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FilterChip(
                          label: const Text('Has a profile photo'),
                          selected: _hasProfilePhoto ?? false,
                          // Off means "either", not "no photo" — the list
                          // should not hide teachers for lacking one.
                          onSelected: (isSelected) => setState(
                            () => _hasProfilePhoto = isSelected ? true : null,
                          ),
                        ),
                      ),
                    ),
                    _FilterGroup(
                      label: 'Sort by',
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final option in TeacherSortOrder.values)
                            ChoiceChip(
                              label: Text(_sortLabel(option)),
                              selected: _sortOrder == option,
                              onSelected: (_) =>
                                  setState(() => _sortOrder = option),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.sm,
                  AppSpacing.xxl,
                  AppSpacing.lg,
                ),
                child: AppButton(label: 'Show teachers', onPressed: _apply),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _sortLabel(TeacherSortOrder order) => switch (order) {
    TeacherSortOrder.desc => 'Newest first',
    TeacherSortOrder.asc => 'Oldest first',
  };
}

/// The three values the API accepts for `gender`, kept here rather than
/// borrowed from the teacher wizard's own enum — this is a student screen.
const List<({String label, String wireValue})> _genderOptions = [
  (label: 'Male', wireValue: 'male'),
  (label: 'Female', wireValue: 'female'),
  (label: 'Other', wireValue: 'other'),
];

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.gapSm,
          child,
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({
    required this.options,
    required this.selected,
    required this.onToggled,
  });

  final List<String> options;
  final List<String> selected;
  final void Function(String option, bool isSelected) onToggled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(option),
            selected: selected.contains(option),
            onSelected: (isSelected) => onToggled(option, isSelected),
          ),
      ],
    );
  }
}
