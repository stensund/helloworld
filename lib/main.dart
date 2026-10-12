import 'package:flutter/material.dart';

import 'data/app_store.dart';
import 'screens/generator_screen.dart';
import 'screens/log_screen.dart';
import 'screens/records_screen.dart';
import 'screens/timer_home_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.load();
  runApp(SmartWodApp(store: store));
}

class SmartWodApp extends StatelessWidget {
  const SmartWodApp({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      store: store,
      child: MaterialApp(
        title: 'SmartWOD',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    TimerHomeScreen(),
    GeneratorScreen(),
    LogScreen(),
    RecordsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            label: 'Generator',
          ),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Logg'),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            label: 'PR',
          ),
        ],
      ),
    );
  }
}
