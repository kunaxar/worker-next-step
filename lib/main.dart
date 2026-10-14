import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data.dart';

void main() => runApp(const NextStepApp());

const orange = Color(0xFFE8590C);
const ink = Color(0xFF1F2933);
const sand = Color(0xFFFAF6F0);

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

class Work {
  final Trade trade;
  final String employer, period;
  final List<String> done;
  String status; // self, requested
  Work(this.trade, this.employer, this.period, this.done, {this.status = 'self'});
}

class Cred {
  final String name, issuer, note;
  final Color color;
  const Cred(this.name, this.issuer, this.note, this.color);
}

const demoCreds = [
  Cred('OSHA 10-Hour', 'Demo record', 'Expiry: read it from your card', Color(0xFF2B8A3E)),
  Cred('NCCER Core', 'Demo record', 'Added from photo', Color(0xFF1C7ED6)),
  Cred('First Aid / CPR', 'Demo record', 'Expiry: read it from your card', Color(0xFF9C36B5)),
];

final List<Work> works = [
  Work(trades[0], 'Brightline Electric (demo)', '2023 - now', [trades[0].tasks[0], trades[0].tasks[1], trades[0].tasks[4]], status: 'self'),
];
final ValueNotifier<int> tradeIdx = ValueNotifier(0);
final ValueNotifier<int> rev = ValueNotifier(0);

String money(int v) => '\$${v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';

Future<void> open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const MeTab(), const PayTab(), const NextTab()];
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SafeArea(child: AnimatedBuilder(animation: Listenable.merge([tradeIdx, rev]), builder: (_, __) => pages[tab])),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.badge_outlined), selectedIcon: Icon(Icons.badge), label: 'My work'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Pay'),
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Next step'),
        ],
      ),
    );
  }
}

Widget title(String t, [String? sub]) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ink)),
        if (sub != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(sub, style: const TextStyle(fontSize: 15, color: Color(0xFF52606D)))),
      ]),
    );

Widget demoBanner() => Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFFFF3BF), borderRadius: BorderRadius.circular(10)),
      child: const Text('Prototype. Fictional worker and records. Not connected to any real account.', style: TextStyle(fontSize: 12.5, color: ink)),
    );

// ---------------- My work ----------------
class MeTab extends StatelessWidget {
  const MeTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        title('Marcus (demo)', 'Your cards and your work, in one place'),
        demoBanner(),
        const Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, 8), child: Text('Cards', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17))),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: demoCreds.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final c = demoCreds[i];
              return Container(
                width: 190,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: c.color, borderRadius: BorderRadius.circular(18)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(c.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.issuer, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(c.note, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                  ]),
                ]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
          child: Row(children: [
            const Expanded(child: Text('Jobs I have worked', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17))),
            FilledButton.icon(
              onPressed: () async {
                final w = await Navigator.push<Work>(context, MaterialPageRoute(builder: (_) => const AddWork()));
                if (w != null) {
                  works.insert(0, w);
                  tradeIdx.value = trades.indexOf(w.trade);
                  rev.value++;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved. See what ${w.trade.name.toLowerCase()} pays on the Pay tab.')));
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add a job'),
            ),
          ]),
        ),
        for (final w in works) Padding(padding: const EdgeInsets.fromLTRB(20, 6, 20, 6), child: WorkCard(w)),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text('"Self-described" means you wrote it. It becomes "Confirmed" only when the supervisor you name says so.', style: TextStyle(fontSize: 12.5, color: Color(0xFF52606D))),
        ),
      ]);
}

class WorkCard extends StatefulWidget {
  final Work w;
  const WorkCard(this.w, {super.key});
  @override
  State<WorkCard> createState() => _WorkCardState();
}

class _WorkCardState extends State<WorkCard> {
  bool open = false;
  @override
  Widget build(BuildContext context) {
    final w = widget.w;
    final shown = open ? w.done : w.done.take(2).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(w.trade.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.trade.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              Text('${w.employer}  |  ${w.period}', style: const TextStyle(color: Color(0xFF52606D), fontSize: 13)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: w.status == 'self' ? const Color(0xFFE4E7EB) : const Color(0xFFFFE8CC), borderRadius: BorderRadius.circular(20)),
              child: Text(w.status == 'self' ? 'Self-described' : 'Waiting for supervisor', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 10),
          for (final t in shown)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check_circle, size: 16, color: Color(0xFF2B8A3E)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(t, style: const TextStyle(fontSize: 13.5))),
                ])),
          Row(children: [
            if (w.done.length > 2) TextButton(onPressed: () => setState(() => open = !open), child: Text(open ? 'Show less' : 'Show all ${w.done.length}')),
            const Spacer(),
            if (w.status == 'self')
              OutlinedButton(onPressed: () => _ask(context, w), child: const Text('Ask a supervisor to confirm')),
          ]),
        ]),
      ),
    );
  }

  void _ask(BuildContext context, Work w) {
    final nameC = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Who can vouch for this job?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 6),
          const Text('They get a link to review the list. Nothing shows as confirmed until they answer. (Demo: nothing is sent.)', style: TextStyle(fontSize: 13.5)),
          const SizedBox(height: 12),
          TextField(controller: nameC, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Supervisor name')),
          const SizedBox(height: 12),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: () {
                    setState(() => w.status = 'requested');
                    Navigator.pop(ctx);
                  },
                  child: const Text('Send request (demo)'))),
        ]),
      ),
    );
  }
}

