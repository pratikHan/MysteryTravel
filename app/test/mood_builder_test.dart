import 'package:flutter_test/flutter_test.dart';
import 'package:mystery_city_adventures/data/plan_fixtures.dart';
import 'package:mystery_city_adventures/state/app_state.dart';

void main() {
  test('Category picks cap at 5 and unlock the bonus', () {
    final state = AppState();
    final ids = PlanFixtures.categories.map((c) => c.id).toList();

    for (var i = 0; i < 5; i++) {
      expect(state.togglePlanCategory(ids[i]), isTrue);
    }
    expect(state.plan.categoryIds.length, 5);

    // Sixth pick is rejected.
    expect(state.togglePlanCategory(ids[5]), isFalse);
    expect(state.plan.categoryIds.length, 5);

    // Deselecting frees a slot again.
    expect(state.togglePlanCategory(ids[0]), isTrue);
    expect(state.plan.categoryIds.length, 4);
    expect(state.togglePlanCategory(ids[5]), isTrue);
  });

  test('Companion reaction reflects mood and picks', () {
    final state = AppState();
    expect(PlanFixtures.companionReaction(state.plan),
        contains('Tell me your vibe'));

    state.setMood('calm');
    state.togglePlanCategory('nature');
    final reaction = PlanFixtures.companionReaction(state.plan);
    expect(reaction, contains('cozy day'));
    expect(reaction.toLowerCase(), contains('nature'));
  });
}
