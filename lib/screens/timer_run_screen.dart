import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';
import '../models/timer_engine.dart';
import '../models/wod_config.dart';

class TimerRunScreen extends StatefulWidget {
  const TimerRunScreen({
    super.key,
    required this.config,
    this.title,
    this.workout,
  });

  final WodConfig config;

  /// Optional name and movement list, e.g. from the generator.
  final String? title;
  final String? workout;

  @override
  State<TimerRunScreen> createState() => _TimerRunScreenState();
}

class _TimerRunScreenState extends State<TimerRunScreen>
    with SingleTickerProviderStateMixin {
  late final TimerEngine _engine = TimerEngine(widget.config);
  final Stopwatch _stopwatch = Stopwatch();
  late final Ticker _ticker;

  late TimerSnapshot _snap = _engine.at(Duration.zero);
  int _manualRounds = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => _tick())..start();
    _stopwatch.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick() {
    if (_finished) return;
    final next = _engine.at(_stopwatch.elapsed);
    if (next.phaseIndex != _snap.phaseIndex) {
      _beep(long: true);
    } else if (next.displaySeconds != _snap.displaySeconds &&
        !next.phase.countUp &&
        next.displaySeconds > 0 &&
        next.displaySeconds <= 3) {
      _beep();
    }
    if (next.finished) {
      _finish();
      return;
    }
    if (next.displaySeconds != _snap.displaySeconds ||
        next.phaseIndex != _snap.phaseIndex) {
      setState(() => _snap = next);
    }
  }

  void _beep({bool long = false}) {
    SystemSound.play(SystemSoundType.click);
    long ? HapticFeedback.heavyImpact() : HapticFeedback.lightImpact();
  }

  void _togglePause() {
    setState(() {
      _stopwatch.isRunning ? _stopwatch.stop() : _stopwatch.start();
    });
  }

  void _reset() {
    setState(() {
      _stopwatch
        ..reset()
        ..start();
      _manualRounds = 0;
      _finished = false;
      _snap = _engine.at(Duration.zero);
    });
  }

  Future<void> _finish() async {
    _stopwatch.stop();
    final snap = _engine.at(_stopwatch.elapsed);
    setState(() {
      _finished = true;
      _snap = snap;
    });
    _beep(long: true);

    final rounds = _engine.totalRounds > 0
        ? (snap.finished ? _engine.totalRounds : snap.phase.round)
        : _manualRounds;
    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ferdig! 💪'),
        content: Text(
          'Tid: ${formatDuration(snap.workoutElapsed)}\n'
          '${rounds > 0 ? 'Runder: $rounds\n' : ''}'
          '\nVil du lagre økten i loggen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Forkast'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lagre'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (save == true) {
      StoreScope.of(context).addLog(
        LogEntry(
          date: DateTime.now(),
          title: widget.title == null
              ? widget.config.summary
              : '${widget.title} – ${widget.config.summary}',
          durationSeconds: snap.workoutElapsed,
          rounds: rounds,
          notes: widget.workout ?? '',
        ),
      );
    }
    Navigator.of(context).pop();
  }

  Color get _phaseColor => switch (_snap.phase.kind) {
    PhaseKind.countdown => const Color(0xFFFFB300),
    PhaseKind.work => widget.config.type.color,
    PhaseKind.rest => const Color(0xFF546E7A),
  };

  String get _phaseLabel => switch (_snap.phase.kind) {
    PhaseKind.countdown => 'GJØR DEG KLAR',
    PhaseKind.work => switch (widget.config.type) {
      WodType.forTime || WodType.amrap => widget.config.type.label,
      _ => 'ARBEID',
    },
    PhaseKind.rest => 'HVILE',
  };

  double get _progress {
    final len = _snap.phase.seconds;
    if (len == null || len == 0) return 0;
    final passed = _snap.phase.countUp
        ? _snap.displaySeconds
        : len - _snap.displaySeconds;
    return (passed / len).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final running = _stopwatch.isRunning;
    final color = _phaseColor;
    final showRoundButton =
        _engine.totalRounds == 0 && _snap.phase.kind == PhaseKind.work;

    return Scaffold(
      backgroundColor: Color.lerp(Colors.black, color, 0.18),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.title ?? widget.config.summary,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                _phaseLabel,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              if (_engine.totalRounds > 0 && _snap.phase.round > 0)
                Text(
                  'Runde ${_snap.phase.round} / ${_engine.totalRounds}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (widget.workout != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.workout!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade300, fontSize: 16),
                ),
              ],
              Expanded(
                child: Center(
                  child: FittedBox(
                    child: Text(
                      _snap.phase.kind == PhaseKind.countdown
                          ? '${_snap.displaySeconds}'
                          : formatDuration(_snap.displaySeconds),
                      key: const Key('clock'),
                      style: const TextStyle(
                        fontSize: 160,
                        fontWeight: FontWeight.w900,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
              if (_snap.phase.seconds != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 10,
                    color: color,
                    backgroundColor: Colors.white12,
                  ),
                ),
              const SizedBox(height: 24),
              if (showRoundButton) ...[
                SizedBox(
                  width: double.infinity,
                  height: 96,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _finished
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            setState(() => _manualRounds++);
                          },
                    child: Text(
                      'RUNDER: $_manualRounds   (+1)',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RoundIconButton(
                    icon: Icons.replay,
                    label: 'Nullstill',
                    onTap: _reset,
                  ),
                  _RoundIconButton(
                    icon: running ? Icons.pause : Icons.play_arrow,
                    label: running ? 'Pause' : 'Fortsett',
                    big: true,
                    color: color,
                    onTap: _finished ? null : _togglePause,
                  ),
                  _RoundIconButton(
                    icon: Icons.flag,
                    label: 'Ferdig',
                    onTap: _finished ? null : _finish,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.big = false,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool big;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final size = big ? 80.0 : 60.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: color ?? Colors.white24,
              foregroundColor: color == null ? Colors.white : Colors.black,
            ),
            iconSize: big ? 44 : 28,
            onPressed: onTap,
            icon: Icon(icon),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}