// ---------------- Add a job ----------------
class AddWork extends StatefulWidget {
  const AddWork({super.key});
  @override
  State<AddWork> createState() => _AddWorkState();
}

class _AddWorkState extends State<AddWork> {
  int step = 0;
  Trade? trade;
  final emp = TextEditingController();
  String when = '2024 - now';
  final picked = <String>{};
  static const whens = ['2026 - now', '2025 - now', '2024 - now', '2023 - 2024', '2022 - 2023', '2020 - 2022'];

  @override
  Widget build(BuildContext context) {
    final steps = ['What kind of work?', 'Where and when?', 'What did you do?'];
    return Scaffold(
      appBar: AppBar(title: Text('Add a job  (${step + 1} of 3)'), backgroundColor: sand),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(children: [
            LinearProgressIndicator(value: (step + 1) / 3, color: orange, backgroundColor: const Color(0xFFEDE5DA)),
            title(steps[step], step == 2 ? 'Tap everything you really did on this job.' : null),
            Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 20), child: [stepTrade(), stepWhere(), stepTasks()][step])),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(children: [
                if (step > 0) OutlinedButton(onPressed: () => setState(() => step--), child: const Text('Back')),
                const Spacer(),
                FilledButton(
                  onPressed: _canNext() ? _next : null,
                  child: Text(step == 2 ? 'Save job (${picked.length})' : 'Next'),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  bool _canNext() => step == 0 ? trade != null : step == 1 ? emp.text.trim().isNotEmpty : picked.isNotEmpty;
  void _next() {
    if (step < 2) {
      setState(() => step++);
    } else {
      final done = trade!.tasks.where(picked.contains).toList();
      Navigator.pop(context, Work(trade!, emp.text.trim(), when, done));
    }
  }

  Widget stepTrade() => Wrap(spacing: 10, runSpacing: 10, children: [
        for (final t in trades)
          InkWell(
            onTap: () => setState(() {
              if (trade != t) picked.clear();
              trade = t;
            }),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 140,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                color: trade == t ? const Color(0xFFFFE3CF) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: trade == t ? orange : const Color(0xFFEDE5DA), width: trade == t ? 2 : 1),
              ),
              child: Column(children: [
                Text(t.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(t.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ]),
            ),
          ),
      ]);

  Widget stepWhere() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: emp, onChanged: (_) => setState(() {}), decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Company or crew', filled: true, fillColor: Colors.white)),
        const SizedBox(height: 16),
        const Text('When', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [for (final w in whens) ChoiceChip(label: Text(w), selected: when == w, onSelected: (_) => setState(() => when = w))]),
      ]);

  Widget stepTasks() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final t in trade!.tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => picked.contains(t) ? picked.remove(t) : picked.add(t)),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: picked.contains(t) ? const Color(0xFFFFE3CF) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: picked.contains(t) ? orange : const Color(0xFFEDE5DA)),
                ),
                child: Row(children: [
                  Icon(picked.contains(t) ? Icons.check_circle : Icons.add_circle_outline, color: picked.contains(t) ? orange : Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(child: Text(t, style: const TextStyle(fontSize: 14))),
                ]),
              ),
            ),
          ),
        const SizedBox(height: 8),
        const Text('Task list: O*NET, a US Department of Labor database. Tap only what you did.', style: TextStyle(fontSize: 12, color: Color(0xFF52606D))),
      ]);
}

// ---------------- shared trade picker ----------------
Widget tradePicker() => SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: trades.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ChoiceChip(label: Text('${trades[i].emoji} ${trades[i].name}'), selected: tradeIdx.value == i, onSelected: (_) => tradeIdx.value = i),
      ),
    );

