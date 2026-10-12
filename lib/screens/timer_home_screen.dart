import 'package:flutter/material.dart';

import '../models/wod_config.dart';
import 'timer_setup_screen.dart';

class TimerHomeScreen extends StatelessWidget {
  const TimerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'SMART'),
              TextSpan(
                text: 'WOD',
                style: TextStyle(color: Color(0xFFE53935)),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Velg WOD-type, still inn tiden og trykk GO!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          for (final type in WodType.values) ...[
            _WodTypeCard(type: type),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _WodTypeCard extends StatelessWidget {
  const _WodTypeCard({required this.type});

  final WodType type;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TimerSetupScreen(initial: WodConfig.defaults(type)),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: type.color, width: 6)),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(type.icon, color: type.color, size: 36),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.description,
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
