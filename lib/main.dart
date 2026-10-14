import 'package:flutter/material.dart';
import 'shared.dart';
import 'wallet.dart';
import 'work.dart';
import 'grow.dart';
import 'profile.dart';

void main() => runApp(const NextStepApp());

class NextStepApp extends StatelessWidget {
  const NextStepApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Next Step (prototype)',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: orange, brightness: Brightness.light).copyWith(primary: orange),
          scaffoldBackgroundColor: sand,
          textTheme: ThemeData.light().textTheme.apply(fontSizeFactor: 1.05),
          cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFFEDE5DA)))),
          navigationBarTheme: const NavigationBarThemeData(backgroundColor: Colors.white, indicatorColor: Color(0xFFFFE3CF)),
        ),
        home: const Shell(),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = int.tryParse(Uri.base.queryParameters['tab'] ?? '') ?? 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SafeArea(child: AnimatedBuilder(animation: Listenable.merge([tradeIdx, rev]), builder: (_, __) => <Widget>[WalletTab(), WorkTab(), GrowTab(), ProfileTab()][tab])),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.wallet_outlined), selectedIcon: Icon(Icons.wallet), label: 'Cards'),
          NavigationDestination(icon: Icon(Icons.construction_outlined), selectedIcon: Icon(Icons.construction), label: 'Work'),
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Grow'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}

class GrowTab extends StatefulWidget {
  const GrowTab({super.key});
  @override
  State<GrowTab> createState() => _GrowTabState();
}

class _GrowTabState extends State<GrowTab> {
  int seg = 0;
  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [ButtonSegment(value: 0, label: Text('Pay'), icon: Icon(Icons.payments_outlined)), ButtonSegment(value: 1, label: Text('Next step'), icon: Icon(Icons.trending_up))],
                selected: {seg},
                onSelectionChanged: (s) => setState(() => seg = s.first),
              )),
        ),
        Expanded(child: seg == 0 ? const PayTab() : const NextTab()),
      ]);
}
