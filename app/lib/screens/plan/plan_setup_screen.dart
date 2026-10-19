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
import '../../widgets/companion_bubble.dart';
import '../../widgets/mascot.dart';
import '../../widgets/motion_widgets.dart';
import '../../widgets/toast.dart';

/// Plan Setup — layout per design/mockups/02_plan_setup.png, keeping
/// the Mood Builder micro-interactions (typing companion bubble,
/// bouncy CTA, counter pops, 5/5 celebration).
class PlanSetupScreen extends StatefulWidget {
  const PlanSetupScreen({super.key});

  @override
  State<PlanSetupScreen> createState() => _PlanSetupScreenState();
}

class _PlanSetupScreenState extends State<PlanSetupScreen> {
  late final TextEditingController _wish;
  bool _capCelebrated = false;

  @override
  void initState() {
    super.initState();
    _wish = TextEditingController(text: AppScope.read(context).plan.wishText);
  }

  @override
  void dispose() {
    _wish.dispose();
    super.dispose();
  }

  // ---- pickers ----

  Future<void> _pickCity() async {
    final state = AppScope.read(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.ground,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => _CitySheet(initial: state.plan.city),
    );
    if (picked != null && picked.trim().isNotEmpty) {
      state.updatePlan(city: picked.trim());
    }
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

  static const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _mo = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  void _onCategoryTap(String id) {
    final state = AppScope.read(context);
    final hadFull =
        state.plan.categoryIds.length >= PlanRequest.maxCategories;
    final ok = state.togglePlanCategory(id);
    if (!ok) {
      SoundService.instance.play(Sfx.wrong, haptic: Haptic.warning);
      showAppToast(
          context, 'That\'s your 5 — swap one out to change the mix!');
      return;
    }
    SoundService.instance.play(Sfx.pop, haptic: Haptic.light);
    final isFullNow =
        state.plan.categoryIds.length >= PlanRequest.maxCategories;
    if (isFullNow && !hadFull && !_capCelebrated) {
      _capCelebrated = true;
      SoundService.instance.play(Sfx.success, haptic: Haptic.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    final plan = state.plan;
    final picks = plan.categoryIds.length;
    final full = picks >= PlanRequest.maxCategories;
    final mystery = plan.mode == ExplorationMode.mystery;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ---- Header ----
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.prefsGutter,
                  AppSpace.s, AppSpace.prefsGutter, 0),
              child: ScreenHeader(
                title: 'Plan Your Day',
                subtitle: mystery
                    ? '🔮 Mystery exploration'
                    : '🗺️ Planned exploration',
                onBack: () => context.go('/path-choice'),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpace.prefsGutter,
                    AppSpace.xl, AppSpace.prefsGutter, AppSpace.xl),
                physics: const BouncingScrollPhysics(),
                children: [
                  AppText('Where & when', AppType.sectionHeader),
                  const SizedBox(height: AppSpace.m),
                  _PickerField(
                    emoji: '🏙️',
                    label: plan.city.isEmpty
                        ? 'City (e.g. San Francisco)'
                        : plan.city,
                    placeholder: plan.city.isEmpty,
                    onTap: _pickCity,
                  ),
                  const SizedBox(height: AppSpace.s + 2),
                  Row(
                    children: [
                      Expanded(
                        flex: 13,
                        child: _PickerField(
                          emoji: '📅',
                          label: plan.date == null
                              ? 'Pick a date'
                              : '${_wd[plan.date!.weekday - 1]}, ${_mo[plan.date!.month - 1]} ${plan.date!.day}',
                          placeholder: plan.date == null,
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: AppSpace.s + 2),
                      Expanded(
                        flex: 10,
                        child: _PickerField(
                          emoji: '🕙',
                          label: plan.startTime == null
                              ? 'Start time'
                              : plan.startTime!.format(context),
                          placeholder: plan.startTime == null,
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xxl + 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppText('What would you love to explore?',
                            AppType.sectionHeader),
                      ),
                      const SizedBox(width: AppSpace.s),
                      PopIn(
                        key: ValueKey('picks-$picks'),
                        peak: 1.18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.m,
                              vertical: AppSpace.xs + 2),
                          decoration: BoxDecoration(
                            color:
                                full ? c.gold : context.accents.peaceful,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: AppText(
                              '$picks / ${PlanRequest.maxCategories}',
                              AppType.chip,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xs),
                  AppText(
                      'Pick up to ${PlanRequest.maxCategories} for one perfect day',
                      AppType.body,
                      color: c.muted),
                  const SizedBox(height: AppSpace.l),
                  Wrap(
                    spacing: AppSpace.s + 1,
                    runSpacing: AppSpace.s + 1,
                    children: [
                      for (final cat in PlanFixtures.categories)
                        _CategoryChip(
                          category: cat,
                          selected: plan.categoryIds.contains(cat.id),
                          onTap: () => _onCategoryTap(cat.id),
                        ),
                    ],
                  ),
                  AnimatedSize(
                    duration: AppMotion.base,
                    curve: AppMotion.easeOut,
                    child: picks > 0
                        ? Padding(
                            padding:
                                const EdgeInsets.only(top: AppSpace.m),
                            child: _CapNote(picks: picks, full: full),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                  const SizedBox(height: AppSpace.xxl + 4),
                  AppText('Anything specific in mind?',
                      AppType.sectionHeader),
                  const SizedBox(height: AppSpace.m),
                  TextField(
                    controller: _wish,
                    onChanged: (v) => state.updatePlan(wishText: v),
                    maxLines: 3,
                    style: AppType.body.style(c.ink),
                    decoration: InputDecoration(
                      hintText:
                          '"I want a nice park and a good coffee shop for a lazy Sunday…"',
                      hintStyle: AppType.body
                          .style(c.muted.withValues(alpha: 0.65)),
                      filled: true,
                      fillColor: c.surface,
                      contentPadding: const EdgeInsets.all(AppSpace.l),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.card),
                        borderSide:
                            BorderSide(color: c.border, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.card),
                        borderSide: BorderSide(color: c.ink, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  CompanionBubble(
                    message: PlanFixtures.companionReaction(plan),
                    mascotState:
                        full ? MascotState.celebrating : MascotState.curious,
                  ),
                  const SizedBox(height: AppSpace.xl),
                  BouncyPressable(
                    enabled: plan.isComplete,
                    sfx: Sfx.success,
                    haptic: Haptic.medium,
                    onTap: () => context.go('/curated'),
                    child: AnimatedOpacity(
                      duration: AppMotion.base,
                      opacity: plan.isComplete ? 1 : 0.55,
                      child: Container(
                        height: AppSize.cta,
                        decoration: BoxDecoration(
                          color: c.pill,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                          boxShadow: [
                            BoxShadow(
                                color: c.shadow(0.25),
                                blurRadius: 14,
                                offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Center(
                          child: AppText(
                              'Create My Adventures ✨', AppType.cta,
                              color: c.onDark),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.emoji,
    required this.label,
    required this.placeholder,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 50,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpace.l),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.row),
          border: Border.all(color: c.border, width: 1.5),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: AppSpace.s + 2),
            Expanded(
              child: AppText(
                label,
                AppType.body,
                color: placeholder
                    ? c.muted.withValues(alpha: 0.7)
                    : c.ink,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: c.muted),
          ],
        ),
      ),
    );
  }
}

/// Emoji chip per the mockup: outlined pill, filled accent when selected.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final AdventureCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = context.accents.peaceful;
    return Pressable(
      onTap: onTap,
      sfx: null,
      haptic: null,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.easeOut,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.l, vertical: AppSpace.s + 1),
        decoration: BoxDecoration(
          color: selected ? accent : c.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: selected ? accent : c.border, width: 1.5),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: AppSpace.xs + 2),
            AppText(category.label, AppType.chip,
                color: selected ? Colors.white : c.ink),
          ],
        ),
      ),
    );
  }
}

/// The mockup's green note under the chips; copy tracks progress and
/// celebrates the full mix.
class _CapNote extends StatelessWidget {
  const _CapNote({required this.picks, required this.full});

  final int picks;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final remaining = PlanRequest.maxCategories - picks;
    return AnimatedContainer(
      duration: AppMotion.base,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.l, vertical: AppSpace.m - 2),
      decoration: BoxDecoration(
        color: full ? c.gold.softFill : c.success.softFill,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(
          color: full ? c.gold.softBorder : c.success.softBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          full
              ? PopIn(
                  key: const ValueKey('full'),
                  peak: 1.35,
                  withRotation: true,
                  child:
                      const Text('🎉', style: TextStyle(fontSize: 16)),
                )
              : const Text('✨', style: TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpace.s),
          Expanded(
            child: AppText(
              full
                  ? 'All 5 picked — sounds like a great day!'
                  : remaining == 1
                      ? 'Nice mix! One more pick and your day is full.'
                      : 'Nice mix! $remaining more picks and your day is full.',
              AppType.chip,
              color: full ? c.goldDeep : c.success,
            ),
          ),
        ],
      ),
    );
  }
}

/// City picker bottom sheet: free text + popular US city suggestions.
class _CitySheet extends StatefulWidget {
  const _CitySheet({required this.initial});

  final String initial;

  @override
  State<_CitySheet> createState() => _CitySheetState();
}

class _CitySheetState extends State<_CitySheet> {
  late final TextEditingController _search =
      TextEditingController(text: widget.initial);
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.initial;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final matches = PlanFixtures.usCities
        .where((city) =>
            _query.trim().isEmpty ||
            city.toLowerCase().contains(_query.trim().toLowerCase()))
        .toList();
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.screenGutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: AppText('Where to?', AppType.sectionHeader)),
            const SizedBox(height: AppSpace.l),
            TextField(
              controller: _search,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              onSubmitted: (v) => Navigator.of(context).pop(v),
              style: AppType.body.style(c.ink),
              decoration: InputDecoration(
                hintText: 'Type any US city…',
                hintStyle:
                    AppType.body.style(c.muted.withValues(alpha: 0.7)),
                prefixIcon:
                    Icon(Icons.search_rounded, color: c.muted, size: 20),
                filled: true,
                fillColor: c.surface,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpace.m, horizontal: AppSpace.l),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide(color: c.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide(color: c.ink, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: AppSpace.m),
            Wrap(
              spacing: AppSpace.s,
              runSpacing: AppSpace.s,
              children: [
                for (final city in matches.take(8))
                  Pressable(
                    onTap: () => Navigator.of(context).pop(city),
                    sfx: Sfx.pop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.l,
                          vertical: AppSpace.s + 1),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: c.border, width: 1.5),
                      ),
                      child: AppText(city, AppType.chip),
                    ),
                  ),
              ],
            ),
            if (_query.trim().isNotEmpty &&
                !matches.any((city) =>
                    city.toLowerCase() == _query.trim().toLowerCase())) ...[
              const SizedBox(height: AppSpace.m),
              Pressable(
                onTap: () => Navigator.of(context).pop(_query.trim()),
                child: Row(
                  children: [
                    Icon(Icons.add_location_alt_outlined,
                        size: 18, color: context.accents.peaceful),
                    const SizedBox(width: AppSpace.s),
                    AppText('Use "${_query.trim()}"', AppType.itemTitle,
                        color: context.accents.peaceful),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpace.l),
          ],
        ),
      ),
    );
  }
}
