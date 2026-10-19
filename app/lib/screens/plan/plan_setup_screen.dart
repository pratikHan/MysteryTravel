import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/plan_fixtures.dart';
import '../../data/plan_models.dart';
import '../../state/app_state.dart';
import '../../theme/themes.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';
import '../../widgets/toast.dart';

/// Plan Setup — city, date, start time, up-to-5 categories, wish text.
/// SKELETON: working inputs in plain styling; full design in Slice 2.
class PlanSetupScreen extends StatefulWidget {
  const PlanSetupScreen({super.key});

  @override
  State<PlanSetupScreen> createState() => _PlanSetupScreenState();
}

class _PlanSetupScreenState extends State<PlanSetupScreen> {
  late final TextEditingController _city;
  late final TextEditingController _wish;

  @override
  void initState() {
    super.initState();
    final plan = AppScope.read(context).plan;
    _city = TextEditingController(text: plan.city);
    _wish = TextEditingController(text: plan.wishText);
  }

  @override
  void dispose() {
    _city.dispose();
    _wish.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final state = AppScope.read(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: state.plan.date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) state.updatePlan(date: picked);
  }

  Future<void> _pickTime() async {
    final state = AppScope.read(context);
    final picked = await showTimePicker(
      context: context,
      initialTime:
          state.plan.startTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) state.updatePlan(startTime: picked);
  }

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  String _dateLabel(DateTime? d) => d == null
      ? 'Pick a date'
      : '${_weekdays[d.weekday - 1]}, ${d.month}/${d.day}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    final plan = state.plan;
    final mystery = plan.mode == ExplorationMode.mystery;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.prefsGutter,
                  AppSpace.l, AppSpace.prefsGutter, 0),
              child: ScreenHeader(
                title: 'Plan Your Day',
                subtitle: mystery
                    ? 'Mystery exploration'
                    : 'Planned exploration',
                onBack: () => context.go('/path-choice'),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpace.prefsGutter),
                physics: const BouncingScrollPhysics(),
                children: [
                  AppText('Where & when', AppType.sectionHeader),
                  const SizedBox(height: AppSpace.m),
                  TextField(
                    controller: _city,
                    onChanged: (v) => state.updatePlan(city: v),
                    style: AppType.body.style(c.ink),
                    decoration: _fieldDecoration(
                        context, 'City (e.g. San Francisco)',
                        icon: Icons.location_city_rounded),
                  ),
                  const SizedBox(height: AppSpace.m),
                  Row(
                    children: [
                      Expanded(
                        child: _PickerChip(
                          icon: Icons.event_rounded,
                          label: _dateLabel(plan.date),
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: AppSpace.m),
                      Expanded(
                        child: _PickerChip(
                          icon: Icons.schedule_rounded,
                          label: plan.startTime == null
                              ? 'Start time'
                              : plan.startTime!.format(context),
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xxl),
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                            'What would you love to explore?',
                            AppType.sectionHeader),
                      ),
                      AppText(
                          '${plan.categoryIds.length}/${PlanRequest.maxCategories}',
                          AppType.meta,
                          color: c.muted),
                    ],
                  ),
                  const SizedBox(height: AppSpace.m),
                  Wrap(
                    spacing: AppSpace.s,
                    runSpacing: AppSpace.s,
                    children: [
                      for (final cat in PlanFixtures.categories)
                        FilterChipPill(
                          label: '${cat.emoji} ${cat.label}',
                          selected: plan.categoryIds.contains(cat.id),
                          onTap: () {
                            final ok =
                                state.togglePlanCategory(cat.id);
                            if (!ok) {
                              SoundService.instance.play(Sfx.wrong,
                                  haptic: Haptic.warning);
                              showAppToast(context,
                                  'Pick up to ${PlanRequest.maxCategories} for one day!');
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xxl),
                  AppText('Anything specific in mind?',
                      AppType.sectionHeader),
                  const SizedBox(height: AppSpace.m),
                  TextField(
                    controller: _wish,
                    onChanged: (v) => state.updatePlan(wishText: v),
                    maxLines: 3,
                    style: AppType.body.style(c.ink),
                    decoration: _fieldDecoration(
                      context,
                      'e.g. "A nice park and a good coffee shop for a lazy Sunday…"',
                    ),
                  ),
                  const SizedBox(height: AppSpace.xxl),
                  PrimaryButton(
                    label: 'Create My Adventures',
                    enabled: plan.isComplete,
                    sfx: Sfx.success,
                    onTap: () => context.go('/curated'),
                  ),
                  const SizedBox(height: AppSpace.l),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(BuildContext context, String hint,
      {IconData? icon}) {
    final c = context.colors;
    return InputDecoration(
      hintText: hint,
      hintStyle: AppType.body.style(c.muted.withValues(alpha: 0.7)),
      prefixIcon:
          icon == null ? null : Icon(icon, color: c.muted, size: 20),
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpace.m, horizontal: AppSpace.l),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.row),
        borderSide: BorderSide(color: c.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.row),
        borderSide: BorderSide(color: c.ink, width: 1.5),
      ),
    );
  }
}

class _PickerChip extends StatelessWidget {
  const _PickerChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.l, vertical: AppSpace.m + 1),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.row),
          border: Border.all(color: c.border, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: c.muted),
            const SizedBox(width: AppSpace.s),
            Expanded(
              child: AppText(label, AppType.chip,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
