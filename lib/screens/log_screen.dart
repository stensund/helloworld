import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../models/wod_config.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final log = store.log;
    final totalSeconds = log.fold<int>(0, (s, e) => s + e.durationSeconds);

    return Scaffold(
      appBar: AppBar(title: const Text('TRENINGSLOGG')),
      body: log.isEmpty
          ? const _Empty(
              icon: Icons.list_alt,
              text: 'Ingen økter ennå.\nFullfør en WOD for å lagre den her.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _Stat(label: 'Økter', value: '${log.length}'),
                    const SizedBox(width: 12),
                    _Stat(
                      label: 'Total tid',
                      value: formatDuration(totalSeconds),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (final e in log)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Dismissible(
                      key: ObjectKey(e),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red.shade900,
                        child: const Icon(Icons.delete),
                      ),
                      onDismissed: (_) => store.removeLog(e),
                      child: Card(
                        child: ListTile(
                          title: Text(
                            e.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            [
                              _date(e.date),
                              if (e.notes.isNotEmpty) e.notes,
                            ].join('\n'),
                          ),
                          isThreeLine: e.notes.isNotEmpty,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatDuration(e.durationSeconds),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (e.rounds > 0) Text('${e.rounds} runder'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.white24),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
