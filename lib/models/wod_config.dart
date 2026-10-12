import 'package:flutter/material.dart';

/// The WOD formats supported by the timer.
enum WodType {
  forTime(
    'FOR TIME',
    'Så fort som mulig, med valgfri time cap',
    Icons.timer_outlined,
    Color(0xFF29B6F6),
  ),
  amrap(
    'AMRAP',
    'Så mange runder som mulig på tiden',
    Icons.all_inclusive,
    Color(0xFFFF7043),
  ),
  emom('EMOM', 'Every minute on the minute', Icons.repeat, Color(0xFF66BB6A)),
  tabata(
    'TABATA',
    '20 s arbeid / 10 s hvile × 8',
    Icons.bolt,
    Color(0xFFFFCA28),
  ),
  intervals(
    'INTERVALL',
    'Egendefinerte arbeids- og hvileintervaller',
    Icons.tune,
    Color(0xFFAB47BC),
  );

  const WodType(this.label, this.description, this.icon, this.color);

  final String label;
  final String description;
  final IconData icon;
  final Color color;
}

/// User-chosen settings for one timer session.
class WodConfig {
  const WodConfig({
    required this.type,
    this.minutes = 10,
    this.rounds = 8,
    this.workSeconds = 20,
    this.restSeconds = 10,
    this.intervalSeconds = 60,
    this.countdownSeconds = 10,
  });

  final WodType type;

  /// AMRAP duration, or For Time cap (0 = no cap).
  final int minutes;

  /// Number of rounds for EMOM, Tabata and Intervall.
  final int rounds;

  /// Work/rest for Tabata and Intervall.
  final int workSeconds;
  final int restSeconds;

  /// Length of each EMOM interval ("every X").
  final int intervalSeconds;

  /// Get-ready countdown before the workout starts.
  final int countdownSeconds;

  factory WodConfig.defaults(WodType type) => switch (type) {
    WodType.forTime => const WodConfig(type: WodType.forTime, minutes: 20),
    WodType.amrap => const WodConfig(type: WodType.amrap, minutes: 12),
    WodType.emom => const WodConfig(
      type: WodType.emom,
      rounds: 10,
      intervalSeconds: 60,
    ),
    WodType.tabata => const WodConfig(
      type: WodType.tabata,
      rounds: 8,
      workSeconds: 20,
      restSeconds: 10,
    ),
    WodType.intervals => const WodConfig(
      type: WodType.intervals,
      rounds: 5,
      workSeconds: 60,
      restSeconds: 30,
    ),
  };

  WodConfig copyWith({
    int? minutes,
    int? rounds,
    int? workSeconds,
    int? restSeconds,
    int? intervalSeconds,
    int? countdownSeconds,
  }) => WodConfig(
    type: type,
    minutes: minutes ?? this.minutes,
    rounds: rounds ?? this.rounds,
    workSeconds: workSeconds ?? this.workSeconds,
    restSeconds: restSeconds ?? this.restSeconds,
    intervalSeconds: intervalSeconds ?? this.intervalSeconds,
    countdownSeconds: countdownSeconds ?? this.countdownSeconds,
  );

  /// Short human-readable summary, e.g. "AMRAP 12 min".
  String get summary => switch (type) {
    WodType.forTime =>
      minutes == 0 ? 'For Time (ingen cap)' : 'For Time, cap $minutes min',
    WodType.amrap => 'AMRAP $minutes min',
    WodType.emom => 'EMOM ${formatDuration(intervalSeconds)} × $rounds',
    WodType.tabata => 'Tabata ${workSeconds}s/${restSeconds}s × $rounds',
    WodType.intervals =>
      'Intervall ${formatDuration(workSeconds)}/${formatDuration(restSeconds)} × $rounds',
  };
}

/// Formats seconds as m:ss (or h:mm:ss).
String formatDuration(int totalSeconds) {
  final s = totalSeconds.abs();
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = (s % 60).toString().padLeft(2, '0');
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$sec';
  return '$m:$sec';
}
