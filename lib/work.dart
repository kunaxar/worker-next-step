import 'package:flutter/material.dart';
import 'data.dart';
import 'shared.dart';

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
  bool now = true;
  String startYear = '2024';
  String endYear = '2025';
  final picked = <String>{};
  static const years = ['2026', '2025', '2024', '2023', '2022', '2021', '2020'];

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
      Navigator.pop(context, Work(trade!, emp.text.trim(), now ? '\$startYear - now' : '\$startYear - \$endYear', done));
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
        const Text('Started', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [for (final y in years) ChoiceChip(label: Text(y), selected: startYear == y, onSelected: (_) => setState(() => startYear = y))]),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('I work here now'), value: now, onChanged: (v) => setState(() => now = v)),
        if (!now) ...[
          const Text('Ended', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [for (final y in years) ChoiceChip(label: Text(y), selected: endYear == y, onSelected: (_) => setState(() => endYear = y))]),
        ],
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


class WorkTab extends StatelessWidget {
  const WorkTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        title('My work', 'What you actually did, job by job'),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () async {
                final w = await Navigator.push<Work>(context, MaterialPageRoute(builder: (_) => const AddWork()));
                if (w != null) {
                  works.insert(0, w);
                  tradeIdx.value = trades.indexOf(w.trade);
                  rev.value++;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved. See what ${w.trade.name.toLowerCase()} pays under Grow.')));
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add a job'),
            ),
          ),
        ),
        if (works.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('Add your first job. Pick the trade, tap what you did. No typing needed beyond the company name.')),
        for (final w in works) Padding(padding: const EdgeInsets.fromLTRB(20, 6, 20, 6), child: WorkCard(w)),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text('"Self-described" means you wrote it. It becomes "Confirmed" only when the supervisor you name says so.', style: TextStyle(fontSize: 12.5, color: grey)),
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
