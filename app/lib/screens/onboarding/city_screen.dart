import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/sounds.dart';
import '../../data/fixtures.dart';
import '../../state/app_state.dart';
import '../../theme/themes.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/motion_widgets.dart';

/// City picker with live search (source: select_city.dc.html).
class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = AppScope.of(context);
    final visible = Fixtures.cities
        .where((city) =>
            _query.isEmpty ||
            city.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final picked = state.city;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.25],
            colors: [c.groundTop, c.ground],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpace.prefsGutter),
            child: Column(
              children: [
                const SizedBox(height: AppSpace.s),
                ScreenHeader(
                  title: 'Pick Your\nAdventure City',
                  titleType: AppType.displayTitle,
                  onBack: () => context.go('/interests'),
                ),
                const SizedBox(height: AppSpace.xl),
                _SearchField(
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: AppSpace.xl),
                Expanded(
                  child: visible.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: AppSpace.xxl),
                          child: AppText(
                            'No cities match that yet.\nNew cities are on the way!',
                            AppType.body,
                            color: c.muted,
                            align: TextAlign.center,
                          ),
                        )
                      : GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpace.l,
                          crossAxisSpacing: AppSpace.l,
                          childAspectRatio: 171 / 150,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            for (final city in visible)
                              _CityCard(
                                name: city.name,
                                image: city.image,
                                selected: state.cityId == city.id,
                                onTap: () => state.pickCity(city.id),
                              ),
                          ],
                        ),
                ),
                SizedBox(
                  height: AppSize.cta + AppSpace.xl,
                  child: picked == null
                      ? null
                      : FadeRiseIn(
                          key: ValueKey(picked.id),
                          offset: 12,
                          child: PrimaryButton(
                            label: 'Explore ${picked.name}',
                            trailingArrow: true,
                            onTap: () => context.go('/mode'),
                          ),
                        ),
                ),
                const SizedBox(height: AppSpace.s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      onChanged: onChanged,
      style: AppType.body.style(c.ink),
      cursorColor: c.ink,
      decoration: InputDecoration(
        hintText: 'Search cities...',
        hintStyle: AppType.body.style(c.muted.withValues(alpha: 0.75)),
        prefixIcon: Icon(Icons.search_rounded, color: c.muted, size: 20),
        filled: true,
        fillColor: c.surface,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: AppSpace.m, horizontal: AppSpace.xl),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: c.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: c.ink, width: 1.5),
        ),
      ),
    );
  }
}

class _CityCard extends StatelessWidget {
  const _CityCard({
    required this.name,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String image;
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: selected
              ? Border.all(color: c.ink, width: 3)
              : Border.all(color: Colors.transparent, width: 3),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: c.shadow(0.2),
                      blurRadius: 18,
                      offset: const Offset(0, 8))
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card - 3),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(image, fit: BoxFit.cover),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        c.pill.withValues(alpha: 0.78),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpace.l,
                bottom: AppSpace.m - 1,
                child: AppText(name, AppType.rowTitle, color: Colors.white),
              ),
              if (selected)
                const Positioned(
                    top: AppSpace.s, right: AppSpace.s, child: CheckBadge()),
            ],
          ),
        ),
      ),
    );
  }
}
