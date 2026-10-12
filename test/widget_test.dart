import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwod/data/app_store.dart';
import 'package:smartwod/data/exercises.dart';
import 'package:smartwod/main.dart';
import 'package:smartwod/models/timer_engine.dart';
import 'package:smartwod/models/wod_config.dart';

void main() {
  group('TimerEngine', () {
    test('AMRAP counts down after countdown', () {
      final e = TimerEngine(
        const WodConfig(type: WodType.amrap, minutes: 10, countdownSeconds: 10),
      );
      expect(e.at(Duration.zero).phase.kind, PhaseKind.countdown);
      expect(e.at(Duration.zero).displaySeconds, 10);
      final s = e.at(const Duration(seconds: 15));
      expect(s.phase.kind, PhaseKind.work);
      expect(s.displaySeconds, 595);
      expect(s.workoutElapsed, 5);
      expect(e.at(const Duration(seconds: 610)).finished, isTrue);
    });

    test('Tabata alternates work/rest with no trailing rest', () {
      final e = TimerEngine(
        WodConfig.defaults(WodType.tabata).copyWith(countdownSeconds: 0),
      );
      expect(e.totalSeconds, 8 * 20 + 7 * 10);
      expect(e.at(const Duration(seconds: 21)).phase.kind, PhaseKind.rest);
      final r2 = e.at(const Duration(seconds: 31));
      expect(r2.phase.kind, PhaseKind.work);
      expect(r2.phase.round, 2);
    });

    test('EMOM rounds', () {
      final e = TimerEngine(
        const WodConfig(
          type: WodType.emom,
          rounds: 5,
          intervalSeconds: 60,
          countdownSeconds: 0,
        ),
      );
      expect(e.at(const Duration(seconds: 125)).phase.round, 3);
      expect(e.at(const Duration(seconds: 125)).displaySeconds, 55);
    });

    test('For Time without cap is open-ended and counts up', () {
      final e = TimerEngine(
        const WodConfig(type: WodType.forTime, minutes: 0, countdownSeconds: 0),
      );
      expect(e.totalSeconds, isNull);
      final s = e.at(const Duration(hours: 2));
      expect(s.finished, isFalse);
      expect(s.displaySeconds, 7200);
    });
  });

  test('generator only uses selected equipment', () {
    for (var seed = 0; seed < 50; seed++) {
      final wod = generateWod(
        equipment: {Equipment.kettlebell},
        minutes: 15,
        random: Random(seed),
      );
      expect(wod.movements, isNotEmpty);
      for (final m in wod.movements) {
        expect(m.equipment, anyOf(Equipment.none, Equipment.kettlebell));
      }
    }
  });

  testWidgets('home shows WOD types and opens setup', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore();
    await store.load();
    await tester.pumpWidget(SmartWodApp(store: store));

    expect(find.text('AMRAP'), findsOneWidget);
    expect(find.text('TABATA'), findsOneWidget);

    await tester.tap(find.text('AMRAP'));
    await tester.pumpAndSettle();
    expect(find.text('GO!'), findsOneWidget);
    expect(find.text('12 min'), findsOneWidget);
  });
}
