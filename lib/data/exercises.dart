import 'dart:math';

import '../models/wod_config.dart';

enum Equipment {
  none('Kroppsvekt'),
  barbell('Vektstang'),
  dumbbell('Manualer'),
  kettlebell('Kettlebell'),
  pullupBar('Pull-up-stang'),
  rower('Romaskin'),
  jumpRope('Hoppetau'),
  box('Boks'),
  wallBall('Wall ball');

  const Equipment(this.label);
  final String label;
}

class Exercise {
  const Exercise(this.name, this.equipment, this.reps);
  final String name;
  final Equipment equipment;

  /// Typical rep scheme for one round, e.g. "10" or "250 m".
  final String reps;
}

const exercises = <Exercise>[
  Exercise('Air squats', Equipment.none, '20'),
  Exercise('Push-ups', Equipment.none, '15'),
  Exercise('Burpees', Equipment.none, '10'),
  Exercise('Sit-ups', Equipment.none, '20'),
  Exercise('Lunges', Equipment.none, '20'),
  Exercise('Mountain climbers', Equipment.none, '30'),
  Exercise('Tuck jumps', Equipment.none, '10'),
  Exercise('Deadlift', Equipment.barbell, '10'),
  Exercise('Thrusters', Equipment.barbell, '10'),
  Exercise('Power cleans', Equipment.barbell, '8'),
  Exercise('Push press', Equipment.barbell, '10'),
  Exercise('Front squats', Equipment.barbell, '10'),
  Exercise('DB snatch', Equipment.dumbbell, '12'),
  Exercise('DB thrusters', Equipment.dumbbell, '12'),
  Exercise('Devil press', Equipment.dumbbell, '8'),
  Exercise('KB swings', Equipment.kettlebell, '15'),
  Exercise('Goblet squats', Equipment.kettlebell, '15'),
  Exercise('KB clean & jerk', Equipment.kettlebell, '10'),
  Exercise('Pull-ups', Equipment.pullupBar, '10'),
  Exercise('Toes-to-bar', Equipment.pullupBar, '10'),
  Exercise('Row', Equipment.rower, '250 m'),
  Exercise('Row (kalorier)', Equipment.rower, '15 kal'),
  Exercise('Double-unders', Equipment.jumpRope, '40'),
  Exercise('Single-unders', Equipment.jumpRope, '80'),
  Exercise('Box jumps', Equipment.box, '15'),
  Exercise('Step-ups', Equipment.box, '20'),
  Exercise('Wall balls', Equipment.wallBall, '20'),
];

/// A generated workout: a timer format plus a list of movements.
class GeneratedWod {
  const GeneratedWod(this.config, this.movements, this.name);
  final WodConfig config;
  final List<Exercise> movements;
  final String name;

  String get description =>
      '${config.summary}\n${movements.map((m) => '${m.reps} ${m.name}').join('\n')}';
}

const _names = [
  'Inferno',
  'Viking',
  'Fjellet',
  'Stormen',
  'Nordlys',
  'Ragnarok',
  'Tordenskrall',
  'Midnattssol',
  'Isbreen',
  'Fossen',
  'Valkyrie',
  'Trollet',
];

/// Builds a random workout from the available [equipment] that fits roughly
/// in [minutes].
GeneratedWod generateWod({
  required Set<Equipment> equipment,
  required int minutes,
  Random? random,
}) {
  final rnd = random ?? Random();
  final available =
      exercises
          .where(
            (e) =>
                e.equipment == Equipment.none ||
                equipment.contains(e.equipment),
          )
          .toList()
        ..shuffle(rnd);

  final type = [WodType.amrap, WodType.forTime, WodType.emom][rnd.nextInt(3)];
  final count = type == WodType.emom
      ? min(minutes, 4).clamp(2, 4)
      : 3 + rnd.nextInt(2);
  final moves = available.take(count).toList();

  final config = switch (type) {
    WodType.emom => WodConfig(
      type: WodType.emom,
      rounds: (minutes ~/ moves.length) * moves.length,
      intervalSeconds: 60,
    ),
    WodType.forTime => WodConfig(type: WodType.forTime, minutes: minutes),
    _ => WodConfig(type: WodType.amrap, minutes: minutes),
  };
  return GeneratedWod(config, moves, _names[rnd.nextInt(_names.length)]);
}
