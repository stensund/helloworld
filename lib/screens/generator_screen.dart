import 'package:flutter/material.dart';

import '../data/exercises.dart';
import '../widgets/value_stepper.dart';
import 'timer_run_screen.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final Set<Equipment> _equipment = {Equipment.kettlebell, Equipment.jumpRope};
  int _minutes = 15;
  GeneratedWod? _wod;

  void _generate() => setState(
    () => _wod = generateWod(equipment: _equipment, minutes: _minutes),
  );

  @override
  Widget build(BuildContext context) {
    final wod = _wod;
    return Scaffold(
      appBar: AppBar(title: const Text('WOD-GENERATOR')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Hvilket utstyr har du?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in Equipment.values.where(
                (e) => e != Equipment.none,
              ))
                FilterChip(
                  label: Text(e.label),
                  selected: _equipment.contains(e),
                  onSelected: (on) => setState(
                    () => on ? _equipment.add(e) : _equipment.remove(e),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ValueStepper(
            label: 'Varighet',
            value: _minutes,
            min: 5,
            max: 60,
            step: 5,
            format: (v) => '$v min',
            onChanged: (v) => setState(() => _minutes = v),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.casino),
            label: Text(wod == null ? 'LAG WOD' : 'NY WOD'),
          ),
          if (wod != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${wod.name}"',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wod.config.summary,
                      style: TextStyle(
                        color: wod.config.type.color,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Divider(height: 24),
                    for (final m in wod.movements)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '${m.reps}  ${m.name}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: wod.config.type.color,
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TimerRunScreen(
                            config: wod.config,
                            title: wod.name,
                            workout: wod.movements
                                .map((m) => '${m.reps} ${m.name}')
                                .join(' · '),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('START'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
