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

/// Plan Setup — the "Mood Builder" (reference: design1001/plan_setup.png).
///
/// Where & when pickers, a mood row, the 12-category grid with the
/// 5-pick cap and bonus banner, the wish box, and the companion bubble
/// that reacts (with typing dots) to every choice.
class PlanSetupScreen extends StatefulWidget {
  const PlanSetupScreen({super.key});

  @override
  State<PlanSetupScreen> createState() => _PlanSetupScreenState();
}

class _PlanSetupScreenState extends State<PlanSetupScreen> {
  late final TextEditingController _wish;
  bool _bonusCelebrated = false;

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
    if (isFullNow && !hadFull && !_bonusCelebrated) {
      _bonusCelebrated = true;
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.3],
            colors: [c.groundTop, c.ground],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ---- Header ----
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.screenGutter, AppSpace.s, AppSpace.screenGutter, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleIconButton(
                      icon: Icons.chevron_left_rounded,
                      semanticLabel: 'Back to Path Choice',
                      onTap: () => context.go('/path-choice'),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          AppText('Mood Builder', AppType.screenTitle),
                          const SizedBox(height: 2),
                          AppText('Turn your mood into a magical day ✨',
                              AppType.chip,
                              color: c.muted),
                          const SizedBox(height: AppSpace.m),
                          const _StepBar(step: 2, total: 4),
                        ],
                      ),
                    ),
                    CircleIconButton(
                      icon: Icons.menu_rounded,
                      semanticLabel: 'Options',
                      onTap: () => _openMenu(context),
                    ),
                  ],
                ),
              ),
              // ---- Form ----
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpace.screenGutter,
                      AppSpace.xl, AppSpace.screenGutter, AppSpace.xl),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    AppText('Where & when are you exploring?',
                        AppType.formHeader),
                    const SizedBox(height: AppSpace.m),
                    Row(
                      children: [
                        Expanded(
                          flex: 13,
                          child: _PickerField(
                            emoji: '🏙️',
                            label: plan.city.isEmpty ? 'City' : plan.city,
                            placeholder: plan.city.isEmpty,
                            onTap: _pickCity,
                          ),
                        ),
                        const SizedBox(width: AppSpace.s),
                        Expanded(
                          flex: 12,
                          child: _PickerField(
                            emoji: '📅',
                            label: plan.date == null
                                ? 'Date'
                                : '${_wd[plan.date!.weekday - 1]}, ${_mo[plan.date!.month - 1]} ${plan.date!.day}',
                            placeholder: plan.date == null,
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: AppSpace.s),
                        Expanded(
                          flex: 10,
                          child: _PickerField(
                            emoji: '🕙',
                            label: plan.startTime == null
                                ? 'Time'
                                : plan.startTime!.format(context),
                            placeholder: plan.startTime == null,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.xxl + 4),
                    AppText('How are you feeling today?', AppType.formHeader),
                    const SizedBox(height: AppSpace.xs),
                    AppText('Pick a mood to set the vibe for your day.',
                        AppType.body,
                        color: c.muted),
                    const SizedBox(height: AppSpace.m),
                    SizedBox(
                      height: 46,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: PlanFixtures.moods.length,
                        separatorBuilder: (_, i) =>
                            const SizedBox(width: AppSpace.s + 1),
                        itemBuilder: (context, i) {
                          final mood = PlanFixtures.moods[i];
                          return _MoodPill(
                            mood: mood,
                            selected: plan.moodId == mood.id,
                            onTap: () {
                              SoundService.instance
                                  .play(Sfx.pop, haptic: Haptic.light);
                              state.setMood(mood.id);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpace.xxl + 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppText('What would you love to explore?',
                              AppType.formHeader),
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
                              color: full ? c.gold : context.accents.peaceful,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: AppText(
                                '$picks / ${PlanRequest.maxCategories} picks',
                                AppType.chip,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.xs),
                    AppText(
                        'Pick up to ${PlanRequest.maxCategories} categories for your perfect day.',
                        AppType.body,
                        color: c.muted),
                    const SizedBox(height: AppSpace.l),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpace.s + 2,
                      crossAxisSpacing: AppSpace.s + 2,
                      childAspectRatio: 1.26,
                      children: [
                        for (final cat in PlanFixtures.categories)
                          _CategoryCard(
                            category: cat,
                            selected: plan.categoryIds.contains(cat.id),
                            onTap: () => _onCategoryTap(cat.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.l),
                    _BonusBanner(picks: picks),
                    const SizedBox(height: AppSpace.xxl + 4),
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                              'Anything specific in mind?', AppType.formHeader),
                        ),
                        AppText('Optional', AppType.chip, color: c.muted),
                      ],
                    ),
                    const SizedBox(height: AppSpace.m),
                    TextField(
                      controller: _wish,
                      onChanged: (v) => state.updatePlan(wishText: v),
                      maxLines: 3,
                      style: AppType.body.style(c.ink),
                      decoration: InputDecoration(
                        hintText:
                            '"I want a peaceful park, great coffee, and some hidden gems…"',
                        hintStyle:
                            AppType.body.style(c.muted.withValues(alpha: 0.65)),
                        suffixIcon: Icon(Icons.edit_outlined,
                            color: c.muted, size: 18),
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
                      mascotState: full
                          ? MascotState.celebrating
                          : MascotState.idle,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText('Create My Adventure ✨', AppType.cta,
                                  color: c.onDark),
                              const SizedBox(width: AppSpace.s),
                              Icon(Icons.arrow_forward_rounded,
                                  color: c.onDark, size: 20),
                            ],
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
      ),
    );
  }

  void _openMenu(BuildContext context) {
    final c = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.ground,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.screenGutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (icon, label, action) in [
                (Icons.swap_horiz_rounded, 'Switch exploration mode', () {
                  context.go('/path-choice');
                }),
                (Icons.restart_alt_rounded, 'Start over', () {
                  AppScope.read(context).plan.reset();
                  AppScope.read(context).updatePlan();
                  _wish.clear();
                  setState(() => _bonusCelebrated = false);
                }),
              ])
                Pressable(
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    action();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpace.m, horizontal: AppSpace.s),
                    child: Row(
                      children: [
                        Icon(icon, size: 21, color: c.ink),
                        const SizedBox(width: AppSpace.l),
                        AppText(label, AppType.rowTitle),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Gold step-progress segments under the title.
class _StepBar extends StatelessWidget {
  const _StepBar({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: AppMotion.base,
            width: 44,
            height: 8,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : AppSpace.xs + 2),
            decoration: BoxDecoration(
              color: i < step ? c.gold : c.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}

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
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.m - 2),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.row),
          border: Border.all(color: c.border, width: 1.5),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: AppSpace.xs + 2),
            Expanded(
              child: AppText(
                label,
                AppType.chip,
                color: placeholder ? c.muted.withValues(alpha: 0.7) : c.ink,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: c.muted),
          ],
        ),
      ),
    );
  }
}