// ---------------- Pay ----------------
class PayTab extends StatelessWidget {
  const PayTab({super.key});
  @override
  Widget build(BuildContext context) {
    final t = trades[tradeIdx.value];
    final hourly = (t.median / 2080);
    final sorted = [...trades]..sort((a, b) => b.median.compareTo(a.median));
    final maxV = sorted.first.median;
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      title('What it pays', 'Typical pay for ${t.name.toLowerCase()}s in the US'),
      tradePicker(),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('\$${hourly.toStringAsFixed(2)} an hour', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: orange)),
              const SizedBox(height: 4),
              Text('${money(t.median)} a year, middle of the pack', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              const Text('Half of workers earn more, half earn less. Local pay can be higher or lower. Not a promise of what you will earn.', style: TextStyle(fontSize: 13, color: Color(0xFF52606D))),
              const Divider(height: 28),
              Text('${money(t.jobs)} people work as ${t.name.toLowerCase()}s across the US. Average: ${money(t.mean)} a year.', style: const TextStyle(fontSize: 13.5)),
            ]),
          ),
        ),
      ),
      const Padding(padding: EdgeInsets.fromLTRB(20, 14, 20, 8), child: Text('How trades compare (yearly median)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
      for (final s in sorted)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: InkWell(
            onTap: () => tradeIdx.value = trades.indexOf(s),
            child: Row(children: [
              SizedBox(width: 120, child: Text(s.name, style: TextStyle(fontSize: 12.5, fontWeight: s == t ? FontWeight.w800 : FontWeight.w400), overflow: TextOverflow.ellipsis)),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(minHeight: 14, value: s.median / maxV, color: s == t ? orange : const Color(0xFFCBD2D9), backgroundColor: const Color(0xFFF0EAE0)))),
              SizedBox(width: 62, child: Text(money(s.median), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
            ]),
          ),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          const Expanded(child: Text('Source: US Bureau of Labor Statistics, Occupational Employment and Wage Statistics, national estimates for 2025.', style: TextStyle(fontSize: 12, color: Color(0xFF52606D)))),
          TextButton(onPressed: () => open('https://www.bls.gov/oes/'), child: const Text('bls.gov')),
        ]),
      ),
    ]);
  }
}

// ---------------- Next step ----------------
const zoneText = {
  2: ['Some training needed', 'Usually a high school diploma or GED, though some jobs do not need one. Training runs from a few days to one year on the job.'],
  3: ['Training plus experience', "Most jobs in this group need vocational school, related work experience, or an associate's degree. One or two years of on-the-job learning, and an apprenticeship may be part of it."],
};

class NextTab extends StatelessWidget {
  const NextTab({super.key});
  @override
  Widget build(BuildContext context) {
    final t = trades[tradeIdx.value];
    final z = zoneText[t.zone] ?? ['', ''];
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      title('Your next step', 'Where ${t.name.toLowerCase()}s go from here'),
      tradePicker(),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('HOW PEOPLE GET IN', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1, color: orange)),
              const SizedBox(height: 6),
              Text(z[0], style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(z[1], style: const TextStyle(fontSize: 14)),
            ]),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('SIMILAR WORK YOU COULD MOVE INTO', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1, color: orange)),
              const SizedBox(height: 8),
              for (final r in t.related)
                Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [const Icon(Icons.arrow_forward, size: 16), const SizedBox(width: 8), Expanded(child: Text(r, style: const TextStyle(fontSize: 14.5)))])),
            ]),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('FIND HELP NEAR YOU', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1, color: orange)),
              const SizedBox(height: 10),
              linkBtn(Icons.handshake_outlined, 'Find an apprenticeship', 'Opens Apprenticeship.gov', 'https://www.apprenticeship.gov/apprenticeship-job-finder'),
              linkBtn(Icons.school_outlined, 'Find training near you', 'Opens CareerOneStop', 'https://www.careeronestop.org/Toolkit/Training/find-local-training.aspx'),
              linkBtn(Icons.verified_outlined, 'Look up a certification', 'Opens CareerOneStop', 'https://www.careeronestop.org/Toolkit/Training/find-certifications.aspx'),
              linkBtn(Icons.info_outline, 'Read the full job profile', 'Opens O*NET OnLine', 'https://www.onetonline.org/link/summary/${t.soc}'),
            ]),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Text(
          'These open outside websites. This prototype copies none of their listings.\n\n'
          'This page includes information from the O*NET 31.0 Database by the U.S. Department of Labor, Employment and Training Administration (USDOL/ETA). Used under the CC BY 4.0 license. O*NET is a trademark of USDOL/ETA. This prototype has modified all or some of this information (selected, reordered, shown in a different layout). USDOL/ETA has not approved, endorsed, or tested these modifications.',
          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
        ),
      ),
    ]);
  }

  Widget linkBtn(IconData i, String t, String s, String url) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: const Color(0xFFFFE3CF), child: Icon(i, color: orange)),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(s, style: const TextStyle(fontSize: 12.5)),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () => open(url),
      );
}
