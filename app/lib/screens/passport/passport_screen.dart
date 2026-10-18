import 'package:flutter/material.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/mascot.dart';
import '../../widgets/motion_widgets.dart';

/// Passport: Stamps / Cities tabs, earned vs placeholder stamps, stamp
/// tap zooms (reference: 23_passport.png).
class PassportScreen extends StatefulWidget {
  const PassportScreen({super.key});

  @override
  State<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends State<PassportScreen> {
  bool _stampsTab = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: AppSpace.l),
            AppText('My Passport', AppType.pageTitle),
            const SizedBox(height: AppSpace.l),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screenGutter),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentPill(
                      label: 'Stamps',
                      selected: _stampsTab,
                      onTap: () => setState(() => _stampsTab = true),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: _SegmentPill(
                      label: 'Cities',
                      selected: !_stampsTab,
                      onTap: () => setState(() => _stampsTab = false),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.xl),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.base,
                child: _stampsTab
                    ? _StampsGrid(key: const ValueKey('stamps'))
                    : _CitiesGrid(key: const ValueKey('cities')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentPill extends StatelessWidget {
  const _SegmentPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      sfx: Sfx.pop,
      child: AnimatedContainer(
        duration: AppMotion.base,
        height: AppSize.iconButton,
        decoration: BoxDecoration(
          color: selected ? c.pill : c.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: selected ? c.pill : c.border, width: 1.5),
        ),
        child: Center(
          child: AppText(label, AppType.itemTitle,
              color: selected ? c.onDark : c.ink),
        ),
      ),
    );
  }
}

class _StampsGrid extends StatelessWidget {
  const _StampsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenGutter),
      physics: const BouncingScrollPhysics(),
      children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpace.m,
          crossAxisSpacing: AppSpace.m,
          childAspectRatio: 100 / 138,
          children: [
            for (final (i, stamp) in Fixtures.stamps.indexed)
              FadeRiseIn(
                delay: Duration(milliseconds: 50 * i),
                child: _StampCard(stamp: stamp),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.xl),
        Container(
          padding: const EdgeInsets.all(AppSpace.l),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              const Mascot(MascotState.idle, size: 86),
              const SizedBox(width: AppSpace.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Keep exploring', AppType.rowTitle),
                    const SizedBox(height: 2),
                    AppText(
                        'to collect more stamps and build your global adventure passport!',
                        AppType.chip,
                        color: c.muted),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.xl),
      ],
    );
  }
}

class _StampCard extends StatelessWidget {
  const _StampCard({required this.stamp});

  final Stamp stamp;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (!stamp.earned) {
      return Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.thumb),
                border: Border.all(
                  color: c.muted.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(Icons.lock_outline_rounded,
                  color: c.muted.withValues(alpha: 0.5), size: 28),
            ),
          ),
          const SizedBox(height: AppSpace.xs + 2),
          AppText(stamp.label, AppType.caption, color: c.muted),
          AppText('Coming Soon', AppType.caption,
              color: c.muted.withValues(alpha: 0.6)),
        ],
      );
    }
    return Pressable(
      onTap: () => _showZoom(context),
      sfx: Sfx.pop,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(AppRadius.thumb),
                border: Border.all(color: stamp.frameColor, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: c.shadow(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.all(AppSpace.xs + 2),
              child: Image.asset(stamp.image, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: AppSpace.xs + 2),
          AppText(stamp.label, AppType.caption),
        ],
      ),
    );
  }

  void _showZoom(BuildContext context) {
    final c = context.colors;
    showDialog<void>(
      context: context,
      barrierColor: c.ink.withValues(alpha: 0.55),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: PopIn(
          peak: 1.08,
          child: Container(
            padding: const EdgeInsets.all(AppSpace.xl),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.card + 4),
              border: Border.all(color: stamp.frameColor, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(stamp.image, height: 260, fit: BoxFit.contain),
                const SizedBox(height: AppSpace.l),
                AppText(stamp.label, AppType.detailTitle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CitiesGrid extends StatelessWidget {
  const _CitiesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenGutter),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpace.l,
      crossAxisSpacing: AppSpace.l,
      childAspectRatio: 171 / 150,
      physics: const BouncingScrollPhysics(),
      children: [
        for (final city in Fixtures.cities)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(city.image, fit: BoxFit.cover),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          c.pill.withValues(alpha: 0.78)
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpace.l,
                  bottom: AppSpace.m - 1,
                  child: AppText(city.name, AppType.rowTitle,
                      color: Colors.white),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