class _MoodPill extends StatelessWidget {
  const _MoodPill({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      sfx: null,
      haptic: null,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl - 2),
        decoration: BoxDecoration(
          color: selected ? c.gold.softFill : c.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? c.gold : c.border,
            width: selected ? 2.5 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: c.gold.withValues(alpha: 0.4),
                      blurRadius: 14,
                      spreadRadius: 1),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: AppSpace.xs + 2),
            AppText(mood.label, AppType.itemTitle),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
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
      child: Stack(
        children: [
          AnimatedContainer(
            duration: AppMotion.base,
            curve: AppMotion.easeOut,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s, vertical: AppSpace.s),
            decoration: BoxDecoration(
              color: selected ? accent : c.surface,
              borderRadius: BorderRadius.circular(AppRadius.row),
              border: Border.all(
                color: selected ? accent : c.border,
                width: 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ]
                  : null,
            ),
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(category.emoji,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: AppSpace.xs),
                  AppText(
                    category.label,
                    AppType.caption,
                    color: selected ? Colors.white : c.ink,
                    align: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          if (selected)
            Positioned(
              top: AppSpace.xs,
              right: AppSpace.xs,
              child: PopIn(
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded,
                      size: 13, color: accent),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Gamified nudge toward 5 picks; celebrates when the bonus unlocks.
class _BonusBanner extends StatelessWidget {
  const _BonusBanner({required this.picks});

  final int picks;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final full = picks >= PlanRequest.maxCategories;
    final remaining = PlanRequest.maxCategories - picks;
    return AnimatedContainer(
      duration: AppMotion.base,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.l, vertical: AppSpace.m + 2),
      decoration: BoxDecoration(
        color: full ? c.success.softFill : c.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: full ? c.success.softBorder : c.border,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          full
              ? PopIn(
                  key: const ValueKey('unlocked'),
                  peak: 1.4,
                  withRotation: true,
                  child: const Text('🎉', style: TextStyle(fontSize: 30)),
                )
              : Floaty(
                  child:
                      const Text('🎁', style: TextStyle(fontSize: 30))),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  full
                      ? 'Bonus unlocked!'
                      : 'Choose $remaining more ${remaining == 1 ? 'category' : 'categories'} to unlock a bonus!',
                  AppType.itemTitle,
                ),
                const SizedBox(height: 2),
                AppText(
                  full
                      ? 'A special surprise is hiding in your day plan 🎉'
                      : 'Get a special surprise in your day plan ✨',
                  AppType.chip,
                  color: c.muted,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.s),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.m, vertical: AppSpace.xs + 2),
            decoration: BoxDecoration(
              color: full ? c.success : c.gold,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: AppText('$picks / ${PlanRequest.maxCategories}',
                AppType.meta,
                color: Colors.white),
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
      padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom),
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
                          horizontal: AppSpace.l, vertical: AppSpace.s + 1),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
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
