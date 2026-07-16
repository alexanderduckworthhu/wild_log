import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/layout/wild_space.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/wild_colors.dart';
import '../../domain/activity_type.dart';
import '../../domain/session.dart';
import '../../providers/providers.dart';
import '../shared/wild_widgets.dart';

class SessionFormScreen extends ConsumerStatefulWidget {
  const SessionFormScreen({
    super.key,
    this.existing,
    this.initialType,
  });

  final AdventureSession? existing;
  final ActivityType? initialType;

  @override
  ConsumerState<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends ConsumerState<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late ActivityType _type;
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _notes;
  late final TextEditingController _duration;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late final TextEditingController _elevation;
  late final TextEditingController _distance;
  late DateTime _startedAt;
  late int _difficulty;
  final Map<String, TextEditingController> _detailControllers = {};
  bool _showMapPin = false;
  bool _showExtras = false;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.activityType ?? widget.initialType ?? ActivityType.hike;
    _title = TextEditingController(text: e?.title ?? '');
    _location = TextEditingController(text: e?.locationName ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _duration = TextEditingController(
      text: e != null
          ? '${e.durationMinutes}'
          : '${AppConstants.defaultDurationMinutes}',
    );
    _lat = TextEditingController(text: e?.latitude?.toString() ?? '');
    _lng = TextEditingController(text: e?.longitude?.toString() ?? '');
    _elevation = TextEditingController(text: e?.elevationGainM?.toString() ?? '');
    _distance = TextEditingController(text: e?.distanceKm?.toString() ?? '');
    _startedAt = e?.startedAt ?? DateTime.now();
    _difficulty = e?.difficulty ?? 3;
    _showMapPin = e?.hasMapPin ?? false;
    _showExtras = e != null &&
        (e.details.isNotEmpty ||
            e.elevationGainM != null ||
            e.distanceKm != null);
    _rebuildDetailControllers(seed: e?.details);
  }

