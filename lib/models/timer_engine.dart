import 'wod_config.dart';

enum PhaseKind { countdown, work, rest }

/// One contiguous block of the workout timeline.
class Phase {
  const Phase({
    required this.kind,
    required this.seconds,
    this.round = 0,
    this.countUp = false,
  });

  final PhaseKind kind;

  /// Length in seconds, or null for an open-ended phase (For Time without cap).
  final int? seconds;

  /// 1-based round number, 0 when not applicable.
  final int round;

  /// Whether the clock shows elapsed rather than remaining time.
  final bool countUp;
}

/// Where the timer is at a given elapsed time.
class TimerSnapshot {
  const TimerSnapshot({
    required this.phase,
    required this.phaseIndex,
    required this.displaySeconds,
    required this.workoutElapsed,
    required this.finished,
  });

  final Phase phase;
  final int phaseIndex;

  /// Value to show on the clock (whole seconds).
  final int displaySeconds;

  /// Seconds elapsed since the countdown ended.
  final int workoutElapsed;
  final bool finished;
}

/// Pure, deterministic timeline for a [WodConfig]. The UI only feeds it the
/// elapsed time, which keeps the timing logic easy to test.
class TimerEngine {
  TimerEngine(this.config) : phases = _buildPhases(config);

  final WodConfig config;
  final List<Phase> phases;

  int get totalRounds => switch (config.type) {
    WodType.forTime || WodType.amrap => 0,
    _ => config.rounds,
  };

  /// Total length including countdown, or null if open-ended.
  int? get totalSeconds {
    var sum = 0;
    for (final p in phases) {
      if (p.seconds == null) return null;
      sum += p.seconds!;
    }
    return sum;
  }

  static List<Phase> _buildPhases(WodConfig c) {
    final out = <Phase>[
      if (c.countdownSeconds > 0)
        Phase(kind: PhaseKind.countdown, seconds: c.countdownSeconds),
    ];
    switch (c.type) {
      case WodType.forTime:
        out.add(
          Phase(
            kind: PhaseKind.work,
            seconds: c.minutes > 0 ? c.minutes * 60 : null,
            countUp: true,
          ),
        );
      case WodType.amrap:
        out.add(Phase(kind: PhaseKind.work, seconds: c.minutes * 60));
      case WodType.emom:
        for (var r = 1; r <= c.rounds; r++) {
          out.add(
            Phase(kind: PhaseKind.work, seconds: c.intervalSeconds, round: r),
          );
        }
      case WodType.tabata:
      case WodType.intervals:
        for (var r = 1; r <= c.rounds; r++) {
          out.add(
            Phase(kind: PhaseKind.work, seconds: c.workSeconds, round: r),
          );
          // No trailing rest after the final round.
          if (c.restSeconds > 0 && r < c.rounds) {
            out.add(
              Phase(kind: PhaseKind.rest, seconds: c.restSeconds, round: r),
            );
          }
        }
    }
    return out;
  }

  TimerSnapshot at(Duration elapsed) {
    final e = elapsed.inMilliseconds / 1000.0;
    final countdown = phases.first.kind == PhaseKind.countdown
        ? phases.first.seconds!
        : 0;
    final workoutElapsed = (e - countdown).clamp(0, double.infinity).floor();

    var start = 0.0;
    for (var i = 0; i < phases.length; i++) {
      final p = phases[i];
      final len = p.seconds;
      if (len == null || e < start + len) {
        final inPhase = e - start;
        final display = p.countUp
            ? inPhase.floor()
            : (len! - inPhase).ceil().clamp(0, len);
        return TimerSnapshot(
          phase: p,
          phaseIndex: i,
          displaySeconds: display,
          workoutElapsed: workoutElapsed,
          finished: false,
        );
      }
      start += len;
    }
    final last = phases.last;
    return TimerSnapshot(
      phase: last,
      phaseIndex: phases.length - 1,
      displaySeconds: last.countUp ? last.seconds! : 0,
      workoutElapsed: (totalSeconds ?? 0) - countdown,
      finished: true,
    );
  }
}
