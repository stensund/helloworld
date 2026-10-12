import 'package:flutter/material.dart';

import '../models/timer_engine.dart';
import '../models/wod_config.dart';
import '../widgets/value_stepper.dart';
import 'timer_run_screen.dart';

class TimerSetupScreen extends StatefulWidget {
  const TimerSetupScreen({super.key, required this.initial});

  final WodConfig initial;

  @override
  State<TimerSetupScreen> createState() => _TimerSetupScreenState();
}

class _TimerSetupScreenState extends State<TimerSetupScreen> {
  late WodConfig _c = widget.initial;

  void _set(WodConfig c) => setState(() => _c = c);

  @override
  Widget build(BuildContext context) {
    final type = _c.type;
    final total = TimerEngine(_c.copyWith(countdownSeconds: 0)).totalSeconds;

    return Scaffold(
      appBar: AppBar(title: Text(type.label)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            type.description,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ..._fields().expand((w) => [w, const SizedBox(height: 8)]),
          ValueStepper(
            label: 'Nedtelling',
            value: _c.countdownSeconds,
            min: 0,
            max: 60,
            step: 5,
            format: (v) => '${v}s',
            onChanged: (v) => _set(_c.copyWith(countdownSeconds: v)),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              total == null
                  ? 'Total tid: åpen'
                  : 'Total tid: ${formatDuration(total)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: type.color),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TimerRunScreen(config: _c)),
            ),
            child: const Text('GO!'),
          ),
        ),
      ),
    );
  }

  List<Widget> _fields() {
    String secs(int v) => formatDuration(v);
    switch (_c.type) {
      case WodType.forTime:
        return [
          ValueStepper(
            label: 'Time cap',
            value: _c.minutes,
            max: 120,
            format: (v) => v == 0 ? 'Ingen' : '$v min',
            onChanged: (v) => _set(_c.copyWith(minutes: v)),
          ),
        ];
      case WodType.amrap:
        return [
          ValueStepper(
            label: 'Varighet',
            value: _c.minutes,
            min: 1,
            max: 120,
            format: (v) => '$v min',
            onChanged: (v) => _set(_c.copyWith(minutes: v)),
          ),
        ];
      case WodType.emom:
        return [
          ValueStepper(
            label: 'Hvert',
            value: _c.intervalSeconds,
            min: 15,
            max: 600,
            step: 15,
            format: secs,
            onChanged: (v) => _set(_c.copyWith(intervalSeconds: v)),
          ),
          ValueStepper(
            label: 'Runder',
            value: _c.rounds,
            min: 1,
            max: 100,
            onChanged: (v) => _set(_c.copyWith(rounds: v)),
          ),
        ];
      case WodType.tabata:
      case WodType.intervals:
        return [
          ValueStepper(
            label: 'Arbeid',
            value: _c.workSeconds,
            min: 5,
            max: 600,
            step: 5,
            format: secs,
            onChanged: (v) => _set(_c.copyWith(workSeconds: v)),
          ),
          ValueStepper(
            label: 'Hvile',
            value: _c.restSeconds,
            min: 0,
            max: 600,
            step: 5,
            format: secs,
            onChanged: (v) => _set(_c.copyWith(restSeconds: v)),
          ),
          ValueStepper(
            label: 'Runder',
            value: _c.rounds,
            min: 1,
            max: 100,
            onChanged: (v) => _set(_c.copyWith(rounds: v)),
          ),
        ];
    }
  }
}
