import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A completed workout in the log.
class LogEntry {
  LogEntry({
    required this.date,
    required this.title,
    required this.durationSeconds,
    this.rounds = 0,
    this.notes = '',
  });

  final DateTime date;
  final String title;
  final int durationSeconds;
  final int rounds;
  final String notes;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'title': title,
    'duration': durationSeconds,
    'rounds': rounds,
    'notes': notes,
  };

  factory LogEntry.fromJson(Map<String, dynamic> j) => LogEntry(
    date: DateTime.parse(j['date'] as String),
    title: j['title'] as String,
    durationSeconds: j['duration'] as int,
    rounds: j['rounds'] as int? ?? 0,
    notes: j['notes'] as String? ?? '',
  );
}

/// A personal record for a lift or benchmark.
class PersonalRecord {
  PersonalRecord({required this.name, required this.value, required this.date});

  final String name;

  /// Free-form value, e.g. "120 kg" or "4:32".
  final String value;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'date': date.toIso8601String(),
  };

  factory PersonalRecord.fromJson(Map<String, dynamic> j) => PersonalRecord(
    name: j['name'] as String,
    value: j['value'] as String,
    date: DateTime.parse(j['date'] as String),
  );
}

/// Holds the workout log and PRs, persisted with shared_preferences.
class AppStore extends ChangeNotifier {
  static const _logKey = 'log';
  static const _prKey = 'prs';

  final List<LogEntry> log = [];
  final List<PersonalRecord> records = [];
  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    log
      ..clear()
      ..addAll(
        (_prefs!.getStringList(_logKey) ?? []).map(
          (s) => LogEntry.fromJson(jsonDecode(s) as Map<String, dynamic>),
        ),
      );
    records
      ..clear()
      ..addAll(
        (_prefs!.getStringList(_prKey) ?? []).map(
          (s) => PersonalRecord.fromJson(jsonDecode(s) as Map<String, dynamic>),
        ),
      );
    notifyListeners();
  }

  void addLog(LogEntry e) {
    log.insert(0, e);
    _save();
  }

  void removeLog(LogEntry e) {
    log.remove(e);
    _save();
  }

  /// Adds a PR, replacing any existing record with the same name.
  void setRecord(PersonalRecord pr) {
    records.removeWhere((r) => r.name.toLowerCase() == pr.name.toLowerCase());
    records.add(pr);
    records.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    _save();
  }

  void removeRecord(PersonalRecord pr) {
    records.remove(pr);
    _save();
  }

  void _save() {
    notifyListeners();
    _prefs?.setStringList(
      _logKey,
      log.map((e) => jsonEncode(e.toJson())).toList(),
    );
    _prefs?.setStringList(
      _prKey,
      records.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}

/// Makes the [AppStore] available to the widget tree.
class StoreScope extends InheritedNotifier<AppStore> {
  const StoreScope({super.key, required AppStore store, required super.child})
    : super(notifier: store);

  static AppStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}
