import 'package:flutter/material.dart';

import '../data/app_store.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  Future<void> _edit(BuildContext context, [PersonalRecord? existing]) async {
    final store = StoreScope.of(context);
    final name = TextEditingController(text: existing?.name);
    final value = TextEditingController(text: existing?.value);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Ny PR' : 'Oppdater PR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: existing == null,
              decoration: const InputDecoration(
                labelText: 'Øvelse / benchmark',
                hintText: 'f.eks. Back squat, Fran',
              ),
            ),
            TextField(
              controller: value,
              autofocus: existing != null,
              decoration: const InputDecoration(
                labelText: 'Resultat',
                hintText: 'f.eks. 120 kg eller 4:32',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lagre'),
          ),
        ],
      ),
    );
    if (ok == true &&
        name.text.trim().isNotEmpty &&
        value.text.trim().isNotEmpty) {
      store.setRecord(
        PersonalRecord(
          name: name.text.trim(),
          value: value.text.trim(),
          date: DateTime.now(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('PERSONLIGE REKORDER')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add),
        label: const Text('Ny PR'),
      ),
      body: store.records.isEmpty
          ? Center(
              child: Text(
                'Ingen PR-er registrert ennå.',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: store.records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final pr = store.records[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.emoji_events,
                      color: Color(0xFFFFCA28),
                    ),
                    title: Text(
                      pr.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Satt ${pr.date.day}.${pr.date.month}.${pr.date.year}',
                    ),
                    trailing: Text(
                      pr.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    onTap: () => _edit(context, pr),
                    onLongPress: () => store.removeRecord(pr),
                  ),
                );
              },
            ),
    );
  }
}