  void _rebuildDetailControllers({Map<String, dynamic>? seed}) {
    for (final c in _detailControllers.values) {
      c.dispose();
    }
    _detailControllers.clear();
    for (final field in _type.specificFields) {
      final existing = seed?[field.key];
      _detailControllers[field.key] = TextEditingController(
        text: existing?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    _duration.dispose();
    _lat.dispose();
    _lng.dispose();
    _elevation.dispose();
    _distance.dispose();
    for (final c in _detailControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validateLatitude(String? value) {
    if (!_showMapPin) return null;
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppStrings.formPinNeedsBoth;
    final lat = double.tryParse(text);
    if (lat == null ||
        lat < AppConstants.minLatitudeDegrees ||
        lat > AppConstants.maxLatitudeDegrees) {
      return AppStrings.formLatInvalid;
    }
    return null;
  }

  String? _validateLongitude(String? value) {
    if (!_showMapPin) return null;
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppStrings.formPinNeedsBoth;
    final lng = double.tryParse(text);
    if (lng == null ||
        lng < AppConstants.minLongitudeDegrees ||
        lng > AppConstants.maxLongitudeDegrees) {
      return AppStrings.formLngInvalid;
    }
    return null;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startedAt,
      firstDate: DateTime(AppConstants.earliestLogYear),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: AppStrings.formDateHelp,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startedAt),
      helpText: AppStrings.formTimeHelp,
    );
    if (time == null) return;
    setState(() {
      _startedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_showMapPin) {
      final latText = _lat.text.trim();
      final lngText = _lng.text.trim();
      if (latText.isEmpty || lngText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.formPinNeedsBoth)),
        );
        return;
      }
      final lat = double.tryParse(latText);
      final lng = double.tryParse(lngText);
      if (lat == null ||
          lat < AppConstants.minLatitudeDegrees ||
          lat > AppConstants.maxLatitudeDegrees) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.formLatInvalid)),
        );
        return;
      }
      if (lng == null ||
          lng < AppConstants.minLongitudeDegrees ||
          lng > AppConstants.maxLongitudeDegrees) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.formLngInvalid)),
        );
        return;
      }
    }

    await wildCommitFeedback();
    setState(() => _saving = true);

    final details = <String, dynamic>{};
    for (final field in _type.specificFields) {
      final raw = _detailControllers[field.key]?.text.trim() ?? '';
      if (raw.isEmpty) continue;
      if (field.kind == FieldKind.number) {
        details[field.key] = num.tryParse(raw) ?? raw;
      } else {
        details[field.key] = raw;
      }
    }

    double? elev = double.tryParse(_elevation.text.trim());
    double? dist = double.tryParse(_distance.text.trim());
    if (elev == null && details['elevationGainM'] is num) {
      elev = (details['elevationGainM'] as num).toDouble();
    }
    if (dist == null && details['distanceKm'] is num) {
      dist = (details['distanceKm'] as num).toDouble();
    }
    if (details['verticalDropM'] is num && elev == null) {
      elev = (details['verticalDropM'] as num).toDouble();
    }

    final existing = widget.existing;
    final title = _title.text.trim().isEmpty
        ? AppStrings.formAutoTitle(
            _type.label,
            DateFormat('MMM d').format(_startedAt),
          )
        : _title.text.trim();

    final session = AdventureSession(
      id: existing?.id ?? '',
      activityType: _type,
      title: title,
      startedAt: _startedAt,
      durationMinutes: int.tryParse(_duration.text.trim()) ?? 0,
      locationName:
          _location.text.trim().isEmpty ? null : _location.text.trim(),
      latitude: _showMapPin ? double.tryParse(_lat.text.trim()) : null,
      longitude: _showMapPin ? double.tryParse(_lng.text.trim()) : null,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      difficulty: _difficulty,
      elevationGainM: elev,
      distanceKm: dist,
      details: details,
      createdAt: existing?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(sessionRepositoryProvider).upsert(session);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.formSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WildColors.voidBlack,
      appBar: AppBar(
        title: Text(_editing ? AppStrings.formEditTitle : AppStrings.formNewTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            WildSpace.lg,
            WildSpace.xs,
            WildSpace.lg,
            120,
          ),
          children: [
            Text(
              AppStrings.formWhatDoing,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: WildSpace.sm),
            Wrap(
              spacing: WildSpace.xs,
              runSpacing: WildSpace.xs,
              children: [
                for (final t in ActivityType.values)
                  ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.icon, size: 16, color: t.color),
                        const SizedBox(width: 6),
                        Text(t.label),
                      ],
                    ),
                    selected: _type == t,
                    onSelected: (_) => setState(() {
                      _type = t;
                      _rebuildDetailControllers();
                    }),
                  ),
              ],
            ),
            const SizedBox(height: WildSpace.lg),
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: AppStrings.formNameDay,
                hintText: AppStrings.formNameHint,
                helperText: AppStrings.formNameHelper,
              ),
            ),
            const SizedBox(height: WildSpace.sm),
            FieldPanel(
              onTap: _pickDate,
              padding: const EdgeInsets.symmetric(
                horizontal: WildSpace.md,
                vertical: WildSpace.sm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18),
                  const SizedBox(width: WildSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.formWhen,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          DateFormat('EEE, MMM d · h:mm a').format(_startedAt),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: WildColors.mist),
                ],
              ),
            ),
            const SizedBox(height: WildSpace.sm),
            TextFormField(
              controller: _duration,
              decoration: const InputDecoration(
                labelText: AppStrings.formDuration,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: WildSpace.lg),
            Text(
              AppStrings.formHowHard,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: WildSpace.xs),
            Row(
              children: [
                for (var i = AppConstants.minDifficulty;
                    i <= AppConstants.maxDifficulty;
                    i++)
                  Padding(
                    padding: const EdgeInsets.only(right: WildSpace.xs),
                    child: ChoiceChip(
                      label: Text('$i'),
                      selected: _difficulty == i,
                      onSelected: (_) => setState(() => _difficulty = i),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: WildSpace.lg),
            TextFormField(
              controller: _location,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: AppStrings.formWhere,
                hintText: AppStrings.formWhereHint,
              ),
            ),
            const SizedBox(height: WildSpace.sm),
            TextFormField(
              controller: _notes,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: AppStrings.formNotes,
                alignLabelWithHint: true,
                hintText: AppStrings.formNotesHint,
              ),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: WildSpace.md),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                AppStrings.formPinMap,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                AppStrings.formPinMapSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              value: _showMapPin,
              activeThumbColor: WildColors.lichen,
              onChanged: (v) => setState(() => _showMapPin = v),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _showMapPin
                  ? Padding(
                      padding: const EdgeInsets.only(top: WildSpace.xs),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _lat,
                              decoration: const InputDecoration(
                                labelText: AppStrings.formLatitude,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              validator: _validateLatitude,
                            ),
                          ),
                          const SizedBox(width: WildSpace.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _lng,
                              decoration: const InputDecoration(
                                labelText: AppStrings.formLongitude,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              validator: _validateLongitude,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: WildSpace.xs),
            WildSecondaryButton(
              label: _showExtras
                  ? AppStrings.formHideDetails
                  : AppStrings.formShowDetails,
              onPressed: () => setState(() => _showExtras = !_showExtras),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              child: _showExtras
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: WildSpace.xs),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _elevation,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.formElevation,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: WildSpace.sm),
                            Expanded(
                              child: TextFormField(
                                controller: _distance,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.formDistance,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: WildSpace.sm),
                        for (final field in _type.specificFields)
                          if (field.key != 'elevationGainM' &&
                              field.key != 'distanceKm')
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: WildSpace.sm,
                              ),
                              child: TextFormField(
                                controller: _detailControllers[field.key],
                                decoration: InputDecoration(
                                  labelText: field.label,
                                ),
                                keyboardType: field.kind == FieldKind.number
                                    ? const TextInputType.numberWithOptions(
                                        decimal: true,
                                      )
                                    : TextInputType.text,
                              ),
                            ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WildSpace.lg,
            WildSpace.xs,
            WildSpace.lg,
            WildSpace.sm,
          ),
          child: WildPrimaryButton(
            label: _editing ? AppStrings.formSaveEdit : AppStrings.formSaveNew,
            icon: Icons.check,
            busy: _saving,
            onPressed: _save,
          ),
        ),
      ),
    );
  }
}
